# Restitution

Active-restitution skill: spaced review of notes from the `brain/` vault.

It reads `brain/` through the vault contract only (Markdown notes, `[[wikilinks]]`,
frontmatter with `title`, `tags`, `created`, `updated`; meta files excluded via
`brain/.okignore`, the reserved `index`/`log`/`hot` pages and `_`-prefixed
framework directories). It never writes to `brain/`; retention state lives here.

Design docs: `docs/` (`01-knowledge-base.md`: vault migration and contract).
