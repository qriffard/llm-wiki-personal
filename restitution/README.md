# Restitution

Data side of Active Restitution: spaced review of notes from the `brain/` vault.
The code lives in [`qriffard/active_restitution`](https://github.com/qriffard/active_restitution);
this directory holds its retention store and the design docs.

It reads `brain/` through the vault contract only (Markdown notes, `[[wikilinks]]`,
frontmatter with `title`, `tags`, `created`, `updated`; meta files excluded via
`brain/.okignore`, the reserved `index`/`log`/`hot` pages and `_`-prefixed
framework directories). It never writes to `brain/`; retention state lives here.

```
restitution/
├── config.yaml        # scope, ignore list, depth, edge weights
├── notes/             # learning state per note, keyed by brain/-relative path
├── probes/            # generated questions and reference answers
├── sessions/          # session logs
├── verifications/     # optional reference checks
└── docs/              # design docs (01-knowledge-base.md: vault migration and contract)
```

Usage, from a checkout of `active_restitution/core`:

```
uv run restitution check <repo>/brain --store <repo>/restitution
uv run restitution rank  <repo>/brain --store <repo>/restitution
```
