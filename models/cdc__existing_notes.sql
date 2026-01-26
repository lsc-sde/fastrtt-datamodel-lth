MODEL (
  name fastrtt.cdc__existing_note,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key (org_code, source_system, source_id)
  )
);

SELECT DISTINCT
  org_code::VARCHAR(3),
  source_system::VARCHAR(20),
  source_id::VARCHAR(100)
FROM fastrtt.rxn__document
