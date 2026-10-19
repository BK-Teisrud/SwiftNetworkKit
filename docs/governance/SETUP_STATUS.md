# Oppsettsstatus og verifikasjon

Kontrollert 2026-10-19. [Offentlig repo](https://github.com/BK-Teisrud/SwiftNetworkKit), [privat prosjekt](https://github.com/users/BK-Teisrud/projects/6). Dette er faktiske innstillinger lest tilbake fra GitHub, ikke bare forslag i JSON. **Ingen produktkode eller kodegodkjenning.**

| Område | Resultat og begrunnelse |
| --- | --- |
| Repo | Public, main, Issues/Projects på; Wiki/Discussions av for én dokumentasjonskilde |
| Merge | Kun squash, auto-merge av, branch cleanup/update på |
| Web sign-off | Av etter konkret eiergodkjenning; ingen DCO er valgt; ikke en endring av LICENSE |
| Main | Ruleset 25428389 aktivt, PR og løste tråder, lineær historikk, ingen sletting/force-push; ingen bypass-aktører |
| Tag-oppretting | 25432767 begrenser refs/tags/v*, admin-unntak gjelder bare creation |
| Tag-uforanderlighet | 25428391 update/deletion uten bypass; gjelder også admin så lenge regelen består |
| Release | Immutable releases aktivert, enforced_by_owner=false; kontoeier kan fortsatt endre innstillingen |
| Actions | Read-only token, PR-approval av, GitHub-/lokale actions, SHA-låsing på; null workflows |
| Security | Secret scanning/push protection og privat rapportering konfigurert; se tidligere baseline og repository-readback |
| Labels | 16 egendefinerte type/scope/priority/øvrige labels; fem status-labels fjernet, også fra maler/seed |
| Plan | Sju milepæler, ingen oppdiktede datoer; 30 startissues + 23 I-oppgaver + START-00 og verifikasjonsissue = 55 issues |
| Oppgaver | I01–I23 (#42–64) har eier, milepæl, kriterier, foreldreepic og native avhengigheter; alle Blocked av #41 |
| Prosjekt | Sju statusvalg, Priority/Scope og Order; åtte visninger inkludert Arbeidskø og Ferdig |
| Arbeidskø | Flat tabell, Order stigende; lagret i UI og kontrollert etter reload |
| Automasjon | Import, subissues, added/closed/reopened og PR merged på; Auto-close og PR linked av |
| Kontosikkerhet | Eier bekrefter 2FA aktivert; ikke uavhengig verifisert, ingen credentials innhentet |
| Kontakt | Ingen adresse avklart; ingen privat lisens-/bidragsprosess eller oppdiktet kontaktadresse |
| Testmiljø | Ni nyere simulator-runtimes inventarført; ingen minimums-runtime eller produkttest verifisert |

## Funksjonstest av prosjektflyt

[Oppsettsissue #40](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/40) ble opprettet uten eksplisitt prosjektimport. Native auto-add tok det inn med Backlog. Prosjektstatus ble satt til Done, og API viste at issue fortsatt var open. Issue ble lukket som completed, gjenåpnet, og native workflow satte Backlog. Deretter ble det lukket på nytt og native workflow satte Done. Alle fire kontroller er bestått. Ingen produktkode eller testkode ble opprettet.

Native sub-issue-relasjoner er opprettet, alle 45 forventede blocked-by-relasjoner for I01–I23 er lest tilbake, og API-readback viser workflows enabled. PR merged/auto-add subissues er ikke separat ende-til-ende-testet med en produkt-PR; denne avgrensningen beholdes. Item closed skiller ikke reason i gjeldende oppsett: not planned må korrigeres manuelt til Not Planned; Ferdig filtrerer completed og unngår feil leveransetelling. Priority/Scope synkroniseres manuelt ved triage.

## Verifikasjonsgrunnlag

Repository-settings, effektive main-regler, alle tre rulesets, immutable-releases, Actions-token/policy/workflowantall, labels, prosjektvisninger/workflows/felt og oppgavestatus er lest tilbake. Alle 23 deloppgaver har Blocked, P1, KJERNE og korrekt numerisk Order. Arbeidskøens stigende sortering og avskrudd hierarki er lagret og kontrollert etter reload i nettleseren. JSON, YAML, lokale dokumentlenker, whitespace og filinventar kontrolleres før dokumentasjons-PR.

Konfigurasjonsgrunnlag: .github/settings og .github/rulesets. Filer er versjonerte snapshots, ikke automatisk synk eller et skript som skal kjøres ukritisk. Historisk planning.json er opprinnelig seed, ikke live status. Ingen aktive Actions-workflows, Swift-filer, Package.swift, prototyper, tester, tagger eller releases finnes i leveransen. Ingen produktbygg/test hevdes bestått.

## Hva som er ferdig og hva som gjenstår

F0-planlegging og forberedende repoarbeid er fullført; OPS-01 / #30 avsluttes med dokumentasjons-PR-en og F0-milepælen avsluttes deretter. Dette er ingen produktlevering. [START-00 / #41](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/41) i F1 forblir åpen til eier uttrykkelig godkjenner kodestart. I01 er første kodeoppgave etter denne godkjenningen.

[PRE_CODE_READINESS.md](../planning/PRE_CODE_READINESS.md) viser restpunktene: faktisk API-symbolkontroll per oppgave, reell CI i I06 og minimums-OS-/enhetsbevis i I21/I22. Nyere enheter er eieroppgitt uten eksakte versjoner. Manglende minimumsmiljø blokkerer release; ingen kjøp/oppgraderinger eller endret OS-støtte er godkjent.

Ingen ekstra reviewer er påkrevd før en reell medmaintainer finnes. Ingen signerte commits er påkrevd uten avklart signeringsoppsett. Ingen tomme status-checks, Dependabot-filer uten manifest, unødvendige tredjepartsverktøy, secrets, webhooks, apper, runners, betalingsprodukter eller publisering er opprettet. Main har ingen bypass, men repo-admin kan fortsatt endre reglene; ingen garanti mot kontoeieren gis. Prosjektet holdes privat, og daterte roadmap-bars utsettes til kapasitet/datoer faktisk er vedtatt.
