# Personal — Log

> Append-only chronological record. Each entry starts with `## [YYYY-MM-DD] <op> | <title>`
> so it is greppable: `grep "^## \[" log.md | tail -5`.

## [2026-06-26] create | Wiki initialized
Bootstrapped LLM Wiki for "Personal". Purpose: Track reading (books, articles), listening (podcasts), and notes on personal viewpoints. Use-case: personal + research.

## [2026-06-26] ingest | LFI, l'antiaméricanisme et la complaisance envers l'antisémitisme
Note personnelle (conversation Claude). Pages créées : lfi-antisemitisme, lfi, people/jean-luc-melenchon, distinction-israel-juifs-francais, panorama-partis-antisemitisme. Source capturée dans raw/lfi_antisemitisme.md.

## [2026-06-26] ingest | « L'inceste n'est jamais de la sexualité » — Mediapart, juin 2026
Vidéo YouTube (ZY7dKt4UwFU), émission À l'air libre, 1h16. Avec Camille Kouchner, Eva Thomas, Romain Lemire, Sarah Brethes. Transcript capturé dans raw/inceste-mediapart.fr.vtt. Pages créées : inceste-mediapart-juin2026, inceste-fait-social, people/camille-kouchner, people/eva-thomas, people/romain-lemire.

## [2026-06-26] ingest | bulk × 3 — articles presse (Ipsos/CRIF, Mediapart, Le Monde)
3 articles ajoutés dans raw/ par l'utilisateur.
- ipsos-crif-antisemitisme-france-2024 (source primaire confirmant chiffres LFI 55% / RN 52%)
- erner-france-culture-lfi-rn (affaire montage fallacieux France Culture)
- unedic-mythe-chomeur-oisif-2026 (étude Unédic vs mythe politique)
Mise à jour : panorama-partis-antisemitisme (données Ipsos intégrées). Seuil lint atteint (10 ingests).

## [2026-06-26] ingest | bulk × 5 — Mediapart playlist (parallel subagents)
5 vidéos YouTube ingérées en parallèle. Transcripts VTT dans raw/video-*.fr.vtt.

- **fNsTyraIa9A** → affaire-lyhanna-justice-defaillante (justice pédocriminelle, rapport Darmanin secret)
- **YibxgFFPuSM** → genocide-gaza-culturicide-mediapart-juin2026 (culturicide, Marion Slitine)
- **Hmo08c2dgM4** → financement-libyen-sarkozy-proces-appel (procès appel Sarkozy, réquisitions 7 ans)
- **3J4k1YVuFLA** → bollore-culture-alarme-mai2026 (Bolloré, concentration médias)
- **35vwVsWyu50** → loi-yadan-balibar-mediapart (loi Yadan, Balibar)

Reconciliation : 7 entity pages (nicolas-sarkozy, vincent-bollore, etienne-balibar, fabrice-arfi, gerald-darmanin, andrea-bescond, marion-slitine) + affaire-lyhanna + 5 concept pages (loi-yadan, culturicide, concentration-medias-france, antisionisme-vs-antisemitisme, justice-pedocriminalite-france, affaire-libyenne).

## [2026-07-07] ingest | Valérie Masson-Delmotte explique le changement climatique
Podcast L'échappée (Mediapart), épisode du 2026-07-06, 68 min. Pas de
transcript officiel dans le flux RSS (`podcast:transcript` absent) →
transcrit localement avec whisper.cpp (large-v3-turbo). Capture dans
`raw/valerie-masson-delmotte-changement-climatique.md`. Nouvelle capacité
d'ingest podcast ajoutée à ce cycle : `.claude/scripts/extract-podcast.py`
(résout Apple Podcasts/RSS/audio direct, transcript officiel si publié sinon
whisper.cpp) — voir CLAUDE.md. Pages créées : valerie-masson-delmotte-changement-climatique, people/valerie-masson-delmotte.

## [2026-07-07] lint | 33 pages auditées, 2 domaines promus, 3 liens cassés/manquants corrigés
Premier lint du wiki (seuil de 10 ingests dépassé depuis le 10e ingest, jamais fait avant). Périmètre : 33 pages `wiki/`, frontmatter, liens entrants/sortants, tags, captures.

- **Domaines promus** (tag-clusters > 8 pages) : [[_index-antisemitisme]] (9 pages) et [[_index-inceste]] (9 pages) créés, liés depuis `index.md`. `index.md` allégé — ces deux domaines ne sont plus énumérés à plat dans Sources/Entities/Concepts.
- **Tag `politique-française` (18/33 pages) non promu** : trop générique pour être un domaine cohérent (recouvre LFI, Sarkozy, Bolloré, justice...). À reconsidérer : soit un tag de filtrage annexe, soit à décomposer en tags plus spécifiques lors d'un prochain lint.
- **Tag `justice` (8 pages) non promu** : recoupe entièrement les domaines inceste/pédocriminalité et corruption/Sarkozy déjà couverts autrement — pas un cluster indépendant.
- **Concept manquant créé** : [[antiamericanisme-prisme]] — référencé par deux pages ([[lfi]], [[lfi-antisemitisme]]) sans jamais avoir été écrit ; un des deux liens avait même une faute de frappe (espace parasite dans le slug). Page créée, les deux liens corrigés.
- **Orphelin corrigé** : [[erner-france-culture-lfi-rn]] n'était référencé que depuis `index.md`, jamais depuis une autre page de contenu — ajout d'un renvoi croisé depuis [[lfi-antisemitisme]] (cas concret du cadrage « LFI antisémite / RN dédiabolisé »).
- **Orphelin accepté tel quel** : [[unedic-mythe-chomeur-oisif-2026]] — seul source sur le chômage, aucune page connexe à lier pour l'instant.
- **Affirmation obsolète corrigée** : `lfi.md` indiquait « 55% ... à vérifier avec source primaire » — la source primaire ([[ipsos-crif-antisemitisme-france-2024]]) confirme ce chiffre depuis l'ingest du 26/06 ; mention et lien mis à jour.
- **Captures `pending`/`failed`** : aucune trouvée, rien à relancer.
- **`_hot.md`** : rafraîchi, flag de lint levé.

Pistes pour la suite : décomposer `politique-française` en tags plus fins ; envisager une page overview.md de synthèse (jamais créée depuis le bootstrap) maintenant que le wiki a une taille significative (33 pages, 4 domaines thématiques).
