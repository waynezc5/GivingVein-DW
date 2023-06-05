# GivingVein-DW

This repository contains the design and T-SQL implementation and ETL for a data warehouse from an OLTP database that manages the blood donations and donors of a fictitious non-profit organization. That project can be found here ![GivingVein-OLTP](https://github.com/waynezc5/GivingVein-OLTP).

The warehouse contains 2 data marts. The first is specific to donations and the second is for lab orders.

## Data Warehouse Design
The star schema is represented in the following diagrams:

Donations Star Schema
![Donations Diagram](https://github.com/waynezc5/GivingVein-DW/blob/main/GivingVein%20Dimensional%20Modeling%20-%20Donations%20Diagram.jpeg)

Lab Orders Star Schema
![Lab Orders Diagram](https://github.com/waynezc5/GivingVein-DW/blob/main/GivingVein%20Dimensional%20Modeling%20-%20Orders%20Diagram.jpeg)

## Files Included

### GivingVeinDW.sql
The T-SQL statements to create the tables and constraints necessary to build the warehouse infrastructure.

### GivingVeinDW_ETL_SP.sql
Contains the T-SQL stored procedures to pull the data from the GivingVein OLTP and load into the data warehouse for consumption and report building.

### GivingVeinDW.bak
Full backup file of the data warehouse with the data from the OLTP loaded.

## Usage
To use the GivingVeinDW database, either run the GivingVeinDW.sql and the GivingVeinDW ETL SP.sql on the same instance as the GivingVein OLTP against a SQL Server instance or simply restore the backup file.

