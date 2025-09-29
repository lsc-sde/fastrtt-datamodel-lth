MODEL (
  name fastrtt.stg__note,
  kind FULL,
  cron '@daily',
  grain visit_id
);

SELECT
  cd.pdfdocumentkey AS note_id,
  cd.patientmrn AS person_id,
  cd.eventdate AS note_date,
  32817 AS note_type_concept_id, /* Athena concept_id for 'EHR' */
  NULL AS note_class_concept_id,
  NULL AS note_title,
  cd.filestream AS note_text,
  pd.name AS department,
  cd.agent AS provider_id,
  concat(dt.deptshortname, ' - ', dt.displayname) AS note_source_value
FROM @db_documentviewer.dbo.clinicdocuments AS cd
JOIN fastrtt.src__patient_list AS pl
  ON cd.patientmrn = pl.mrn COLLATE Latin1_General_CI_AS
  AND cd.eventdate >= pl.rtt_start_date
LEFT JOIN @db_documentviewer.dbo.aliasdepartment AS ad
  ON ad.provenanceid = cd.provenanceid AND ad.provenanceidvalue = cd.departmentid
LEFT JOIN @db_documentviewer.dbo.primarydepartment AS pd
  ON pd.primarydepartmentid = ad.primarydepartmentid
LEFT JOIN @db_documentviewer.dbo.documenttype AS dt
  ON dt.documenttypeid = cd.documenttypeid
