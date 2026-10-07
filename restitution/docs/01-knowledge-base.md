# 1. Knowledge base: migration and vault contract

*Part of Active Restitution. See `00-overview.md`.*

*Status: migration done on 2026-10-04 (commits `eb061be`, `2ee87f6`). This version replaces the plan with what was actually done.*

## 1. Goal

In order to start reviewing real content immediately, we reuse the existing personal LLM wiki rather than building a new knowledge base. This document describes the migration of that wiki to an Obsidian vault maintained with the `Ar9av/obsidian-wiki` framework, and defines the vault contract that the restitution skill relies on.

We can note that the existing wiki and the target framework shared most of their design: many small, tightly scoped pages, a global index, per-theme indexes and a cache of recent pages. Indeed, the migration turned out to be a renaming and frontmatter exercise, not a restructuring.

The rest of this document is organised as follows. First, we state the constraints. Then, we define the vault contract and the mapping that was applied. Finally, we describe the migration procedure, its validation and the remaining open questions.

## 2. Constraints

- **No employer content.** The vault is pushed to GitHub and read by hosted services, so it must contain no employer document, page derived from internal material, or internal name. This rule is written in `brain/AGENTS.md`, which every framework skill reads before writing.
- **Private repository.** The vault and the restitution code share one private repository (`qriffard/llm-wiki-personal`), as two top-level directories: `brain/` and `restitution/`. This departs from the initial plan, in which only the vault was private and the restitution code was public; publishing the code now requires splitting `restitution/` into its own repository.
- **The skill never writes to `brain/`.** The vault is maintained by the user and by `obsidian-wiki` skills. Retention state lives under `restitution/` (document 2).
- **Framework is replaceable.** The restitution skill depends only on the vault contract below, not on `obsidian-wiki`. If the framework becomes a burden, any tool that respects the contract can replace it.

## 3. Vault contract (what the skill consumes)

A conforming vault is a directory of Markdown files such that:

1. Each note is a `.md` file with a stable path relative to the vault root; the path without extension is the note identifier (e.g. `entities/jean-luc-melenchon`).
2. Internal links use `[[wikilinks]]`, path-qualified, with optional `|alias` and `#heading`. Inside a Markdown table, the alias separator is escaped as `\|`.
3. Each note has YAML frontmatter with at least `title`, `tags`, `created`, `updated`. The `obsidian-wiki` set (`title, category, tags, sources, summary, created, updated`) is a superset and is therefore valid. Free-text values (`title`, `summary`) may use folded scalars (`>-`).
4. Optional typed dependencies are expressed with the framework's native `relationships:` list, each entry having a `target` wikilink and a `type` from the framework's allowlist (e.g. `extends`, `contradicts`). The skill treats them as weighted edges; their absence is acceptable.
5. Non-review files are identified by three rules, all already used by the framework's own lint: the `.okignore` file at the vault root (gitignore syntax, currently `/AGENTS.md` and `/_meta`), the reserved page names `index`, `log`, `hot` and `_insights`, and the skipped directories `_raw`, `_archived`, `_staging`, `_archives` and any dot-directory.

Nothing else is required. In particular, no retention field is ever added to a note.

## 4. Mapping applied

| Old wiki | Vault | Notes |
|---|---|---|
| `wiki/*.md`, `wiki/people/*.md` | `<category>/<slug>.md` | `type` gives the folder: entity → `entities/`, concept → `concepts/`, source → `references/`, comparison and overview → `synthesis/`. People pages join `entities/`. |
| `type` | `category` | Same mapping as the folder. |
| `date` | `created` | The git history is too coarse to be used: most pages arrived in a few bulk commits, which would have collapsed `created` to two or three dates. |
| last commit on the file | `updated` | Maximum of `created` and the last commit date. |
| `sources` (a count) | `sources` (a list) | `url:<source_url>` when the page had one, the archived raw file otherwise, an empty list for derived pages. |
| `source_url`, `captured`, `version` | `sources`, `captured`, `version` | `captured` and `version` are kept as owner extensions declared in `brain/AGENTS.md`. |
| index one-liners | `summary` | Every page had one; wikilinks inside summaries are flattened to text. |
| `[[slug]]`, `[[people/slug]]` | `[[category/slug]]` | Alias and heading preserved. |
| `raw/*` | `_raw/_archived/*` | 11 captures. Markdown captures are also recorded as `snapshots:`; all are recorded in `.manifest.json`. |
| `_index-*.md` | dropped | Both theme indexes held at most 9 pages; tags and the generated `index.md` cover them. |
| `index.md`, `_hot.md` | `index.md`, `hot.md` | Regenerated with `obsidian-wiki memory sync`, not migrated. |
| `log.md` | `_archives/llm-wiki-log.md` | Kept verbatim as history; a fresh `log.md` starts with the `MIGRATE` entry. |

## 5. Migration procedure

1. **Inventory.** The wiki held 35 pages, 11 raw captures, 2 theme indexes and about 160 wikilinks. A search for the employer's name in the working tree, in `raw/` and in the full git history returned nothing.
2. **Separate.** Hence, no page had to be removed or rewritten. The pre-migration state is commit `ce821ab` (the `pre-migration` tag could not be pushed from the cloud session).
3. **Install the framework.** `pip install obsidian-wiki` and `obsidian-wiki setup --vault <repo>/brain` work as documented. The SessionStart hook `.claude/hooks/setup-obsidian-wiki.sh` now does this on every session (install on cloud containers only), then checks the vault with `doctor` and `lint` and injects the vault recap. The framework's own session hooks are not registered: the start hook would fire too late in cloud sessions, and the Stop capture hook would push session notes into `brain/` through the repository's sync hook.
4. **Convert with a script.** `.claude/scripts/migrate-to-obsidian-wiki.py` (stdlib only) applies the mapping of section 4, then calls the framework CLI for snapshots, manifest and memory files. It runs in dry-run mode by default and prints a report.
5. **Validate.**
   - Page count parity: 35 pages before and after (9 concepts, 14 entities, 11 references, 1 synthesis).
   - Zero broken wikilinks. We can note that the old wiki already had 21 dangling links, pointing to pages that were never created (and one typo, `metooi nceste`); they were turned into plain text and listed in the migration report. One other typo (`justice-pedo-criminalite-france`) was fixed.
   - `obsidian-wiki lint` returns `warn`, with no failure. The warnings are understood: 35 pages without trust fields (`base_confidence`, `lifecycle`), which we chose not to invent, a missing trust ledger, and 6 `snapshot_mismatch` caused by the `.vtt` transcripts (see section 7). `obsidian-wiki doctor` passes.
   - The contract checker of document 2 (`restitution check <vault>`) does not exist yet.
6. **Cut over.** The old top-level layout was removed; it remains in the history at `ce821ab`. New captures go to `brain/` through `obsidian-wiki` skills.

In conclusion, the migration fitted in one working session, and step 2 turned out to be empty.

## 6. Ingestion after migration

Ingestion stays outside the restitution project. For the author's own use, a scheduled job (Cowork task or cron) running `/wiki-history-ingest claude` and pushing the repository is sufficient; it is not set up yet. Note that the repository's sync hook already commits and pushes every change at the end of each turn, so a scheduled job only needs to trigger the ingest.

## 7. Open questions

The two first questions of the initial plan are resolved. First, theme index pages were dropped in favour of tags and the generated index. Second, typed relations do not need a body section: the framework has a native `relationships:` field, validated by its lint.

The remaining questions are the following:

- **Ingestion frequency and runner** (Cowork scheduled task vs. cron on a home machine); daily is a reasonable starting point.
- **Non-Markdown snapshots.** The framework's lint resolves wikilinks only to `.md` and media files, so `.vtt` (and presumably `.txt`) transcripts cannot be recorded as `snapshots:` without being reported as broken links. They are currently linked from each page's Sources section with a Markdown link. Either the framework accepts these extensions, or transcripts should be converted to `.md` at capture time.
- **Repository split.** Whether `restitution/` moves to a public repository, and when.
- **Trust fields.** Whether the restitution skill should consume `lifecycle` or `base_confidence` once the user reviews pages, or ignore them entirely.

The next step will be document 2: the retention model and the `restitution check` contract checker, validated against `brain/`.
