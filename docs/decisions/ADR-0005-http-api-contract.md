# ADR-0005: HTTP-, respons- og feilkontrakt i v1

Dato: 2026-10-19. Status: Godkjente hovedvalg fra prosjekteier; standarddetaljer dokumentert som konkretisering av disse valgene.
Oppgave: [DEC-04 / #4](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/4).

## Godkjenning og kontekst

Prosjekteier valgte i chatten:

1. Typesikre endepunkter som standard, med rå URLRequest ved behov under samme klientregler.
2. Dekodet verdi sammen med HTTP-status og responsheaders.
3. JSON, rå Data/tekst og eksplisitt tomt svar i v1; streaming og multipart utsettes.
4. Strukturerte feil med separat CancellationError.
5. HTTP 200–299 som standard, med eksplisitte unntak per kall.

Disse valgene konkretiseres i [HTTP_API_CONTRACT.md](../planning/HTTP_API_CONTRACT.md), inkludert URL-, header-, body- og valideringsregler. Ingen Swift-kode eller offentlig symbolimplementasjon er opprettet.

## Beslutning

Én HTTP-klientkontrakt håndterer både typed endpoint og rå request. En injiserbar NetworkClient-grense, en konkret APIClient, Endpoint med tilknyttet responstype, NetworkResponse og NetworkError er de planlagte offentlige konseptnavnene. NetworkConfiguration, HTTPMethod og en eksplisitt EmptyResponse inngår i kontraktsmodellen. Eksakte Swift-signaturer fastsettes ved implementasjon innen disse kontraktene og må gjennom API-review; denne ADR-en inneholder ingen kodeskisse.

Responsstrategi velges uttrykkelig: JSON, Data, tekst eller tomt svar. Dette unngår at Data/String feilaktig går gjennom JSON-dekoding bare fordi typene også kan ha Codable-konformitet. Rå request er en byggemåte, ikke en bypass av status-, decoding-, auth-, redirect- eller cancellationregler.

CancellationError er en egen kontrollflyt og pakkes ikke inn som vanlig NetworkError. Skillet mellom request-timeout, total deadline og session-eierskap konkretiseres i DEC-05. Auth-/redirect-/cache-/nettverkspolicy konkretiseres i DEC-06; hovedscope fra ADR-0003 kan ikke utvides gjennom disse detaljbeslutningene.

## Alternativer og begrunnelse

- Bare typed endpoints ville gjort v1 mindre fleksibel ved uvanlige HTTP-kontrakter. Prosjekteier valgte også raw URLRequest.
- Bare dekodet verdi ville skjult status og headers som konsumenter kan trenge. Prosjekteier valgte respons-wrapper.
- Bare JSON ville utelatt enkle tekst-/binær-/tom-responser. Prosjekteier valgte disse enkle variantene uten et generelt format-/streamingrammeverk.
- En samlet feiltype med cancellation kunne vært enklere å liste i ett sted. Prosjekteier valgte separat CancellationError.
- Fast 2xx-regel kunne vært mindre konfigurerbar. Eksplisitte lokale unntak ble valgt fremfor en global skjult endring av suksessbegrepet.

## Plattformkontroll og bevis

Foundation-grunnlaget er kontrollert gjennom offentlige Apple-kilder og availability-deklarasjoner i lokal SDK 26.2. URLSession.data(for:delegate:), URLComponents, URLQueryItem og JSONEncoder/JSONDecoder har deklarert availability innen de vedtatte minimumene. Dette er en avgrenset deklarasjonskontroll i macOS-SDK-ens Swift-interface, ikke kryssplattformbygg eller runtime-bevis. Se den oppdaterte plattformmatrisen for omfanget.

Testkontrakter for suksess, statusunntak, tomme svar, URL-/headerhåndtering, codingfeil og cancellation er beskrevet. De er ikke kjørt; ingen pakke eller tester finnes. Domene-epics lukkes først ved faktisk levering. DEC-05–DEC-07 og F0-porten forblir åpne.

## Kilder

- [Apple: URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- [Apple: URLComponents](https://developer.apple.com/documentation/foundation/urlcomponents)
- [Apple: CancellationError](https://developer.apple.com/documentation/swift/cancellationerror)
- Lokal SDK: Foundation.framework/Modules/Foundation.swiftmodule/x86_64-apple-macos.swiftinterface, SDK 26.2; Xcode 26.3 (17C529).
