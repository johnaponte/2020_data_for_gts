# 2020_data_for_gts
Compilation of data for the GTS update

This proyects uses a YAML configuration file

```yaml
default:
  dirs:
    data: _data
    functions: _functions
    handmade: handmade
    database: database
    reports: reports
    logs: logs
  clean_before_new_analysis:
    - database
    - reports
    - logs
  defaultdb:
    package: RSQLite
    dbconnect: SQLite
    dbname: database/data_for_gts.db
  mapdb:
    package: RSQLite
    dbconnect: SQLite
    dbname: /Users/apontej/development/gmpsur_reference/work/year2019/desarrollo/r/wmr2019_csb/database/csb_results.db
    

```