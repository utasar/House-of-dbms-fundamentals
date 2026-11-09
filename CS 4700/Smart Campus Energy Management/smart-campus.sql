-- CS 4700/6700 Database Design Project — Fall 2026
-- Smart Campus Micro-Grid Energy Management Database
-- Dialect: MySQL 8.0+
-- Run in a dedicated project database/schema. The reset section below drops
-- only the six project tables; do not run it in a schema with data to preserve.
-- Example setup (run separately if needed): CREATE DATABASE smart_campus_energy;
-- USE smart_campus_energy;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS MaintenanceTicket;
DROP TABLE IF EXISTS EnergyReading;
DROP TABLE IF EXISTS SmartMeter;
DROP TABLE IF EXISTS GridPricingTier;
DROP TABLE IF EXISTS RenewableSource;
DROP TABLE IF EXISTS Building;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Building (
    building_id INT PRIMARY KEY,
    building_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200) NOT NULL,
    building_type VARCHAR(40) NOT NULL,
    floor_area_sq_m DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_building_area CHECK (floor_area_sq_m > 0)
) ENGINE=InnoDB;

CREATE TABLE RenewableSource (
    source_id INT PRIMARY KEY,
    building_id INT NOT NULL,
    source_name VARCHAR(100) NOT NULL,
    source_type VARCHAR(30) NOT NULL,
    capacity_kw DECIMAL(10,2) NOT NULL,
    installation_date DATE NOT NULL,
    CONSTRAINT fk_source_building FOREIGN KEY (building_id)
        REFERENCES Building(building_id),
    CONSTRAINT chk_source_type CHECK (source_type IN ('SOLAR', 'WIND', 'OTHER')),
    CONSTRAINT chk_source_capacity CHECK (capacity_kw > 0)
) ENGINE=InnoDB;

CREATE TABLE SmartMeter (
    meter_id INT PRIMARY KEY,
    building_id INT NOT NULL,
    source_id INT NULL,
    meter_name VARCHAR(100) NOT NULL,
    meter_type VARCHAR(30) NOT NULL,
    installation_date DATE NOT NULL,
    CONSTRAINT fk_meter_building FOREIGN KEY (building_id)
        REFERENCES Building(building_id),
    CONSTRAINT fk_meter_source FOREIGN KEY (source_id)
        REFERENCES RenewableSource(source_id),
    CONSTRAINT chk_meter_type CHECK (
        meter_type IN ('BUILDING_LOAD', 'GRID_IMPORT', 'RENEWABLE_GENERATION')
    ),
    CONSTRAINT chk_generation_has_source CHECK (
        meter_type <> 'RENEWABLE_GENERATION' OR source_id IS NOT NULL
    )
) ENGINE=InnoDB;

CREATE TABLE GridPricingTier (
    pricing_tier_id INT PRIMARY KEY,
    tier_name VARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    price_per_kwh DECIMAL(10,4) NOT NULL,
    carbon_kg_per_kwh DECIMAL(10,4) NOT NULL,
    CONSTRAINT chk_tier_time CHECK (start_time < end_time),
    CONSTRAINT chk_tier_price CHECK (price_per_kwh >= 0),
    CONSTRAINT chk_tier_carbon CHECK (carbon_kg_per_kwh >= 0)
) ENGINE=InnoDB;

CREATE TABLE EnergyReading (
    reading_id INT PRIMARY KEY,
    meter_id INT NOT NULL,
    pricing_tier_id INT NULL,
    reading_timestamp DATETIME NOT NULL,
    energy_kwh DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_reading_meter FOREIGN KEY (meter_id)
        REFERENCES SmartMeter(meter_id),
    CONSTRAINT fk_reading_tier FOREIGN KEY (pricing_tier_id)
        REFERENCES GridPricingTier(pricing_tier_id),
    CONSTRAINT chk_reading_energy CHECK (energy_kwh >= 0),
    INDEX idx_reading_time_meter (reading_timestamp, meter_id)
) ENGINE=InnoDB;

CREATE TABLE MaintenanceTicket (
    ticket_id INT PRIMARY KEY,
    meter_id INT NULL,
    source_id INT NULL,
    reported_date DATE NOT NULL,
    description VARCHAR(500) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    resolved_date DATE NULL,
    CONSTRAINT fk_ticket_meter FOREIGN KEY (meter_id)
        REFERENCES SmartMeter(meter_id),
    CONSTRAINT fk_ticket_source FOREIGN KEY (source_id)
        REFERENCES RenewableSource(source_id),
    CONSTRAINT chk_ticket_one_asset CHECK (
        (meter_id IS NOT NULL AND source_id IS NULL)
        OR (meter_id IS NULL AND source_id IS NOT NULL)
    ),
    CONSTRAINT chk_ticket_status CHECK (
        status IN ('OPEN', 'IN_PROGRESS', 'CLOSED')
    ),
    CONSTRAINT chk_ticket_resolution CHECK (
        resolved_date IS NULL OR resolved_date >= reported_date
    )
) ENGINE=InnoDB;

-- Sample data: fictional campus buildings.
INSERT INTO Building
    (building_id, building_name, location, building_type, floor_area_sq_m)
VALUES
    (1, 'Central Library', 'North Campus', 'Library', 12000.00),
    (2, 'Science Hall', 'East Campus', 'Academic', 18000.00),
    (3, 'Residence Hall', 'South Campus', 'Residential', 15000.00);

INSERT INTO RenewableSource
    (source_id, building_id, source_name, source_type, capacity_kw, installation_date)
VALUES
    (1, 1, 'Library rooftop solar', 'SOLAR', 80.00, '2024-06-15'),
    (2, 2, 'Science Hall solar', 'SOLAR', 120.00, '2025-03-20');

INSERT INTO SmartMeter
    (meter_id, building_id, source_id, meter_name, meter_type, installation_date)
VALUES
    (101, 1, NULL, 'Library load meter', 'BUILDING_LOAD', '2024-01-10'),
    (102, 1, NULL, 'Library grid meter', 'GRID_IMPORT', '2024-01-10'),
    (103, 1, 1, 'Library solar meter', 'RENEWABLE_GENERATION', '2024-06-15'),
    (201, 2, NULL, 'Science load meter', 'BUILDING_LOAD', '2024-01-10'),
    (202, 2, NULL, 'Science grid meter', 'GRID_IMPORT', '2024-01-10'),
    (203, 2, 2, 'Science solar meter', 'RENEWABLE_GENERATION', '2025-03-20'),
    (301, 3, NULL, 'Residence load meter', 'BUILDING_LOAD', '2024-01-10'),
    (302, 3, NULL, 'Residence grid meter', 'GRID_IMPORT', '2024-01-10');

INSERT INTO GridPricingTier
    (pricing_tier_id, tier_name, start_time, end_time, price_per_kwh, carbon_kg_per_kwh)
VALUES
    (1, 'Off-peak', '00:00:00', '07:00:00', 0.0800, 0.4000),
    (2, 'Standard', '07:00:00', '16:00:00', 0.1200, 0.3500),
    (3, 'Peak', '16:00:00', '23:59:59', 0.2000, 0.5000);

INSERT INTO EnergyReading
    (reading_id, meter_id, pricing_tier_id, reading_timestamp, energy_kwh)
VALUES
    (1, 101, NULL, '2026-11-02 09:00:00', 120.00),
    (2, 102, 2,    '2026-11-02 09:00:00', 100.00),
    (3, 103, NULL, '2026-11-02 09:00:00', 20.00),
    (4, 201, NULL, '2026-11-02 09:00:00', 180.00),
    (5, 202, 2,    '2026-11-02 09:00:00', 150.00),
    (6, 203, NULL, '2026-11-02 09:00:00', 30.00),
    (7, 101, NULL, '2026-11-02 18:00:00', 140.00),
    (8, 102, 3,    '2026-11-02 18:00:00', 110.00),
    (9, 301, NULL, '2026-11-02 18:00:00', 250.00),
    (10, 302, 3,   '2026-11-02 18:00:00', 200.00);

INSERT INTO MaintenanceTicket
    (ticket_id, meter_id, source_id, reported_date, description, status, resolved_date)
VALUES
    (1, 302, NULL, '2026-11-01', 'Meter readings intermittently missing', 'OPEN', NULL),
    (2, NULL, 2, '2026-10-25', 'Inspect solar inverter connection', 'CLOSED', '2026-10-27');

-- Q1: Total building-load energy by building on November 2, 2026.
SELECT b.building_name, SUM(er.energy_kwh) AS total_load_kwh
FROM EnergyReading AS er
JOIN SmartMeter AS sm ON sm.meter_id = er.meter_id
JOIN Building AS b ON b.building_id = sm.building_id
WHERE sm.meter_type = 'BUILDING_LOAD'
  AND er.reading_timestamp >= '2026-11-02 00:00:00'
  AND er.reading_timestamp <  '2026-11-03 00:00:00'
GROUP BY b.building_id, b.building_name
ORDER BY b.building_id;

-- Q2: Peak recorded load interval per building for that date (not instantaneous kW).
SELECT b.building_name, er.reading_timestamp, er.energy_kwh AS peak_interval_kwh
FROM EnergyReading AS er
JOIN SmartMeter AS sm ON sm.meter_id = er.meter_id
JOIN Building AS b ON b.building_id = sm.building_id
WHERE sm.meter_type = 'BUILDING_LOAD'
  AND er.reading_timestamp >= '2026-11-02 00:00:00'
  AND er.reading_timestamp <  '2026-11-03 00:00:00'
  AND er.energy_kwh = (
      SELECT MAX(er2.energy_kwh)
      FROM EnergyReading AS er2
      JOIN SmartMeter AS sm2 ON sm2.meter_id = er2.meter_id
      WHERE sm2.building_id = b.building_id
        AND sm2.meter_type = 'BUILDING_LOAD'
        AND er2.reading_timestamp >= '2026-11-02 00:00:00'
        AND er2.reading_timestamp <  '2026-11-03 00:00:00'
  )
ORDER BY b.building_id;

-- Q3: Grid import and estimated energy cost, grouped by building and rate tier.
SELECT b.building_name, gpt.tier_name,
       SUM(er.energy_kwh) AS imported_kwh,
       SUM(er.energy_kwh * gpt.price_per_kwh) AS estimated_cost
FROM EnergyReading AS er
JOIN SmartMeter AS sm ON sm.meter_id = er.meter_id
JOIN Building AS b ON b.building_id = sm.building_id
JOIN GridPricingTier AS gpt ON gpt.pricing_tier_id = er.pricing_tier_id
WHERE sm.meter_type = 'GRID_IMPORT'
  AND er.reading_timestamp >= '2026-11-02 00:00:00'
  AND er.reading_timestamp <  '2026-11-03 00:00:00'
  AND TIME(er.reading_timestamp) >= gpt.start_time
  AND TIME(er.reading_timestamp) <= gpt.end_time
GROUP BY b.building_id, b.building_name, gpt.pricing_tier_id, gpt.tier_name
ORDER BY b.building_id, gpt.pricing_tier_id;

-- Q4: Estimated grid carbon by building using the sample tier emissions factors.
SELECT b.building_name,
       SUM(er.energy_kwh * gpt.carbon_kg_per_kwh) AS estimated_grid_carbon_kg
FROM EnergyReading AS er
JOIN SmartMeter AS sm ON sm.meter_id = er.meter_id
JOIN Building AS b ON b.building_id = sm.building_id
JOIN GridPricingTier AS gpt ON gpt.pricing_tier_id = er.pricing_tier_id
WHERE sm.meter_type = 'GRID_IMPORT'
  AND er.reading_timestamp >= '2026-11-02 00:00:00'
  AND er.reading_timestamp <  '2026-11-03 00:00:00'
  AND TIME(er.reading_timestamp) >= gpt.start_time
  AND TIME(er.reading_timestamp) <= gpt.end_time
GROUP BY b.building_id, b.building_name
ORDER BY b.building_id;

-- Q5: Renewable generation by building and renewable source.
SELECT b.building_name, rs.source_name,
       SUM(er.energy_kwh) AS generated_kwh
FROM EnergyReading AS er
JOIN SmartMeter AS sm ON sm.meter_id = er.meter_id
JOIN RenewableSource AS rs ON rs.source_id = sm.source_id
JOIN Building AS b ON b.building_id = rs.building_id
WHERE sm.meter_type = 'RENEWABLE_GENERATION'
  AND er.reading_timestamp >= '2026-11-02 00:00:00'
  AND er.reading_timestamp <  '2026-11-03 00:00:00'
GROUP BY b.building_id, b.building_name, rs.source_id, rs.source_name
ORDER BY b.building_id;

-- Q6: Open and in-progress maintenance, with the associated asset/building.
SELECT mt.ticket_id, mt.description, mt.status,
       COALESCE(sm.meter_name, rs.source_name) AS equipment,
       b.building_name
FROM MaintenanceTicket AS mt
LEFT JOIN SmartMeter AS sm ON sm.meter_id = mt.meter_id
LEFT JOIN RenewableSource AS rs ON rs.source_id = mt.source_id
JOIN Building AS b ON b.building_id = COALESCE(sm.building_id, rs.building_id)
WHERE mt.status IN ('OPEN', 'IN_PROGRESS')
ORDER BY mt.reported_date, mt.ticket_id;

-- DML demonstration: INSERT, UPDATE, DELETE. Roll back so sample relation states
-- remain unchanged after the demo. Run after the seed inserts above.
START TRANSACTION;
INSERT INTO MaintenanceTicket
    (ticket_id, meter_id, source_id, reported_date, description, status, resolved_date)
VALUES
    (99, 101, NULL, '2026-11-03', 'Demonstration ticket; transaction will roll back', 'OPEN', NULL);
UPDATE MaintenanceTicket
SET status = 'IN_PROGRESS'
WHERE ticket_id = 99;
DELETE FROM MaintenanceTicket
WHERE ticket_id = 99;
ROLLBACK;
