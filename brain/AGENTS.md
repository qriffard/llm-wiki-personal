# Owner conventions

Personal knowledge base: reading (books, articles), listening (podcasts,
videos), and notes on personal viewpoints. Migrated on 2026-10-04 from a
hand-rolled LLM Wiki; its log is kept in `_archives/llm-wiki-log.md`.

## Language

Bilingual, French and English. **Do not translate.** Write a page in the
language of its source or of the owner's note, and keep that language when
updating it later.

## Content boundary

No employer content: no internal documents, nothing derived from them, no
internal names. This vault is pushed to GitHub and read by hosted services.

## Frontmatter extensions

On top of the framework fields (`title, category, tags, sources, summary,
created, updated`):

- `captured` — date the raw snapshot was taken, or `pending` / `failed — <reason>`
  when capture did not succeed. Never summarize content that was not captured.
- `version` — source version when it has one (edition/ISBN, document revision,
  git SHA). Used to detect staleness.

Trust fields (`base_confidence`, `lifecycle`) are not set on migrated pages;
treat their absence as unreviewed, not as an error to fill in automatically.

## Categories

- `references/` — one page per ingested source (article, video, podcast, book).
- `entities/` — people, organisations, named affairs.
- `concepts/` — ideas and recurring themes.
- `synthesis/` — comparisons and cross-source analysis.

## Ingest

Capture first: keep an immutable snapshot under `_raw/_archived/` before
summarizing. Podcasts: Apple Podcasts or RSS link (not Spotify). Videos:
transcript via `yt-dlp` when available.
