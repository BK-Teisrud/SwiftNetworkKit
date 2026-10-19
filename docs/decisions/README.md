# Beslutningslogg

| ID | Tema | Status |
| --- | --- | --- |
| ADR-0001 | Repo, arbeidsflyt og scope for oppsett | Godkjent for repooppsett |
| [ADR-0002](ADR-0002-ownership-and-rights.md) | Rettighetshaver og proprietær rettighetspolicy | Godkjent av prosjekteier |
| [ADR-0003](ADR-0003-v1-scope-and-naming.md) | HTTP-kjerne og navn på pakke, produkt og modul | Godkjent av prosjekteier |
| [ADR-0004](ADR-0004-platforms-and-toolchain.md) | Plattformminimum og verktøygrunnlag | Godkjent av prosjekteier |
| DEC-01 | Minimums-OS og Swift/Xcode/SDK-matrise | Godkjent: fire plattformer, Xcode 26.3+, Swift tools 6.2, Swift 6; ADR-0004 |
| DEC-02 | v1-scope, modulnavn og targetgrenser | Godkjent: HTTP-kjerne først; NetworkKit, én bibliotekmodul; ADR-0003 |
| DEC-03 | Lisens og rettighetshaver | Godkjent: Teisrud Development AS; proprietær policy, se ADR-0002 |
| [ADR-0005](ADR-0005-http-api-contract.md) | HTTP-, respons- og feilkontrakt | Hovedvalg godkjent av prosjekteier; standarddetaljer dokumentert |
| DEC-04 | Endpoint, raw request, headers/body og feilkontrakt | Vedtatt: typed + raw, respons-wrapper, JSON/Data/tekst/tomt, separat cancellation; ADR-0005 |
| DEC-05 | Cancellation, clocks, session-eierskap og concurrency | Åpen |
| DEC-06 | Auth, retry, cache, privacy og sikkerhetsgrenser | Åpen |
| DEC-07 | Offisielle verktøy, CI-budsjett og forsyningskjede | Åpen |

Bruk [malen](TEMPLATE.md). En foreslått ADR gir ikke klarsignal til implementasjon. Godkjenning krever eierens eksplisitte beslutning i tilhørende issue/PR. Endre ikke historiske beslutninger uten spor; erstatt dem med ny ADR.
