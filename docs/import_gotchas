# Import Notes (SSMS Import/Export Wizard)

Issues I ran into while loading the Olist CSVs into SQL Server, and how I fixed them.

## 1. Nullable datetime columns
- **Problem:** Empty timestamps in the orders table caused import errors.
- **Fix:** Set **On Error = Ignore** in the wizard so those values load as NULL.

## 2. Misspelled column names
- **Problem:** The source file has `product_name_lenght` and `product_description_lenght` (typo in "length"), which didn't match my table columns.
- **Fix:** Map the columns manually in the wizard's **Advanced** tab.

## 3. Truncated review text
- **Problem:** Long review comments were cut off during import.
- **Fix:** Increase the column width for the review text columns in the **Advanced** tab.

## 4. Category translation table
- **Problem:** Code page conflict when importing the translation file.
- **Fix:** Use **DT_WSTR** (Unicode string) as the data type.

## 5. Duplicate rows in geolocation
- **Problem:** The geolocation file has many duplicate rows, so a primary key could not be applied.
- **Fix:** Load into a staging table first, then remove duplicates with `ROW_NUMBER()` before moving the data into the final table.

## 6. Encoding corruption (UTF-8 read as Latin-1)
- **Problem:** City and state names in geolocation showed garbled characters (e.g. accented letters broken). This did not show up in basic data checks and was only noticed when I looked at the characters themselves.
- **Fix:** Re-import with **Code Page 65001 (UTF-8)** into an **NVARCHAR staging table with no primary key**, then clean and move the data across.

## Schema decisions
- Composite primary keys for `order_items`, `payments`, and `reviews`, since each row is identified by more than one column.
- `CHAR(32)` for the hashed IDs (fixed-length MD5).
- `DECIMAL` for money columns, `INT` for zip codes.

## Lesson
Always spot-check text columns for odd characters right after import. Encoding problems are silent and affect the whole dataset.
