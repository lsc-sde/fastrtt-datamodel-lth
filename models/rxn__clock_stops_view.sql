MODEL (
  name fastrtt.rxn__clock_stops_view,
  kind VIEW,
  cron '@yearly'
);



SELECT
	spl.mrn,
	spl.visit_number,
	spl.patient_name ,
	spl.pathway_type ,
	spl.rtt_start_date,
	cd.EventDate Document_Date,
	spl.specialty PTL_Specialty,
	sn.primary_department Document_Specialty,
	lo.is_clock_stop,
	lo.clock_stop_event_description,
	lo.reasoning,
	lo.context,
	lo.extraction_time,
	cd.Encounter,
	cd.FileName,
	lo.note_id,
	spl.pathway_id 	,
	spl.rtt_last_status
FROM
	FastRTT.fastrtt.rxn__incomplete_ptl spl
JOIN FastRTT.fastrtt.specialty_mapping sm ON
	sm.rtt_specialty = spl.specialty COLLATE DATABASE_DEFAULT
JOIN FastRTT.fastrtt.rxn__document sn ON
	spl.mrn = sn.person_id COLLATE DATABASE_DEFAULT
	AND sn.primary_department = sm.documentviewer_specialty COLLATE DATABASE_DEFAULT
JOIN FastRTT.fastrtt.llmoutput lo ON
	lo.note_id = sn.source_id
JOIN DocumentViewer.dbo.ClinicDocuments cd ON
	sn.source_id = cd.PdfDocumentKey
WHERE
	lo.is_clock_stop = 1
