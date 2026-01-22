from sqlmesh import macro
from sqlmesh.core.macros import MacroEvaluator


@macro()
def before_all(evaluator: MacroEvaluator) -> list[str]:
    schema = (
        "fastrtt" if evaluator.this_env == "prod" else f"fastrtt__{evaluator.this_env}"
    )

    return [
        f"""BEGIN TRY
                EXEC ('CREATE SCHEMA {schema}')
            END TRY
            BEGIN CATCH
            -- do nothing
            END CATCH;""",
        f"""
        EXEC('
            IF OBJECT_ID(''{schema}.existing_note'', ''U'') IS NULL
            CREATE TABLE {schema}.existing_note
            (
                org_code VARCHAR(3),
                source_system VARCHAR(20),
                source_id VARCHAR(100)
            )
            ');
        """,
    ]


@macro()
def after_all(evaluator: MacroEvaluator):
    schema = (
        "fastrtt" if evaluator.this_env == "prod" else f"fastrtt__{evaluator.this_env}"
    )

    return [
        f"TRUNCATE TABLE {schema}.existing_note;",
        f"""INSERT into {schema}.existing_note
        SELECT * FROM {schema}.cdc__existing_note;
        """,
    ]
