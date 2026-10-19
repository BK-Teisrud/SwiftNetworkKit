# Risikoregister

Eier for alle åpne risikoer ved bootstrap: @BK-Teisrud. Vurderes ved ukentlig triage og faseporter.

| ID | Risiko / sannsynlighet / konsekvens | Tiltak og utløsende signal | Port |
| --- | --- | --- | --- |
| R1 | Overengineering / høy / høy | Godkjent liten v1; nye moduler krever behov. Scope vokser uten brukerflyt → stopp og revurder. | F0 |
| R2 | OS-forskjeller / høy / høy | Symbol-/SDK-matrise, guards og enhetstester. Simulator alene er utilstrekkelig. | F0–F4 |
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
