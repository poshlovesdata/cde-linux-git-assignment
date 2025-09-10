#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# script: load_posey_data.sh
# purpose: create database 'posey' if needed
#          drop + recreate tables, then load
#          parch & posey csv files
# ==========================================

CSV_DIR="$HOME/Documents/cde_linux_git_assignment/posey_data"
DB_NAME="posey"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

# check if database exists, else create
if ! psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "database $DB_NAME does not exist. creating..."
    createdb -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" "$DB_NAME"
else
    echo "database $DB_NAME already exists."
fi

# function to load csv into postgres
load_csv() {
    local file_path=$1
    local table_name
    table_name=$(basename "$file_path" .csv)

    echo "processing $file_path..."

    # define schema for each table
    local create_table_sql
    case "$table_name" in
        accounts)
            create_table_sql="DROP TABLE IF EXISTS accounts;
            CREATE TABLE accounts (
                id INT PRIMARY KEY,
                name VARCHAR(100),
                website VARCHAR(255),
                lat FLOAT,
                long FLOAT,
                primary_poc VARCHAR(100),
                sales_rep_id INT
            );"
            ;;
        orders)
            create_table_sql="DROP TABLE IF EXISTS orders;
            CREATE TABLE orders (
                id INT PRIMARY KEY,
                account_id INT,
                occurred_at TIMESTAMP,
                standard_qty INT,
                gloss_qty INT,
                poster_qty INT,
                total INT,
                standard_amt_usd DECIMAL,
                gloss_amt_usd DECIMAL,
                poster_amt_usd DECIMAL,
                total_amt_usd DECIMAL
            );"
            ;;
        region)
            create_table_sql="DROP TABLE IF EXISTS region;
            CREATE TABLE region (
                id INT PRIMARY KEY,
                name VARCHAR(100)
            );"
            ;;
        sales_reps)
            create_table_sql="DROP TABLE IF EXISTS sales_reps;
            CREATE TABLE sales_reps (
                id INT PRIMARY KEY,
                name VARCHAR(100),
                region_id INT
            );"
            ;;
        web_events)
            create_table_sql="DROP TABLE IF EXISTS web_events;
            CREATE TABLE web_events (
                id INT PRIMARY KEY,
                account_id INT,
                occurred_at TIMESTAMP,
                channel VARCHAR(50)
            );"
            ;;
        *)
            echo "no schema defined for $table_name, skipping..."
            return 1
            ;;
    esac

    # drop + create table
    psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "$create_table_sql"

    # load data
    psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "\COPY $table_name FROM '$file_path' DELIMITER ',' CSV HEADER;"

    echo "successfully loaded $file_path into $table_name"
}

# check for csv files
shopt -s nullglob
csv_files=("$CSV_DIR"/*.csv)

if [ ${#csv_files[@]} -eq 0 ]; then
    echo "no csv files found in $CSV_DIR"
    exit 1
fi

# load all csv files
for csv_file in "${csv_files[@]}"; do
    load_csv "$csv_file"
done

echo "all csv files processed."
