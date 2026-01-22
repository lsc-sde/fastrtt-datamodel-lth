MODEL (
  name fastrtt.cdc__existing_note,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key (org_code, source_system, source_id)
  )
);

SELECT DISTINCT
  org_code::VARCHAR,
  source_system::VARCHAR,
  source_id::VARCHAR
FROM fastrtt.rxn__document
