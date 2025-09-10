# CoreDataEngineers Linux Git Assignment

This repository contains the complete solution for the CoreDataEngineers Data Engineering assignment. As a new Data Engineer, this project demonstrates proficiency in Linux system administration, bash scripting, database management, and version control using Git.

## Project Structure

```
cde_linux_git_assignment/
├── scripts/
│   ├── bash/
│   │   ├── etl.sh                    # Main ETL pipeline script
│   │   ├── move_csv_json.sh          # File movement utility
│   │   ├── create_dummy_csv_json.sh  # Test data generator
│   │   └── load_postgres.sh          # PostgreSQL data loader
│   └── sql/
│       └── posey.sql                 # Business intelligence queries
├── raw/                              # Raw data storage (ETL extract phase)
├── transformed/                      # Processed data (ETL transform phase)
├── gold/                             # Final data layer (ETL load phase)
├── test_data/                        # Test files for CSV/JSON operations
├── posey_data/                       # Parch & Posey dataset
└── README.md                         # This documentation file
```

## Assignment Solutions

### 1. ETL Pipeline (`scripts/bash/etl.sh`)

**Objective:** Build a bash script that performs Extract, Transform, Load operations on enterprise survey data.

**Features:**

- **Extract:** Downloads CSV data from New Zealand Statistics website using environment variables
- **Transform:** Renames `Variable_code` to `variable_code` and selects specific columns (`year`, `Value`, `Units`, `variable_code`)
- **Load:** Saves final dataset to `gold` directory
- **Error Handling:** Implements `set -euo pipefail` for robust error management
- **Dependencies:** Automatically installs Miller tool for CSV processing
- **Verification:** Confirms successful completion of each phase

**Usage:**

```bash
chmod +x scripts/bash/etl.sh
./scripts/bash/etl.sh
```

**Environment Variables:**

```bash
CSV_URL: Source URL for the enterprise survey data
```

---

### 2. Cron Job Scheduling

The ETL script is scheduled to run daily at 12:00 AM using cron jobs:

```bash
crontab -e
```

Add this line:

```
0 0 * * * /path/to/your/project/scripts/bash/etl.sh >> /var/log/etl_job.log 2>&1
```

**Cron Expression Breakdown:**

- `0 0 * * *`: Minute=0, Hour=0, Day=any, Month=any, Weekday=any
- Logs output to `/var/log/etl_job.log` for monitoring

---

### 3. File Management Utility (`scripts/bash/move_csv_json.sh`)

**Objective:** Move all CSV and JSON files from source to destination directory.

**Features:**

- Accepts command-line arguments for source and destination directories
- Creates destination directory if it doesn't exist
- Handles cases where no files are found
- Provides feedback on number of files moved
- Supports both CSV and JSON file types

**Usage:**

```bash
# Using default directories
./scripts/bash/move_csv_json.sh

# Using custom directories
./scripts/bash/move_csv_json.sh /source/path /destination/path
```

**Test Data Generator (`scripts/bash/create_dummy_csv_json.sh`):**

```bash
./scripts/bash/create_dummy_csv_json.sh
```

---

### 4. Parch & Posey Database Analysis

#### Database Setup (`scripts/bash/load_postgres.sh`)

**Objective:** Load Parch & Posey CSV files into PostgreSQL database for analysis.

**Features:**

- Creates `posey` database if it doesn't exist
- Defines proper schemas for each table (`accounts`, `orders`, `region`, `sales_reps`, `web_events`)
- Implements DROP and CREATE table logic for clean reloads
- Uses PostgreSQL `COPY` command for efficient data loading
- Handles multiple CSV files automatically

**Prerequisites:**

```bash
# Ensure PostgreSQL is installed and running
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create postgres user if needed
sudo -u postgres createuser --superuser $USER
```

**Usage:**

```bash
./scripts/bash/load_postgres.sh
```

#### Business Intelligence Queries (`scripts/sql/posey.sql`)

**Query Solutions:**

- **High Volume Orders:** Identifies orders with `gloss_qty` or `poster_qty > 4000`

```sql
SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;
```

- **Special Order Patterns:** Finds orders with zero `standard_qty` but high gloss/poster quantities

```sql
SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);
```

- **Customer Segmentation:** Locates companies starting with 'C' or 'W' with specific contact patterns

```sql
SELECT company_name
FROM companies
WHERE (company_name LIKE 'C%' OR company_name LIKE 'W%')
  AND (primary_contact ILIKE '%ana%' AND primary_contact NOT ILIKE '%eana%');
```

- **Sales Territory Analysis:** Provides comprehensive view of regions, sales reps, and their accounts

```sql
SELECT regions.region_name, sales_reps.name AS sales_rep_name, accounts.name AS account_name
FROM regions
JOIN sales_reps ON regions.id = sales_reps.region_id
JOIN accounts ON sales_reps.id = accounts.sales_rep_id
ORDER BY account_name;
```

**Execute Queries:**

```bash
psql -U postgres -d posey -f scripts/sql/posey.sql
```

---

## ETL Pipeline Architecture

![Alt text](/pipeline-architecture.png)

---

## Technical Implementation Details

**Dependencies**

- Linux Operating System (Ubuntu/Debian preferred)
- Bash 4.0+
- PostgreSQL 12+
- curl
- Miller (mlr) - for CSV processing

**Installation Commands:**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y
```

---

## Error Handling & Logging

All scripts implement:

- `set -euo pipefail` for strict error handling
- File existence validation
- Process confirmation messages
- Exit codes for automation integration

---

## Security Considerations

- Uses environment variables for sensitive URLs
- Implements proper file permissions
- Follows principle of least privilege
- Validates input directories before operations

---

## Testing & Validation

### ETL Pipeline Testing

```bash
./scripts/bash/etl.sh

# Check if files exist in correct locations
ls -la raw/ transformed/ gold/

# Validate data transformation
head -5 transformed/2023_year_finance.csv
```

### Database Testing

```bash
# Verify database creation
psql -U postgres -l | grep posey

# Check table creation
psql -U postgres -d posey -c "\dt"

# Validate data loading
psql -U postgres -d posey -c "SELECT COUNT(*) FROM orders;"
```

### File Operations Testing

```bash
# Create test data
./scripts/bash/create_dummy_csv_json.sh

# Test file movement
./scripts/bash/move_csv_json.sh

# Verify results
ls -la test_data/json_and_csv/
```
