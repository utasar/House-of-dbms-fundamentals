DROP DATABASE HospitalManagement;
CREATE DATABASE HospitalManagement;
USE HospitalManagement;

-- CREATE TABLES
CREATE TABLE Insurance (
    InsuranceID VARCHAR(255) PRIMARY KEY NOT NULL,
    ProviderName VARCHAR(255) NOT NULL,
    InsuranceType VARCHAR(255) NOT NULL
);

CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(255) NOT NULL,
    DepartmentLocation VARCHAR(255) NOT NULL
);

CREATE TABLE Patient (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    PatientName VARCHAR(255) NOT NULL,
    DOB DATE NOT NULL,
    Gender VARCHAR(1),
    InsuranceMemberID VARCHAR(255),
    InsuranceID VARCHAR(255),
    CONSTRAINT fk_patient_insurance
        FOREIGN KEY (InsuranceID)
        REFERENCES Insurance(InsuranceID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE PatientContact (
    Phone VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(50) NOT NULL UNIQUE,
    PatientID INT NOT NULL,
    CONSTRAINT fk_patient_phone
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);

CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT,
    DoctorName VARCHAR(255) NOT NULL,
    Speciality VARCHAR(255) NOT NULL,
    OfficeNumber VARCHAR(255) NOT NULL UNIQUE,
    DepartmentID INT,
    CONSTRAINT fk_doctor_department
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Room (
    RoomID INT PRIMARY KEY AUTO_INCREMENT,
    RoomType VARCHAR(255) NOT NULL,
    RoomStatus ENUM('Available', 'Occupied')
);

CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Reason VARCHAR(255) NOT NULL,
    RoomID INT,
    CONSTRAINT fk_appointment_patient
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fk_appointment_doctor
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT fk_appointment_room
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

CREATE TABLE Nurse (
    NurseID INT PRIMARY KEY AUTO_INCREMENT,
    NurseName VARCHAR(255) NOT NULL,
    DepartmentID INT,
    CONSTRAINT fk_nurse_department
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Billing (
    BillingID INT PRIMARY KEY AUTO_INCREMENT,
    TotalBill DECIMAL(10, 2) NOT NULL,
    BillingDate DATE NOT NULL,
    BillType VARCHAR(255) NOT NULL,
    AppointmentID INT NOT NULL,
    CONSTRAINT fk_billing_appointment   
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

-- INSERT STATEMENTS
INSERT INTO Insurance (InsuranceID, ProviderName, InsuranceType) VALUES
('BCBS-BASIC-01', 'Blue Cross Blue Shield', 'Basic'),
('BCBS-PREM-01', 'Blue Cross Blue Shield', 'Premium'),
('AETNA-BASIC-01', 'Aetna', 'Basic'),
('AETNA-PREM-01', 'Aetna', 'Premium'),
('CIGNA-BASIC-01', 'Cigna', 'Basic'),
('CIGNA-PREM-01', 'Cigna', 'Premium'),
('UHC-STD-01', 'UnitedHealthCare', 'Standard'),
('UHC-PREM-01', 'UnitedHealthCare', 'Premium'),
('HUMANA-STD-01', 'Humana', 'Standard'),
('HUMANA-PREM-01', 'Humana', 'Premium'),
('KAISER-STD-01', 'Kaiser', 'Standard'),
('KAISER-PREM-01', 'Kaiser', 'Premium');

INSERT INTO Department (DepartmentName, DepartmentLocation) VALUES
('Cardiology', 'Building A'),
('Anesthesiology', 'Building B'),
('ENT', 'Building C'),
('Geriatrics', 'Building D'),
('Pediatrics', 'Building E'),
('Neurology', 'Building F'),
('Oncology', 'Building G'),
('Orthopedics', 'Building H'),
('Radiology', 'Building I'),
('Surgery', 'Building J'),
('Emergency', 'Building K');

INSERT INTO Patient (PatientName, DOB, Gender, InsuranceID) VALUES
('John Webb', '1980-12-01', 'M', 'BCBS-PREM-01'),
('Sarah Jones', '1995-09-23', 'F', 'BCBS-BASIC-01'),
('Ron Brown', '2005-01-15', 'M', 'AETNA-BASIC-01'),
('Emily Wilson', '2004-07-30', 'F', 'AETNA-PREM-01'),
('William Johnson', '1988-11-10', 'M', 'CIGNA-PREM-01'),
('Lily Martin', '1990-03-05', 'F', 'CIGNA-BASIC-01'),
('James Miller', '1985-02-28', 'M', 'UHC-PREM-01'),
('Sophia Anderson', '1992-06-18', 'F', 'KAISER-PREM-01');

INSERT INTO PatientContact (Phone, Email, PatientID) VALUES
('123-456-7890', 'john.webb@gmail.com', 1),
('234-567-8901', 'sarah.jones@gmail.com', 2),
('345-678-9012', 'ron.brown@gmail.com', 3),
('456-789-0123', 'emily.wilson@gmail.com', 4),
('567-890-1234', 'william.johnson@gmail.com', 5),
('678-901-2345', 'lily.martin@gmail.com', 6),
('789-012-3456', 'james.miller@gmail.com', 7),
('890-123-4567', 'sophia.anderson@gmail.com', 8);

INSERT INTO Doctor (DoctorName, Speciality, OfficeNumber, DepartmentID) VALUES
('Dr. Smith', 'Cardiologist', '101', 1),
('Dr. Harris', 'Cardiologist', '112', 1),
('Dr. Johnson', 'Anesthesiologist', '102', 2),
('Dr. Lee', 'ENT Specialist', '103', 3),
('Dr. Brown', 'Geriatrician', '104', 4),
('Dr. Davis', 'Pediatrician', '105', 5),
('Dr. Wilson', 'Neurologist', '106', 6),
('Dr. Taylor', 'Oncologist', '107', 7),
('Dr. Anderson', 'Orthopedic Surgeon', '108', 8),
('Dr. Thomas', 'Radiologist', '109', 9),
('Dr. Jackson', 'Surgeon', '110', 10),
('Dr. White', 'Emergency Specialist', '111', 11);

INSERT INTO Room (RoomType, RoomStatus) VALUES
('General', 'Available'),
('ICU', 'Occupied'),
('Emergency', 'Occupied'),
('Recovery', 'Available'),
('Surgery', 'Available'),
('Radiology', 'Available'),
('Pediatric', 'Available'),
('Cardiac', 'Occupied');

INSERT INTO Appointment (PatientID, DoctorID, AppointmentDate, AppointmentTime, Reason, RoomID) VALUES
(1, 1, '2026-04-10', '09:00:00', 'Chest pain', 8),
(2, 2, '2026-04-11', '10:00:00', 'Surgery consultation', 5),
(3, 3, '2026-04-12', '11:00:00', 'Stomach pain', 3),
(4, 4, '2026-04-13', '12:00:00', 'Regular checkup', 1),
(5, 5, '2026-04-14', '13:00:00', 'Child fever', 7),
(6, 6, '2026-04-15', '14:00:00', 'Headache scan', 6),
(7, 7, '2026-04-16', '15:00:00', 'Cancer diagnosis', 2),
(8, 8, '2026-04-17', '16:00:00', 'Bone fracture treatment', 5);

INSERT INTO Nurse (NurseName, DepartmentID) VALUES
('Nurse Anna', 1),
('Nurse Betty', 2),
('Nurse Carol', 3),
('Nurse Diana', 4),
('Nurse Emily', 5),
('Nurse Frank', 6),
('Nurse Gianna', 7),
('Nurse Hailey', 8),
('Nurse Isabella', 9),
('Nurse Jane', 10),
('Nurse Karen', 11);

INSERT INTO Billing (TotalBill, BillingDate, BillType, AppointmentID) VALUES
(500.00, '2026-04-10', 'Consultation', 1),
(100.00, '2026-04-10', 'Lab Test', 1),
(1500.00, '2026-04-11', 'Surgery Fee', 2),
(200.00, '2026-04-12', 'Medication', 3),
(300.00, '2026-04-14', 'Follow-up', 5);

INSERT INTO Patient (PatientName, DOB, Gender, InsuranceMemberID, InsuranceID)
VALUES ('Alex Honk', '2000-05-15', 'M', NULL, NULL);

--View: Patient billing summary
CREATE VIEW PatientBilling AS
SELECT p.PatientName,p.PatientID,
COUNT(DISTINCT app.AppointmentID) AS TotalAppointments,
SUM(b.TotalBill) AS TotalAmountBilled
FROM Patient p
JOIN Appointment app ON p.PatientID = app.PatientID
JOIN Billing b ON app.AppointmentID = b.AppointmentID
GROUP BY p.PatientID, p.PatientName;

-- QUERIES

--JOIN- Insurance for each patient
SELECT p.PatientName,p.Gender,i.ProviderName,i.InsuranceType FROM Patient p 
JOIN Insurance i ON p.InsuranceID = i.InsuranceID;

--JOIN- Patient without insurance
SELECT p.PatientName, p.Gender, i.ProviderName, i.InsuranceType
FROM Patient p LEFT JOIN Insurance i ON p.InsuranceID = i.InsuranceID
WHERE i.InsuranceID IS NULL;

--JOIN- Doctors and their departments
SELECT d.DoctorName, d.Speciality, dept.DepartmentName FROM Doctor d
JOIN Department dept ON d.DepartmentID = dept.DepartmentID;

--JOIN- Appointments with patient and doctor details
SELECT app.AppointmentDate, app.AppointmentTime, p.PatientName, d.DoctorName, app.Reason FROM Appointment app
JOIN Patient p ON app.PatientID = p.PatientID
JOIN Doctor d ON app.DoctorID = d.DoctorID;

--GROUP BY + COUNT- Total appointments per doctor
SELECT d.DoctorName, COUNT(app.AppointmentID) AS TotalAppointments
FROM Doctor d
LEFT JOIN Appointment app
ON d.DoctorID = app.DoctorID
GROUP BY d.DoctorName;

--GROUP BY + SUM- Total bill per appointment
SELECT AppointmentID, SUM(TotalBill) AS TotalBill FROM Billing
GROUP BY AppointmentID;

--ORDER BY- List of doctors ordered by name
SELECT DoctorName
FROM Doctor
ORDER BY DoctorName ASC;

--SUBQUERY — Doctors who have at least one appointment
SELECT DoctorName
FROM Doctor
WHERE DoctorID IN (
    SELECT DoctorID
    FROM Appointment
);

--JOIN- Doctors in the Cardiology department
SELECT d.DoctorName, d.Speciality, d.OfficeNumber
FROM Doctor d
JOIN Department dept ON d.DepartmentID = dept.DepartmentID
WHERE dept.DepartmentName = 'Cardiology';



