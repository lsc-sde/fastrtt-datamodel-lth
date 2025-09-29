MODEL (
  name fastrtt.src__patient_list,
  kind FULL,
  cron '@daily',
  grain visit_id
);

SELECT
  type::VARCHAR(50) AS rtt_type,
  visit_id::NUMERIC(12, 0) AS visit_id,
  visit_number::VARCHAR(50) AS visit_number,
  mrn::VARCHAR(50) AS mrn,
  name::VARCHAR(255) AS patient_name,
  rtt_last_status::VARCHAR(255) AS rtt_last_status,
  NULL::VARCHAR(255) AS tfc,
  specialty::VARCHAR(255) AS specialty,
  consultant::VARCHAR(255) AS consultant,
  rtt_start_date::DATE AS rtt_start_date,
  NULL::DATE AS rtt_end_date,
  wait::INTEGER AS wait_in_days,
  first_appt_date::DATE AS first_appt_date,
  band::VARCHAR(25) AS band,
  extract_date::DATE AS extract_date
FROM @db_ptl.dbo.incomplete_ptl
UNION ALL
SELECT
  type::VARCHAR(50) AS rtt_type,
  visit_id::NUMERIC(12, 0) AS visit_id,
  visit_number::VARCHAR(50) AS visit_number,
  mrn::VARCHAR(50) AS mrn,
  name::VARCHAR(255) AS patient_name,
  rtt_last_status::VARCHAR(255) AS rtt_last_status,
  tfc::VARCHAR(50) AS tfc,
  specialty::VARCHAR(255) AS specialty,
  consultant::VARCHAR(255) AS consultant,
  rtt_start_date::DATE AS rtt_start_date,
  rtt_end_date::DATE AS rtt_end_date,
  wait::INTEGER AS wait_in_days,
  NULL::DATE AS first_appt_date,
  NULL::VARCHAR(25) AS band,
  extract_date::DATE AS extract_date
FROM @db_ptl.dbo.clock_stops
