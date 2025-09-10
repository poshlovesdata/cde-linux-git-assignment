#!/usr/bin/env bash

# ETL Script (Extract - Transform - Load)
# This script extracts a CSV file from a URL,transforms it by selecting and renaming columns, and loads the final dataset into the gold directory.

# a safety net for when pipeline fails
set -euo pipefail

# install dependencies
echo "Installing dependencies..."
sudo apt install miller # for handling the commas in csv columns


# env variables
export CSV_URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"

# File paths
RAW_FILE="raw/data.csv"
TRANSFORMED_FILE="transformed/2023_year_finance.csv"
GOLD_FILE="gold/2023_year_finance.csv"

# Extract phase
echo "Extracting data..."
mkdir -p raw # esnure raw/ folder exists

# download the csv save to raw folder
curl -sSL "$CSV_URL" -o "$RAW_FILE"

# confirm file was downloaded
if [[ -f "$RAW_FILE" ]]; then
    echo "File downloaded successfully: $RAW_FILE"
else
    echo "Download Failed"
    exit 1
fi

# Transform phase
echo "Transforming data"

mkdir -p transformed # ensure transformed folder exists

# select required columns and rename header Variable_code - variable_code
mlr --csv cut -f Year,Value,Units,Variable_code "$RAW_FILE" \
  | mlr --csv rename Variable_code,variable_code \
  > "$TRANSFORMED_FILE"

# confirm file was transformed
if [[ -f "$TRANSFORMED_FILE" ]]; then
    echo "Transfomation Complete: $TRANSFORMED_FILE created"
    head -5 "$TRANSFORMED_FILE"
else
    echo "Transformation Failed"
    exit 1
fi

# Load Phase
echo "Loading data into gold layer.."
mkdir -p gold # create gold folder 

# copy transformed file into gold folder
cp "$TRANSFORMED_FILE" "$GOLD_FILE"

# confirm file was loaded
if [[ -f "$GOLD_FILE" ]]; then
    echo "File Loaded $GOLD_FILE "
else 
    echo "Load failed"
    exit 1
fi

echo "ETL process completed successfully!"