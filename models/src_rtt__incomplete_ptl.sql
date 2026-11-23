MODEL (
  name pathways.src_rtt__incomplete_ptl,
  kind VIEW,
  description 'The BI incomplete PTL as it is in DB_PTL (dbo.incomplete_ptl). A fixed name for the source, so models and tests do not depend on which server it is on.'
);

SELECT
  ptl.organisation_code,
  ptl.pathway_type,
  ptl.pathway_id,
  ptl.visit_number,
  ptl.mrn,
  ptl.name,
  ptl.rtt_last_status,
  ptl.specialty,
  ptl.consultant,
  ptl.rtt_start_date,
  ptl.wait,
  ptl.tci_date,
  ptl.first_appt_date,
  ptl.extract_date
FROM @source_table(@db_ptl, 'dbo.incomplete_ptl') AS ptl
