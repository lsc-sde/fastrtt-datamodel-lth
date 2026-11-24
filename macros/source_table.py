from sqlglot import exp
from sqlmesh import macro
from sqlmesh.core.macros import MacroEvaluator


@macro()
def source_table(
    evaluator: MacroEvaluator, prefix: exp.Expression, table: exp.Expression
) -> exp.Table:
    """Build a table reference from a dotted prefix held in a project variable.

    `@db_mpi.some_table` would quote a dotted value such as
    `LTHDATASCIENCE.dbt_omop.prod` as one identifier. Parsing the whole name
    keeps each part separate, so 3-part and 4-part (linked server) names work.

    Usage: FROM @source_table(@db_mpi, 'stg__master_patient_index')
           FROM @source_table(@db_ptl, 'dbo.incomplete_ptl')
    """
    value = prefix.name if isinstance(prefix, exp.Expression) else str(prefix or "")
    if not value or value.upper() == "NULL":
        raise ValueError(
            "source_table: the prefix variable is not set (see sample.env)"
        )
    return exp.to_table(f"{value}.{table.name}", dialect="tsql")


@macro()
def collate_db_default(
    evaluator: MacroEvaluator, expression: exp.Expression
) -> exp.Expression:
    """`expression COLLATE DATABASE_DEFAULT` on SQL Server, unchanged elsewhere.

    Needed when joining text across databases with different collations (the
    PTL lives in 18_Weeks). Other engines, such as the duckdb used by
    `sqlmesh test`, have no DATABASE_DEFAULT collation.
    """
    adapter = evaluator.engine_adapter if evaluator.runtime_stage != "loading" else None
    if adapter is not None and adapter.dialect != "tsql":
        return expression
    return exp.Collate(this=expression, expression=exp.var("DATABASE_DEFAULT"))
