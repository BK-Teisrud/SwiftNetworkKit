# Kravsporbarhet og startbacklog

Baseline: 20 domene-epics, 7 beslutningsoppgaver og 3 styrings-/releaseoppgaver. Dette er planlagt arbeid; ingenting er implementert. Live issue-lenker legges i [GitHub-registeret](GITHUB_REGISTER.md).

| ID | Krav / oppgave | Klassifisering | Fase |
| --- | --- | --- | --- |
| DEC-01 | Vedtatt: OS 17/14/10/17, Xcode 26.3+, Swift tools 6.2 / Swift 6 (ADR-0004) | governance | F0 |
| DEC-02 | Vedtatt: HTTP-kjerne; produkt/modul NetworkKit, én bibliotekmodul (ADR-0003) | governance | F0 |
| DEC-03 | Vedtatt: Teisrud Development AS; proprietær policy (ADR-0002) | governance | F0 |
| DEC-04 | Vedtatt: HTTP-/respons-/feilkontrakt (ADR-0005) | governance | F0 |
| DEC-05 | Vedtatt: session-eierskap, 30/60-grenser, concurrency og shutdown (ADR-0006) | governance | F0 |
| DEC-06 | Vedtatt: sikkerhets-/auth-/lagrings-/nettverkspolicy (ADR-0007) | governance | F0 |
| DEC-07 | Vedta CI-verktøy, matrise og kostnadsramme | governance | F0 |
| NK-01 | HTTP og forespørsler | core | F1 |
| NK-02 | Endpoints og URL-bygging | core | F1 |
| NK-03 | Respons og databehandling | core | F1 |
| NK-04 | Feilhåndtering | core | F1 |
| NK-05 | Autentisering | extension | F3 |
| NK-06 | Sikkerhet og TLS | extension | F6 |
| NK-07 | Retry og robusthet | extension | F3 |
| NK-08 | Caching | extension | F3 |
| NK-09 | Filoverføring | extension | F4 |
| NK-10 | WebSocket og sanntid | extension | F5 |
| NK-11 | TCP, UDP og lokalt nettverk | research | F6 |
| NK-12 | Nettverksstatus | extension | F3 |
| NK-13 | Logging og observability | core | F2 |
| NK-14 | Concurrency og livssyklus | core | F2 |
| NK-15 | Konfigurasjon | core | F1 |
| NK-16 | Testing og mocking | core | F1 |
| NK-17 | Ytelse og optimalisering | extension | F3 |
| NK-18 | Personvern og databeskyttelse | core | F2 |
| NK-19 | Apple-plattformintegrasjon | extension | F4 |
| NK-20 | Utvikleropplevelse og API-design | core | F2 |
| GATE-00 | Godkjenn arkitekturport og klarsignal før kode | governance | F0 |
| REL-01 | Verifiser første stabile kjernerelease | governance | F2 |
| OPS-01 | Kontroller GitHub-oppsett og team-overgang | governance | F0 |

## Vedtatt scope

[V1_SCOPE.md](V1_SCOPE.md) avgrenser inkludert og utsatt omfang for alle 20 domener. Domene-epics holdes åpne til valgt arbeid er levert. DEC-04 / ADR-0005 fastsetter [HTTP-kontrakten](HTTP_API_CONTRACT.md); DEC-05 / ADR-0006 fastsetter [livssykluskontrakten](CONCURRENCY_AND_LIFECYCLE.md). DEC-06 / ADR-0007 fastsetter [sikkerhets-/nettverkspolicyen](SECURITY_AND_NETWORK_POLICY.md); konkrete verifikasjonsoppgaver kreves fortsatt før Ready.

## Før en epic kan planlegges som utvikling

Bryt ned funksjonsfamiliene i separate delissues med kontrakt, testplan og spesifikasjonspunkt. Merk utelatelser eksplisitt. Bruk issue-avhengigheter der tilgjengelig og lenker i body uansett; en lenke er ikke en automatisk merge-sperre. Ingen domener er forhåndslukket eller fremstilt som levert.
