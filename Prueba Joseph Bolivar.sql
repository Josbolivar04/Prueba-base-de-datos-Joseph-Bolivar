-- =========================================================================
-- 1. CREACIÓN DE LA BASE DE DATOS Y CONFIGURACIÓN
-- =========================================================================
CREATE DATABASE IF NOT EXISTS riwi_maintenance_db;
USE riwi_maintenance_db;


DROP TABLE IF EXISTS riwi_work_orders;
DROP TABLE IF EXISTS riwi_equipment;
DROP TABLE IF EXISTS riwi_branches;
DROP TABLE IF EXISTS riwi_service_types;
DROP TABLE IF EXISTS riwi_equipment_categories;
DROP TABLE IF EXISTS riwi_technicians;
DROP TABLE IF EXISTS riwi_clients;
DROP TABLE IF EXISTS riwi_cities;


CREATE TABLE riwi_cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE riwi_clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE riwi_technicians (
    technician_id INT AUTO_INCREMENT PRIMARY KEY,
    technician_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE riwi_equipment_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE riwi_service_types (
    service_type_id INT AUTO_INCREMENT PRIMARY KEY,
    service_type_name VARCHAR(50) UNIQUE NOT NULL
) ENGINE=InnoDB;



CREATE TABLE riwi_branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city_id INT NOT NULL,
    CONSTRAINT fk_branch_city FOREIGN KEY (city_id) 
        REFERENCES riwi_cities(city_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE riwi_equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT fk_equipment_category FOREIGN KEY (category_id) 
        REFERENCES riwi_equipment_categories(category_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;



CREATE TABLE riwi_work_orders (
    order_id VARCHAR(20) PRIMARY KEY,
    service_date DATE NOT NULL,
    hours INT NOT NULL,
    client_id INT NOT NULL,
    branch_id INT NOT NULL,
    technician_id INT NOT NULL,
    equipment_id INT NOT NULL,
    service_type_id INT NOT NULL,
    
    CONSTRAINT fk_orders_client FOREIGN KEY (client_id) 
        REFERENCES riwi_clients(client_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT fk_orders_branch FOREIGN KEY (branch_id) 
        REFERENCES riwi_branches(branch_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT fk_orders_technician FOREIGN KEY (technician_id) 
        REFERENCES riwi_technicians(technician_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT fk_orders_equipment FOREIGN KEY (equipment_id) 
        REFERENCES riwi_equipment(equipment_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
    CONSTRAINT fk_orders_service_type FOREIGN KEY (service_type_id) 
        REFERENCES riwi_service_types(service_type_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;



INSERT INTO riwi_cities (city_name) VALUES ('Medellín'), ('Bogotá');
INSERT INTO riwi_clients (client_name) VALUES ('Acme Corp'), ('Globex Industries');
INSERT INTO riwi_technicians (technician_name) VALUES ('John Doe'), ('Jane Smith');
INSERT INTO riwi_equipment_categories (category_name) VALUES ('Heavy Machinery'), ('IT Infrastructure');
INSERT INTO riwi_service_types (service_type_name) VALUES ('Preventive Maintenance'), ('Emergency Repair');


INSERT INTO riwi_branches (branch_name, city_id) VALUES ('Poblado HQ', 1), ('North Branch', 2);
INSERT INTO riwi_equipment (equipment_name, category_id) VALUES ('Hydraulic Press X1', 1), ('Server Blade Rack', 2);


INSERT INTO riwi_work_orders (order_id, service_date, hours, client_id, branch_id, technician_id, equipment_id, service_type_id) 
VALUES ('WO-2026-001', '2026-03-15', 5, 1, 1, 1, 1, 1);


SELECT 
    wo.order_id AS 'Order ID',
    wo.service_date AS 'Date',
    cl.client_name AS 'Client',
    br.branch_name AS 'Branch',
    ci.city_name AS 'City',
    tech.technician_name AS 'Technician',
    eq.equipment_name AS 'Equipment',
    st.service_type_name AS 'Service Type',
    wo.hours AS 'Hours Logs'
FROM riwi_work_orders wo
INNER JOIN riwi_clients cl ON wo.client_id = cl.client_id
INNER JOIN riwi_branches br ON wo.branch_id = br.branch_id
INNER JOIN riwi_cities ci ON br.city_id = ci.city_id
INNER JOIN riwi_technicians tech ON wo.technician_id = tech.technician_id
INNER JOIN riwi_equipment eq ON wo.equipment_id = eq.equipment_id
INNER JOIN riwi_service_types st ON wo.service_type_id = st.service_type_id;
