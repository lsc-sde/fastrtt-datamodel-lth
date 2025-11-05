MODEL (
  name fastrtt.src__patient_list,
  kind FULL,
  cron '@daily',
  grain visit_id
);

SELECT
  type::VARCHAR(15) AS rtt_type,
  pathway_type::VARCHAR(9) AS pathway_type,
  visit_id::BIGINT AS visit_id,
  visit_number::VARCHAR(20) AS visit_number,
  mrn::VARCHAR(20) AS mrn,
  name::VARCHAR(255) AS patient_name,
  rtt_last_status::VARCHAR(255) AS rtt_last_status,
  specialty::VARCHAR(255) AS specialty,
  consultant::VARCHAR(255) AS consultant,
  rtt_start_date::DATE AS rtt_start_date,
  NULL::DATE AS rtt_end_date,
  wait::SMALLINT AS wait_in_days,
  first_appt_date::DATE AS first_appt_date,
  extract_date::DATE AS extract_date
FROM @db_ptl.dbo.incomplete_ptl
