# speedtestdag

A simple Airflow DAG for automating Ookla Speedtest runs.

## Use Case

As a subscriber of residential internet service through a regional ISP,
I want to automate measurements of my internet connection speed
so that I can compare the actual service to what the ISP has agreed to provide.

## Dependencies

* Apache Airflow, available via PyPI: `pip install apache-airflow`
* Ookla Speetest CLI, available here: https://www.speedtest.net/apps/cli

The Airflow user must be able to run the bash command `speedtest -f json`.

## Airflow Configuration

Copy the files `speedtestdag.py` and `db_ddl.sql` to the Airflow dags folder.

Add an Airflow variable with key `speedtest_config` and value
```
{"db_path": "/path/to/sqlite_file"}
```
where the path refers to the SQLite database file.
The Airflow user must have write access to this location.

## Database Specification

If the SQLite database file does not exist, it will be created when the DAG runs.

The table `RAW_RESULTS` contains results in JSON format.

The view `V_RESULTS` presents the results in tabular format.
The definition of this view is refreshed with each DAG run.

## License

MIT license. See LICENSE file for details.