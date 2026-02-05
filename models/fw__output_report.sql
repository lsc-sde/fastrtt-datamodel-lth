MODEL (
  name fastrtt.fw__output_report,
  kind VIEW,
  cron '@daily'
);

SELECT
  rip.pathway_id,
  rip.specialty AS pathway_specialty,
  rd.primary_department AS document_specialty,
  rip.mrn,
  rip.visit_number,
  rip.patient_name,
  rip.rtt_start_date,
  rip.wait_in_days,
  ar.note_date,
  ar.is_clock_stop,
  ar.clock_stop_event_description,
  ar.reasoning,
  ar.context,
  ar.note_content,
  ar.internal_note_id
FROM fw_output.agent_response AS ar
JOIN fastrtt.rxn__document AS rd
  ON ar.source_id::VARCHAR = rd.source_id::VARCHAR
JOIN fastrtt.rxn__incomplete_ptl AS rip
  ON rip.mrn = rd.person_id COLLATE Latin1_General_CI_AS
JOIN fastrtt.specialty_mapping AS sm
  ON sm.rtt_specialty = rip.specialty
  AND sm.documentviewer_specialty = rd.primary_department COLLATE Latin1_General_CI_AS
WHERE
  rip.valid_to IS NULL
  AND rd.note_date >= rip.rtt_start_date /* ORDER BY */ /*   rip.rtt_start_date ASC, */ /*   ar.note_date ASC */
