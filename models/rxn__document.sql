MODEL (
  name fastrtt.rxn__document,
  kind INCREMENTAL_BY_UNIQUE_KEY (
    unique_key (org_code, source_system, source_id)
  ),
  cron '@daily',
  grain note_id
);

WITH pathways AS (
  SELECT
    spl.mrn AS mrn,
    spl.specialty AS specialty,
    min(spl.rtt_start_date) AS rtt_start_date
  FROM fastrtt.rxn__incomplete_ptl AS spl
  WHERE
    spl.wait_in_days > 18 * 7 AND spl.valid_to IS NULL
  GROUP BY
    spl.mrn,
    spl.specialty
)
SELECT
  'rxn' AS org_code,
  'document_viewer' AS source_system,
  cd.pdfdocumentkey::VARCHAR AS source_id,
  cd.patientmrn AS person_id,
  cd.eventdate AS note_date,
  32817 AS note_type_concept_id, /* Athena concept_id for 'EHR' */
  pd.name AS primary_department,
  ad.name AS alias_department,
  cd.filestream AS note_content,
  cd.agent AS provider_id,
  coalesce(dt.displaynameoverride, dt.displayname) AS note_source_value
FROM pathways AS p
JOIN fastrtt.specialty_mapping AS sm
  ON sm.rtt_specialty = p.specialty COLLATE Latin1_General_CI_AS
JOIN @db_documentviewer.dbo.clinicdocuments AS cd
  ON cd.patientmrn = p.mrn COLLATE Latin1_General_CI_AS
  AND cd.eventdate >= p.rtt_start_date
JOIN @db_documentviewer.dbo.aliasdepartment AS ad
  ON ad.provenanceid = cd.provenanceid AND ad.provenanceidvalue = cd.departmentid
JOIN @db_documentviewer.dbo.primarydepartment AS pd
  ON pd.primarydepartmentid = ad.primarydepartmentid
  AND pd.name = sm.documentviewer_specialty COLLATE Latin1_General_CI_AS
LEFT JOIN @db_documentviewer.dbo.documenttype AS dt
  ON dt.documenttypeid = cd.documenttypeid
WHERE
  NOT EXISTS(
    SELECT
      1
    FROM fastrtt.existing_note AS e
    WHERE
      e.source_id = cd.pdfdocumentkey
      AND org_code = 'rxn'
      AND source_system = 'document_viewer'
  )
