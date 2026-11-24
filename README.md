# fastrtt-datamodel-lth
Semantic Data Model for FastRTT Agentic Workflow (LTH Edition)

A SQLMesh project that makes the incomplete RTT pathways (the BI incomplete PTL
in `18_Weeks`) available in the `pathways` database (on LTHDATASCIENCE), linked to OMOP `person_id`,
for Kvasir to read. Clinical documents are not brought in here: shovel
handles those.

Models (database `pathways`, schema `pathways`):

| Model | What it holds |
|---|---|
| `src_rtt__incomplete_ptl` | View over `dbo.incomplete_ptl` in `DB_PTL` (e.g. `LTHDSDEV.[18_Weeks]`) |
| `rxn__incomplete_ptl` | One row per open pathway, with `person_id` |
| `master_patient_index` | MRN to `person_id` link, copied from the OMOP MPI |
| `specialty_mapping` | Seed mapping PTL specialties to DocumentViewer departments |

## Linking PTL pathways to OMOP `person_id`

`pathways.master_patient_index` copies the MRN-to-`person_id` link from the OMOP
master patient index each day (set `DB_MPI` in `.env`; see `sample.env`). Only
`flex_mrn`, `person_id` and `current_record` are copied.

`pathways.rxn__incomplete_ptl` left-joins it on the trimmed MRN, using current
records only, and adds:

- `person_id`: the OMOP person, or NULL when it cannot be linked safely.
- `person_match_status`: `matched`, `no_match` (MRN not in the MPI) or
  `ambiguous` (MRN maps to more than one person; never guessed).

Every PTL row is kept, so models reading `rxn__incomplete_ptl` are unaffected.

Unit tests use synthetic data and run on duckdb: `uv run sqlmesh test`. SQLMesh
still connects to the gateway in `.env` when it starts, so the server must be
reachable.
