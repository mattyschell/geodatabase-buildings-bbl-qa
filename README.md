# geodatabase-buildings-bbl-qa

When [geodatabase-buildings](https://github.com/mattyschell/geodatabase-buildings) base_bbls (borough-block-lots) have no spatial relationship to the Dept. of Finance tax lot with matching bbl, this can indicate one of several conditions. We will distinguish between these and correct (when necessary) using this periodic QA.

1. The tax lot changed after the most recent building edit.

    We will report these and an editor will update the building base_bbl value.

2. The building base_bbl is incorrect.

    We will report these and an editor will update the building base_bbl value.

3. The Dept. of Finance tax lots are not spatially accurate.

    We will track these so that they are reported by QA only once, and potentially send these to the Dept. of Finance. for attention.

4. The building is not in a tax lot at all - easements, outside city limits, etc.

    We will track these so that they are reported by QA only once and then never look at them again. We will always ignore buildings outside of city limits or on the boundary but not touching a tax lot.

    Some building base_bbls have no matching tax lot because they are spatially located outside of taxable lots, like on subway lines or on bridges.  We will never identify these in QA but we may add some of these "pseudo" bbls to the same "acknowledged" list as we encounter them in QA.

# Dependencies

* SQLPlus and credentials to an Oracle schema with buildings
* When running the full scripted QA, also 
    * Source tax (REST service or ESRI Enterprise Geodatabase) lots from Dept of Finance
    * [geodatabase-toiler](https://github.com/mattyschell/geodatabase-toiler) on PYTHONPATH

# Steps - Start to Finish

### 1. Import Dept. of Finance tax_lot_polygon geometries and borough boundaries into the building schema.  

There's an aggregated borough boundary in the data directory of this repository. 

### 2. Run the QA 

```bat
sqlplus schemaname/iluvesri247@databasename @run.sql
```
    output: bbl-qa.csv

### 3. Helper: Refresh bbl-dab-history.csv

Execute somewhere with read-only access to the taxmap digital alteration book. We use this csv for reference in the review. 

```bat
sqlplus taxreadonly/iluvesri247@databasename @run-dab.sql
```
    output: bbl-dab-history.csv

Commit bbl-dab-history.csv to Github for helpful csv filtering.


### 4. Fix any that are category 1 or 2

### 5. Add any acknowledged in category 3 or 4 to bbl-qa-ack.csv

### 6. Reload acknowledged data and re-run the QA 

```shell
./bbl-qa-writeack.sh
```

```bat
sqlplus schemaname/iluvesri247@databasename @run.sql
```
    output: bbl-qa.csv 

Output bbl-qa.csv will be empty if all IDs were fixed or acknowledged

### 7. Commit the latest bbl-qa-ack.csv to this repo

# Steps - Automate a periodic QA

Copy buildings-bbl-qa-sample.bat to buildings-bbl-qa.bat.  Update the environmentals at the top of the script.


```bat
buildings-bbl-qa.bat
```

output: An email with the QA results. 

