# geodatabase-buildings-bbl-qa

When [geodatabase-buildings](https://github.com/mattyschell/geodatabase-buildings) base_bbls (borough-block-lots) have no spatial relationship to the Dept. of Finance tax lot with matching bbl, this can indicate one of several conditions. We will distinguish between these and correct (when necessary) using this periodic QA.

1. The tax lot changed after the most recent building edit.

    We will report these and an editor will update the building base_bbl value.

2. The building base_bbl is incorrect.

    We will report these and an editor will update the building base_bbl value.

3. The Dept. of Finance tax lots are not spatially accurate.

    We will track these so that they are reported by QA only once, and potentially 
    send these to the Dept. of Finance. for attention.

4. The building is not in a tax lot at all - easements, outside city limits, etc.

    We will track these so that they are reported by QA only once and then never
    look at them again.

# Dependencies

* SQLPlus and credentials to an Oracle schema with buildings

# Steps

### 1. Import Dept. of Finance tax_lot_polygon geometries into the building schema.  

Consider running in development or staging with imported buildings, limiting our churn though add and delete tables.

### 2. Run the QA 

```bat
sqlplus schemaname/iluvesri247@databasename @run.sql
```
    output: bbl-qa.csv

### 3. Refresh bbl-dab-history.csv

Execute somewhere with read-only access to the taxmap digital alteration book. 

```bat
sqlplus taxreadonly/iluvesri247@databasename @run-dab.sql
```
    output: bbl-dab-history.csv


### 4. Fix any that are category 1 or 2

### 5. Add any acknowledged in category 3 or 4 to bbl-qa-ack.csv

### 6. Reload acknowledged data and re-run the QA 

```shell
./bbl-qa-writeack.sh
```

```bat
sqlplus schemaname/iluvesri247@databasename @run.sql
```
    output: Should be empty bbl-qa.csv 

### 7. Commit the latest bbl-qa-ack.csv to this repo

