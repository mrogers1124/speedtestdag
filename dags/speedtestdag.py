from datetime import datetime, timedelta
import json
import os
import logging
import sqlite3

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.models import Variable


logger = logging.getLogger(__name__)
speedtest_config = Variable.get(key="speedtest_config", deserialize_json=True)
db_path = speedtest_config["db_path"]


def func_validate_output(**context):
    output_str = context["ti"].xcom_pull(task_ids="run_speedtest")
    output = json.loads(output_str)

    logger.info(f"Validating speedtest output: { output_str }")

    if "type" not in output.keys():
        raise ValueError("Speedtest output type not defined.")

    if output["type"] != "result":
        raise ValueError("Speedtest output type not 'result'.")

    if "result" not in output.keys():
        raise ValueError("Speedtest output result metadata is missing.")

    if "id" not in output["result"].keys():
        raise ValueError("Speedtest result id not defined.")


def func_update_db_ddl():
    ddl_dir = os.path.split(__file__)[0]
    ddl_path = os.path.join(ddl_dir, "db_ddl.sql")
    logger.info(f"Reading DDL from file {ddl_path}")
    with open(ddl_path, "r") as f:
        ddl = f.read()

    con = sqlite3.connect(db_path)
    with con:
        con.executescript(ddl)
    con.close()


def func_save_result_to_db(**context):
    result = context["ti"].xcom_pull(task_ids="run_speedtest")
    id = json.loads(result)["result"]["id"]

    con = sqlite3.connect(db_path)
    with con:
        con.execute("INSERT INTO RAW_RESULTS(ID, RESULT) VALUES(?, ?);", (id, result))
    con.close()


with DAG(
    "speedtestdag",
    default_args={
        "depends_on_past": False,
        "email": ["airflow@example.com"],
        "email_on_failure": False,
        "email_on_retry": False,
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
    description="A DAG for automating Ookla Speedtest runs",
    schedule="@hourly",
    start_date=datetime(2023, 1, 1),
    catchup=False,
) as dag:

    start_dag = EmptyOperator(
        task_id="start_dag",
    )

    run_speedtest = BashOperator(
        task_id="run_speedtest",
        bash_command="speedtest -f json",
    )

    validate_output = PythonOperator(
        task_id="validate_output",
        python_callable=func_validate_output,
        provide_context=True,
    )

    update_db_ddl = PythonOperator(
        task_id="update_db_ddl",
        python_callable=func_update_db_ddl,
    )

    save_result_to_db = PythonOperator(
        task_id="save_result_to_db",
        python_callable=func_save_result_to_db,
        provide_context=True,
    )

    finish_dag = EmptyOperator(
        task_id="finish_dag",
    )

    start_dag >> run_speedtest >> validate_output
    start_dag >> update_db_ddl
    [validate_output, update_db_ddl] >> save_result_to_db >> finish_dag
