MODEL (
  name pathways.master_patient_index,
  kind FULL,
  cron '@daily',
  description 'MRN to OMOP person_id lookup, copied from the OMOP master patient index (as shovel does). Only the columns needed to link a PTL pathway to a person are kept.'
);

/* Only the link columns are copied: the MPI also holds NHS numbers and dates
   of birth, which FastRTT does not need. */
SELECT
  ltrim(rtrim(mpi.flex_mrn))::VARCHAR(20) AS flex_mrn,
  mpi.person_id::BIGINT AS person_id,
  mpi.current_record::INT AS current_record
FROM @source_table(@db_mpi, 'stg__master_patient_index') AS mpi
WHERE
  NOT mpi.flex_mrn IS NULL AND NOT mpi.person_id IS NULL
