MODEL (
  name pathways.rxn__incomplete_ptl,
  kind FULL,
  cron '@daily',
  grain pathway_id,
  audits (
    not_null_non_blocking(columns := (pathway_id)),
    unique_values_non_blocking(columns := (pathway_id))
  ),
  column_descriptions (
    person_id = 'OMOP person_id, matched on MRN through pathways.master_patient_index (current records only). NULL when the MRN has no match or matches more than one person; see person_match_status.',
    person_match_status = 'matched, no_match (MRN not in the MPI) or ambiguous (MRN maps to more than one person_id).'
  )
);

/* MRNs that map to exactly one current person. An MRN mapped to more than one
   person_id is left unlinked rather than guessed. */
WITH mpi AS (
  SELECT
    mpi.flex_mrn,
    min(mpi.person_id) AS person_id,
    count(DISTINCT mpi.person_id) AS person_count
  FROM pathways.master_patient_index AS mpi
  WHERE
    mpi.current_record = 1
  GROUP BY
    mpi.flex_mrn
)
SELECT
  ptl.organisation_code::VARCHAR(3) AS org_code,
  ptl.pathway_type::VARCHAR(9) AS pathway_type,
  ptl.pathway_id::VARCHAR(24) AS pathway_id,
  ptl.visit_number::VARCHAR(20) AS visit_number,
  ptl.mrn::VARCHAR(20) AS mrn,
  CASE WHEN mpi.person_count = 1 THEN mpi.person_id END::BIGINT AS person_id,
  CASE
    WHEN mpi.flex_mrn IS NULL
    THEN 'no_match'
    WHEN mpi.person_count > 1
    THEN 'ambiguous'
    ELSE 'matched'
  END::VARCHAR(10) AS person_match_status,
  ptl.name::VARCHAR(100) AS patient_name,
  ptl.rtt_last_status::VARCHAR(100) AS rtt_last_status,
  ptl.specialty::VARCHAR(50) AS specialty,
  ptl.consultant::VARCHAR(50) AS consultant,
  ptl.rtt_start_date::DATE AS rtt_start_date,
  ptl.wait AS wait_days_source,
  datediff(DAY, ptl.rtt_start_date::DATETIME2, getdate()::DATETIME2) AS wait_in_days,
  ptl.tci_date::DATE AS tci_date,
  ptl.first_appt_date::DATE AS first_appt_date,
  ptl.extract_date::DATE AS extract_date
FROM pathways.src_rtt__incomplete_ptl AS ptl
LEFT JOIN mpi
  ON mpi.flex_mrn = @collate_db_default(ltrim(rtrim(ptl.mrn)))
