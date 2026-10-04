# Personal knowledge base + Active Restitution

Two top-level directories:

- `brain/` — the knowledge vault: an Obsidian vault maintained with the
  [`Ar9av/obsidian-wiki`](https://github.com/Ar9av/obsidian-wiki) framework.
  Reading (books, articles), listening (podcasts, videos) and notes on personal
  viewpoints. Bilingual French/English.
- `restitution/` — the active-restitution skill (spaced review of notes from
  `brain/`). See `restitution/README.md`.

## Working in `brain/`

- **Read `brain/AGENTS.md` first.** It holds the owner conventions (language,
  no employer content, frontmatter extensions, categories, ingest rules) and
  overrides framework defaults.
- Use the framework's skills (`/wiki-ingest`, `/wiki-capture`, `/wiki-query`,
  `/wiki-lint`, `/wiki-status`, …). They need the vault configured once per
  machine: `pip install obsidian-wiki && obsidian-wiki setup --vault <repo>/brain`.
- Every page lives in a category folder (`concepts/`, `entities/`,
  `references/`, `synthesis/`, …) with frontmatter `title, category, tags,
  sources, summary, created, updated`. Link with path-qualified wikilinks:
  `[[entities/jean-luc-melenchon]]`.
- `index.md`, `log.md` and `hot.md` are generated: update them with
  `obsidian-wiki memory sync <VERB> key=value… --vault brain`, never by hand.
- Raw captures are immutable and live in `brain/_raw/_archived/`. Capture
  helpers from the previous wiki are still in `.claude/scripts/`
  (`extract-podcast.py`, `epub-to-text.py`).

## Working in `restitution/`

The skill reads `brain/` only through the vault contract and **never writes
there**; its retention state lives under `restitution/`.

## History

Until 2026-10-04 this repo was a hand-rolled LLM Wiki (top-level `wiki/`,
`raw/`, `index.md`, `_hot.md`). It was converted by
`.claude/scripts/migrate-to-obsidian-wiki.py`; the old layout is at commit
`ce821ab`, and its log is in `brain/_archives/llm-wiki-log.md`.
