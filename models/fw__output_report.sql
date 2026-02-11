MODEL (
  name fastrtt.fw__output_report,
  kind VIEW,
  cron '@daily'
);

SELECT
  rip.pathway_id::VARCHAR,
  rip.specialty::VARCHAR AS pathway_specialty,
  rd.primary_department::VARCHAR AS document_specialty,
  rip.mrn::VARCHAR,
  rip.visit_number::VARCHAR,
  rip.patient_name::VARCHAR,
  rip.rtt_start_date::DATETIME2,
  rip.wait_in_days::INT,
  ar.note_date::DATETIME2,
  ar.is_clock_stop::VARCHAR,
  ar.clock_stop_event_description::VARCHAR,
  ar.reasoning::VARCHAR,
  ar.context::VARCHAR,
  ar.note_content::VARCHAR,
  ar.internal_note_id::VARCHAR,
  CAST(cast(ar.extraction_time as varchar) AS DATETIME2) as extraction_time
FROM fw_output.agent_response AS ar
JOIN fastrtt.rxn__document AS rd
  ON ar.source_id::VARCHAR = rd.source_id::VARCHAR
JOIN fastrtt.specialty_mapping AS sm
  ON sm.documentviewer_specialty = rd.primary_department COLLATE Latin1_General_CI_AS
JOIN fastrtt.rxn__incomplete_ptl AS rip
  ON rip.mrn = rd.person_id COLLATE Latin1_General_CI_AS
  and sm.rtt_specialty = rip.specialty
WHERE
   rd.note_date >= rip.rtt_start_date /* ORDER BY */ /*   rip.rtt_start_date ASC, */ /*   ar.note_date ASC */
