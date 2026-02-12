MODEL (
  name fastrtt.fw__output_report,
  kind VIEW,
  cron '@daily'
);

SELECT
  rip.pathway_id::VARCHAR(20),
  rip.specialty::VARCHAR(20) AS pathway_specialty,
  rd.primary_department::VARCHAR(20) AS document_specialty,
  rip.mrn::VARCHAR(20),
  rip.visit_number::VARCHAR(20),
  rip.patient_name::VARCHAR(100),
  rip.rtt_start_date::DATETIME2,
  rip.wait_in_days::INT,
  ar.note_date::DATETIME2,
  ar.is_clock_stop::VARCHAR(5),
  ar.clock_stop_event_description::VARCHAR(100),
  ar.reasoning::VARCHAR(max),
  ar.context::VARCHAR(max),
  ar.note_content::VARCHAR(max),
  ar.internal_note_id::BIGINT,
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
