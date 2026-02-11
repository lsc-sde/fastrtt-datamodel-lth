MODEL (
  name fastrtt.rxn__incomplete_ptl,
  kind FULL,
  cron '@daily',
  grain pathway_id
);

SELECT
  organisation_code::VARCHAR(3) AS org_code,
  pathway_type::VARCHAR(9) AS pathway_type,
  pathway_id::VARCHAR(24) AS pathway_id,
  visit_number::VARCHAR(20) AS visit_number,
  mrn::VARCHAR(20) AS mrn,
  name::VARCHAR(100) AS patient_name,
  rtt_last_status::VARCHAR(100) AS rtt_last_status,
  specialty::VARCHAR(50) AS specialty,
  consultant::VARCHAR(50) AS consultant,
  rtt_start_date::DATE AS rtt_start_date,
  wait AS wait_days_source,
  datediff(DAY, rtt_start_date::DATETIME2, getdate()::DATETIME2) AS wait_in_days,
  tci_date::DATE AS tci_date,
  first_appt_date::DATE AS first_appt_date,
  extract_date::DATE AS extract_date
FROM @db_ptl.dbo.incomplete_ptl
