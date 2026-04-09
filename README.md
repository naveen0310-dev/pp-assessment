# Data Analyst Assignment

This repository contains my solutions to the Data Analyst Assignment, organized exactly into three distinct phases as requested.

## Project Structure

- `SQL/` : Contains the DDL (Data Definition Language) and DML (Data Manipulation Language) queries corresponding to Phase 1.
  - `01_Hotel_Schema_Setup.sql`: Tables creation and sample record insertion for the Hotel Management system.
  - `02_Hotel_Queries.sql`: Responses to the 5 business questions for the Hotel Management system.
  - `03_Clinic_Schema_Setup.sql`: Tables creation and sample record insertion for the Clinic Management system.
  - `04_Clinic_Queries.sql`: Responses to the 5 business questions for the Clinic Management system.
- `Spreadsheets/` : Contains the Excel files corresponding to Phase 2.
  - `Ticket_Analysis.xlsx`: Contains the `ticket` and `feedbacks` sheets along with VLOOKUP/INDEX-MATCH formulas.
- `Python/` : Contains scripts corresponding to Phase 3.
  - `01_Time_Converter.py`: Converts raw minutes integer to hours and remaining minutes format.
  - `02_Remove_Duplicates.py`: Removes sequential duplicate characters out of strings using loop.

## Notes & Assumptions
- The SQL dialect targeted is globally compliant (like PostgreSQL, MySQL) adopting standards such as `EXTRACT(MONTH FROM date)`. 
- Since the Excel portion was created programmatically, if you open `Ticket_Analysis.xlsx` you might need to enable editing/viewing formulas to dynamically see the loaded results.
- Sample inputs for Python tests are provided within the `if __name__ == "__main__":` blocks inside the python scripts and can be ran directly.
