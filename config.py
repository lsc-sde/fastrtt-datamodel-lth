import os
from datetime import datetime
from typing import Any, Dict

from dotenv import find_dotenv, load_dotenv
from pydantic import BaseModel, ConfigDict
from sqlmesh.core.config import (
    Config,
    GatewayConfig,
    ModelDefaultsConfig,
    MSSQLConnectionConfig,
)
from sqlmesh.core.config.format import FormatConfig
from sqlmesh.core.config.ui import UIConfig
from sqlmesh.core.model import ModelKindName

load_dotenv(find_dotenv(), override=True)

###############################################################################
# SQLMESH CONFIGURATION
###############################################################################

default_gateway: str = "mssql"
start_date: datetime = datetime.fromisoformat(
    os.getenv("START_DATE", "2024-01-01 00:00:00")
)

gateways = {}

# Setup gateways

# MSSQL

gateway_mssql = GatewayConfig(
    connection=MSSQLConnectionConfig(
        host=os.environ["MSSQL_HOST"],
        database=os.environ["MSSQL_DATABASE"],
        concurrent_tasks=os.getenv("MSSQL_CONCURRENT_TASKS", default=4),
    ),
    state_connection=MSSQLConnectionConfig(
        host=os.environ["MSSQL_STATE_HOST"],
        database=os.environ["MSSQL_STATE_DATABASE"],
    ),
    state_schema=os.environ["STATE_SCHEMA"],
)

gateways["mssql"] = gateway_mssql


class SQLMeshSettings(BaseModel):
    """
    SQLMeshSettings class represents the settings for SQLMesh.

    Attributes:
        project (str): The name of the project.
        model_defaults (ModelDefaultsConfig): The configuration for model defaults.
        gateways (dict): A dictionary of gateways, where the keys are the gateway names and the values are the corresponding gateway functions.
        default_gateway (str): The name of the default gateway.
        variables (dict): A dictionary of variables.
        format (FormatConfig): The configuration for formatting.
    """

    model_config = ConfigDict(protected_namespaces=())

    project: str
    model_defaults: ModelDefaultsConfig = ModelDefaultsConfig(
        kind=ModelKindName.VIEW,
        dialect="tsql,normalization_strategy=case_sensitive",
        cron="@daily",
        owner="LTH DST",
        start=start_date,
    )
    gateways: Dict[str, GatewayConfig] = gateways
    default_gateway: str = default_gateway
    variables: Dict[str, Any]
    format: FormatConfig = FormatConfig(
        append_newline=True,
        normalize=True,
        indent=2,
        normalize_functions="lower",
        leading_comma=False,
        max_text_width=80,
        no_rewrite_casts=False,
    )
    ui: UIConfig = UIConfig(format_on_save=False)


variables = {
    "db_ptl": os.getenv("DB_PTL"),
    "db_toucan": os.getenv("DB_TOUCAN"),
    "db_alma": os.getenv("DB_ALMA"),
    "db_documentviewer": os.getenv("DB_DOCUMENTVIEWER"),
}

# Statements to execute before and after running SQLMesh
before_all = [
    "@before_all()",
]

after_all = [
    "@after_all()",
]

config = Config(
    **dict(SQLMeshSettings(project="fastrtt-lth", variables=variables)),
    before_all=before_all,
    after_all=after_all,
)
