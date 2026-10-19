# ADR-0003: HTTP-kjerne i v1 og navn på pakke, produkt og modul

Dato: 2026-10-19. Status: Godkjent av prosjekteier i chatten.
Oppgave: [DEC-02 / #2](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/2).

## Kontekst og godkjenning

Prosjekteier valgte «HTTP-kjerne først; øvrige moduler kommer senere» og deretter «Repo SwiftNetworkKit, men produkt/importnavn NetworkKit, én modul». Dette fastsetter leveransegrensen og navnene. Det er ikke klarsignal til implementasjon.

## Beslutning

| Rolle | Vedtatt navn / grense |
| --- | --- |
| GitHub-repository | SwiftNetworkKit |
| Swift Package-navn | SwiftNetworkKit |
| Bibliotekprodukt | NetworkKit |
| Bibliotekmodul / target / importnavn | NetworkKit |
| Antall bibliotekmoduler i v1 | Én |

Navnene skal senere brukes konsekvent i pakkemanifest, dokumentasjon og konsumenteksempler. Pakken vil tilby produktet NetworkKit; konsumenter vil importere NetworkKit. Ingen manifest, target eller importkode opprettes nå. Egne testtargets er tillatt senere og teller ikke som ekstra distribuerte bibliotekmoduler. Et separat testhjelperprodukt inngår ikke i v1.

Første stabile versjon skal gi en avgrenset HTTP-kjerne med typesikre kall, JSON, forutsigbare feil, timeout/cancellation, trygg logging og deterministisk testing. Nødvendig konfigurasjon, dependency injection, personvern, dokumentasjon og plattformtilgjengelighet følger kjernen fra starten. URLSession er primær transport og sikre systemstandarder gjelder.

Den normative leveransegrensen står i [V1_SCOPE.md](../planning/V1_SCOPE.md). Detaljer i offentlige kontrakter og policygrenser avgjøres fortsatt i DEC-04–DEC-06. Minimums-OS og verktøy velges i DEC-01 og DEC-07.

## Alternativer og avveininger

- SwiftNetworkKit som både repo og importnavn ville gitt ett navn overalt. Prosjekteier foretrekker NetworkKit som produkt-/importnavn.
- Flere bibliotekmoduler fra starten ville gitt separate produkter, men flere avhengighets- og API-grenser før behovet er dokumentert. Ikke valgt.
- Retry/cache eller hele funksjonskatalogen før første stabile versjon ville økt første leveranse. Prosjekteier valgte HTTP-kjerne først.

## Konsekvenser

F0 → F1 → F2 er veien til v1. F3–F6 beholdes som mulige senere leveranser. Det finnes ingen lovet dato for v1 eller senere moduler. Domene-epics beholder klassifiseringen fra spesifikasjonen, men er ikke automatisk løfte om alle underpunkter i v1.

Interne typer brukes for kompleksitet som ikke trenger et offentlig kontraktsløfte. Separate moduler vurderes senere ved dokumentert behov, med eksplisitt vurdering av avhengigheter og kompatibilitet. Forslag som NetworkKitAuth og NetworkKitTesting i originalspesifikasjonen er ikke vedtatte v1-produkter.

Deloppgaver opprettes før utviklingsarbeid blir Ready, etter at relevante kontrakter er vedtatt. Å lukke DEC-02 betyr at scope og modulvalg er besluttet; det betyr ikke at domene-epics er levert eller at de øvrige F0-beslutningene er ferdige.

ADR-0001 beholdes som historikk; denne ADR-en avgjør navn og scope som der var åpne.
