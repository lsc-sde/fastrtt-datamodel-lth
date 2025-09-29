import typing as t
from datetime import datetime
from io import BytesIO

import pandas as pd
import pypdf
import markitdown
from sqlmesh import ExecutionContext, model


def extract_markitdown(pdf_bytes: bytes) -> str:
    md = markitdown.MarkItDown()
    result = md.convert(BytesIO(pdf_bytes))
    return result.markdown


def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    pdf_reader = pypdf.PdfReader(BytesIO(pdf_bytes))
    text = ""
    # replacements = {
    #     "ï¿½ï¿½": " ",
    # }
    for page in pdf_reader.pages:
        text += (
            page.extract_text(
                extraction_mode="layout", layout_mode_space_vertically=False
            )
            + "\n"
        )
    # text = text.encode().decode("ascii", errors="replace")
    # for old, new in replacements.items():
    #     text = text.replace(old, new)
    return text


@model(
    "fastrtt.pdf2text",
    kind="full",
    columns={
        "note_id": "int",
        "document_text": "varchar(max)",
    },
)
def execute(
    context: ExecutionContext,
    start: datetime,
    end: datetime,
    execution_time: datetime,
    **kwargs: t.Any,
) -> pd.DataFrame:
    """Convert PDF documents to text."""

    db_documentviewer = context.var("db_documentviewer")
    stg__note = context.resolve_table("fastrtt.stg__note")
    df = context.fetchdf(
        f"""
        select
            sn.note_id,
            cd.filestream
        from {stg__note} sn
        join {db_documentviewer}.dbo.clinicdocuments AS cd
        on sn.note_id = cd.pdfdocumentkey
        """
    )

    # df["document_text"] = df["filestream"].apply(extract_text_from_pdf)
    df["document_text"] = df["filestream"].apply(extract_markitdown)
    df = df[["note_id", "document_text"]]
    return df
