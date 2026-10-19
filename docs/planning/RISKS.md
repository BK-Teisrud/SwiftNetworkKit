# Risikoregister

Eier for alle åpne risikoer ved bootstrap: @BK-Teisrud. Vurderes ved ukentlig triage og faseporter.

| ID | Risiko / sannsynlighet / konsekvens | Tiltak og utløsende signal | Port |
| --- | --- | --- | --- |
| R1 | Overengineering / høy / høy | ADR-0003 og V1_SCOPE.md fastsetter HTTP-kjerne og én bibliotekmodul i v1; nye moduler krever vedtak og behov. Scope vokser uten brukerflyt → stopp og revurder. | F0 |
| R2 | OS-forskjeller / høy / høy | ADR-0004 og PLATFORM_MATRIX.md fastsetter OS-minimum/verktøy. Konkrete symboler, guards og runtime-/enhetstester må fortsatt verifiseres. Simulatorbygg alene er utilstrekkelig. | F0–F4 |
| R3 | Dupliserte sideeffekter ved retry / middels / høy | Default uten usikker retry, idempotens og bounded attempts. | F3 |
| R4 | Credentials i logger/redirect/cache / middels / kritisk | Negative redaction/isolasjons-/redirecttester, privat security review. | F2 |
| R5 | Refresh-storm/deadlock / middels / høy | Single-flight og test av samtidighet/cancel før auth-modul. | F3 |
| R6 | Utdatert eller lekket cache / middels / høy | HTTP-semantikk, kontoisolasjon, sletting og eksplisitt offline-policy. | F3 |
| R7 | Bakgrunnsleveranse loves uten OS-støtte / høy / høy | Entitlements, hostapp-ansvar og fysisk testbevis per plattform. | F4 |
| R8 | Solo-maintainer og review-flaskehals / høy / middels | PR-spor, liten WIP, team-profil når reviewer finnes. | Alle |
| R9 | Bruk eller eksterne bidrag uten nødvendige rettigheter / middels / høy | DEC-03 avgjort: Teisrud Development AS, proprietær policy. LICENSE og ADR-0002 presiserer tillatelseskrav og GitHub-unntak. Skriftlig avtale før eksterne innholdsbidrag eller tredjepartsdistribusjon. | F0 og release |
| R10 | Falsk trygghet fra grønn CI / middels / høy | Ingen dummy-checks; ekte matrise og releasebevis. | F1 |
| R11 | Endrede GitHub-regler/verktøy / middels / middels | Kvartalsvis innstillingskontroll, Actions-budsjett og minstetilgang. | Alle |

Aksept av rest-risiko krever kommentar i relevant issue og ADR ved varig avvik. Kritiske sikkerhetsfunn blokkerer release til de er rettet eller scope er fjernet med begrunnelse.

## Konkret restarbeid før release

R2: Minimums-OS-testmiljø er ikke bekreftet. I21 / #62 blokkerer release; nyere enheter og installerte nyere runtimes er ikke erstatning. Se TEST_ENVIRONMENTS.md.

R9: Ingen kontaktadresse finnes ennå. Ingen privat lisens-/bidragsprosess tilbys før egnet kanal er avklart. Dette blokkerer ikke separat godkjent intern implementasjon.

R11: Admin kan endre selve rulesets selv om main/update/deletion ikke har bypass. Ingen teknisk garanti mot kontoeieren gis. Eier bekrefter 2FA, men en uavhengig kontoaudit er ikke utført.
