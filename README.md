Riwi Work Orders Database Project by Joseph David Bolivar Torres
Cortizoss Clan

#Project Description
This project implements a robust, fully normalized relational database designed to track and manage industrial or technical **Work Orders** for Riwi. The system effectively records and organizes critical operational data, including the clients requesting services, the specific technicians assigned, the equipment involved (categorized by type), the types of services performed, and the locations (cities and branches) where the work takes place. The primary goal is to eliminate data redundancy, enforce referential integrity, and optimize operational reporting.

---

## Technologies Used
* **DBML (Database Markup Language)**: Used for database design, modeling, and visualization on dbdiagram.io.


---

##Database Engine
* **PostgreSQL (v15+)**: Selected for its advanced support of relational integrity constraints, robust indexing mechanisms, compliance with SQL standards, and excellent performance handling transactional data.

---

# Explanation of the Normalization Process
The database was transformed from a flat, unorganized structure into a highly efficient relational model by applying the **Three Normal Forms (1NF, 2NF, 3NF)**:

1. **First Normal Form (1NF)**: 
   * Ensured all table attributes are atomic (no multi-valued or nested groups).
   * Defined clear, unique primary keys for every table (e.g., `order_id`, `client_id`).

2. **Second Normal Form (2NF)**:
   * Removed partial dependencies by isolating entities into their own specialized tables.
   * Attributes like `client_name`, `technician_name`, and `equipment_name` were moved out of the main work orders table and linked via foreign keys, ensuring every non-key column depends entirely on the whole primary key.

3. **Third Normal Form (3NF)**:
   * Eliminated transitive dependencies to ensure non-key columns depend *only* on the primary key, not on other non-key columns.
   * **Location Optimization**: Previously, work orders directly referenced both cities and branches. To enforce 3NF, the relation was restructured: a branch now strictly belongs to a city (`riwi_branches.city_id`), and the work order references only the branch (`riwi_work_orders.branch_id`). This prevents data anomalies, such as mistakenly pairing a branch from City A with a record from City B.
   * Equipment names and categories were split (`riwi_equipment` and `riwi_equipment_categories`) so category modifications do not impact individual asset logs.

# Database Structure

The database consists of **7 dimensional/master tables** and **1 central transactional/fact table**:

# Master Tables
* `riwi_cities`: Stores unique geographical city locations.
* `riwi_branches`: Stores specific facility branches, directly linked to a parent city.
* `riwi_clients`: Stores company or individual client information.
* `riwi_technicians`: Stores details of the technicians executing the services.
* `riwi_equipment_categories`: Classifies machinery or tools into unique logical groups.
* `riwi_equipment`: Tracks individual pieces of equipment linked to a category.
* `riwi_service_types`: Defines the type of work performed (e.g., Maintenance, Repair).

# Transactional Table
* `riwi_work_orders`: The core operational table logging dates, duration (`hours`), and mapping all participating entities through structured foreign keys.

# Entity Relationship Diagram
The Entity Relationship Diagram (ERD) mapping this schema features a **Star/Snowflake-hybrid layout** optimized for transactional consistency. 

You can view, interact with, and export the live diagram using the code below:

* **Modeling Tool**: [dbdiagram.io](https://dbdiagram.io/d/6a4c07dc36d348d1207e3778)



Table riwi_city {
  city_id integer [primary key, increment]
  city_name varchar(100) [unique, not null]
}

Table riwi_branches {
  branch_id integer [primary key, increment]
  branch_name varchar(100) [not null]
  city_id integer [ref: > riwi_city.city_id]
}

Table riwi_clients {
  client_id integer [primary key, increment]
  client_name varchar(100) [not null]
}

Table riwi_technicians {
  technician_id integer [primary key, increment]
  technician_name varchar(100) [not null]
}

Table riwi_equipment_categories {
  category_id integer [primary key, increment]
  category_name varchar(50) [unique, not null]
}

Table riwi_service_types {
  service_type_id integer [primary key, increment]
  service_type_name varchar(50) [unique, not null]
}

Table riwi_equipment {
  equipment_id integer [primary key, increment]
  equipment_name varchar(100) [not null]
  category_id integer [ref: > riwi_equipment_categories.category_id]
}


Table riwi_work_orders {
  order_id varchar(20) [primary key]
  service_date date [not null]
  hours integer [not null]
  client_id integer [ref: > riwi_clients.client_id]
  branch_id integer [ref: > riwi_branches.branch_id]
  technician_id integer [ref: > riwi_technicians.technician_id]
  equipment_id integer [ref: > riwi_equipment.equipment_id]
  service_type_id integer [ref: > riwi_service_types.service_type_id]
}



# Database Creation Instructions

To build the database schema in your local PostgreSQL instance, execute the following SQL scripts in order. Master tables are created first to ensure that foreign key constraints can be successfully bound.


1. Create Master Tables with no dependencies

CREATE TABLE riwi_cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE riwi_clients (
    client_id SERIAL PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL
);

CREATE TABLE riwi_technicians (
    technician_id SERIAL PRIMARY KEY,
    technician_name VARCHAR(100) NOT NULL
);

CREATE TABLE riwi_equipment_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE riwi_service_types (
    service_type_id SERIAL PRIMARY KEY,
    service_type_name VARCHAR(50) UNIQUE NOT NULL
);

2. Create Master Tables with dependencies
CREATE TABLE riwi_branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city_id INT REFERENCES riwi_cities(city_id) ON DELETE RESTRICT
);

CREATE TABLE riwi_equipment (
    equipment_id SERIAL PRIMARY KEY,
    equipment_name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES riwi_equipment_categories(category_id) ON DELETE RESTRICT
);

3. Create Transactional Table
CREATE TABLE riwi_work_orders (
    order_id VARCHAR(20) PRIMARY KEY,
    service_date DATE NOT NULL,
    hours INT NOT NULL,
    client_id INT REFERENCES riwi_clients(client_id) ON DELETE RESTRICT,
    branch_id INT REFERENCES riwi_branches(branch_id) ON DELETE RESTRICT,
    technician_id INT REFERENCES riwi_technicians(technician_id) ON DELETE RESTRICT,
    equipment_id INT REFERENCES riwi_equipment(equipment_id) ON DELETE RESTRICT,
    service_type_id INT REFERENCES riwi_service_types(service_type_id) ON DELETE RESTRICT
);


#Data Loading Instructions

To populate the database without triggering constraint violations, you must load data into the independent master catalogs before inserting records into the main transactional log.

## Step 1: Populate Independent Catalog Tables

INSERT INTO riwi_city (city_name) VALUES ('Medellín'), ('Bogotá');
INSERT INTO riwi_clients (client_name) VALUES ('Acme Corp'), ('Globex Industries');
INSERT INTO riwi_technicians (technician_name) VALUES ('John Doe'), ('Jane Smith');
INSERT INTO riwi_equipment_categories (category_name) VALUES ('Heavy Machinery'), ('IT Infrastructure');
INSERT INTO riwi_service_types (service_type_name) VALUES ('Preventive Maintenance'), ('Emergency Repair');


## Step 2: Populate Dependent Catalog Tables

INSERT INTO riwi_branches (branch_name, city_id) VALUES ('Poblado HQ', 1), ('North Branch', 2);
INSERT INTO riwi_equipment (equipment_name, category_id) VALUES ('Hydraulic Press X1', 1), ('Server Blade Rack', 2);


## Step 3: Populate the Transactional Log Table

INSERT INTO riwi_work_orders (order_id, service_date, hours, client_id, branch_id, technician_id, equipment_id, service_type_id) 
VALUES ('WO-2026-001', '2026-03-15', 5, 1, 1, 1, 1, 1);


## Explanation of Each SQL Query



##Query 1: Fetch Full Work Order Details

* **SQL Code**:
 
  SELECT wo.order_id, wo.service_date, cl.client_name, br.branch_name, ci.city_name, tech.technician_name, eq.equipment_name, st.service_type_name, wo.hours
  FROM riwi_work_orders wo
  JOIN riwi_clients cl ON wo.client_id = cl.client_id
  JOIN riwi_branches br ON wo.branch_id = br.branch_id
  JOIN riwi_cities ci ON br.city_id = ci.city_id
  JOIN riwi_technicians tech ON wo.technician_id = tech.technician_id
  JOIN riwi_equipment eq ON wo.equipment_id = eq.equipment_id
  JOIN riwi_service_types st ON wo.service_type_id = st.service_type_id;
  ```
* Explanation: This query flattens the normalized model back into a human-readable format. It utilizes `INNER JOIN` operations to reconstruct the relationship chain from the core order down to the exact branch and its corresponding geographic city location.

### Query 2: Aggregate Total Hours Spent per Technician

* **SQL Code**:
 
  SELECT tech.technician_name, SUM(wo.hours) as total_hours
  FROM riwi_work_orders wo
  JOIN riwi_technicians tech ON wo.technician_id = tech.technician_id
  GROUP BY tech.technician_name
  ORDER BY total_hours DESC;
  

