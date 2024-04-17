
# Importing Datasets in Stata

## Introduction

Stata supports numerous data formats including `.dta`, `.csv`, `.xls/.xlsx` (Excel), `.sav` (SPSS), `.sas7bdat` (SAS), `.dbf` (dBase), and more. The graphical interface may be used to import data at `Menu > File > Import > Text data (delimited, *.csv)`, but only for local files. It's advised that you archive the commands Stata outputs onto the results window for your future `.do` files. Your next project may include remote data, for which only a ready `.do` file script will work.


## 1. Importing CSV Files

- **Syntax**: `import delimited`
- **Example**: 
  ```
  import delimited data.csv, clear
  ```

## 2. Importing Excel Files

- **Syntax**: `import excel`
- **Example**:
  ```
  import excel using data.xlsx, firstrow clear
  ```

## 3. Importing SPSS Files

- **Syntax**: `import spss`
- **Example**:
  ```
  import spss using data.sav, clear
  ```

## 4. Importing SAS Files

- **Syntax**: `import sas`
- **Example**:
  ```
  import sas using data.sas7bdat, clear
  ```

## 5. Importing dBase Files

- **Syntax**: `import dbase`
- **Example**:
  ```
  import dbase using data.dbf, clear
  ```

## 6. Importing Text Data in Fixed Format

- **Syntax**: `import fixed`
- **Example**:
  ```
  import fixed using data.txt, clear
  ```

## 7. Importing Text Data in Fixed Format with a Dictionary

- **Syntax**: `infix using`
- **Example**:
  ```
  infix using dictionary.dct
  ```
  A dictionary file (`dictionary.dct`) specifies the format of your fixed-width file.

## 8. Importing Unformatted Text Data

- **Syntax**: `import delimited`
- **Example**:
  ```
  import delimited data.txt, clear
  ```

## 9. Importing SAS XPORT Files

- **Syntax**: `import xport`
- **Example**:
  ```
  import delimited data.xpt, clear
  ```
  For `.v8xpt` and `.xpt` files, the command remains the same.

   - Visit the [CDC.gov](https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Demographics&CycleBeginYear=1999) website to practice importing a .XPT file:
      - [DEMO](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT) Data from the 2009 survey
      - Use `set timeout 1000` if you have poor internet connectivity

## 10. Importing Data from JDBC Data Sources

- **Syntax**: `jdbc`
- **Example**:
  ```
  jdbc query "SELECT * FROM database.table" , dsn("jdbc:datasourceURL") javaoptions("option1" "option2")
  ```
  Requires setting up a JDBC connection and may involve additional options for Java.

## 11. Importing Data from ODBC Data Sources

- **Syntax**: `odbc load`
- **Example**:
  ```
  odbc load, dsn("DSNname") table("tablename") clear
  ```
  Utilizes an ODBC connection, where `DSNname` is the Data Source Name.

## 12. Importing Data from FRED

- **Syntax**: `import fred`
- **Example**:
  ```
  import fred seriesID, clear
  ```
  Directly imports economic data from the Federal Reserve Economic Data (FRED).

## Tips for Importing Data

1. **Backup your raw data** before starting any analysis.
2. **Inspect your data post-import** using `describe`, `list`, and `summarize`.
3. **Be alert for import errors**; Stata provides helpful error messages to guide troubleshooting.

