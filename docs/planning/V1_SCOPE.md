# Leveransegrense for første stabile versjon

Status: Godkjent hovedscope og modulvalg 2026-10-19, se [ADR-0003](../decisions/ADR-0003-v1-scope-and-naming.md). Ingen implementasjon finnes.

Repo og pakkenavn er SwiftNetworkKit. Det distribueres ett bibliotekprodukt og én bibliotekmodul med navnet NetworkKit. Konsumentens importnavn blir NetworkKit. Egne tester kan senere få et testtarget; dette er ikke en ekstra bibliotekmodul.

## Brukerflyt som v1 skal dekke

En vertapp konfigurerer og injiserer klienten, definerer et typesikkert HTTP-kall, sender forespørselen gjennom URLSession og får et JSON-resultat eller en forståelig feil. Operasjonen har definerte timeout- og cancellationregler. Logging er personverntrygg. Oppførselen kan testes deterministisk uten offentlig nettverk.

Dette inkluderer nødvendige grunnkrav til URL-/requestbygging, konfigurasjon, system trust, personvern, session-livssyklus og dokumentert plattformstøtte. Ingen avansert modul er nødvendig for denne brukerflyten.

## Sporbar leveransegrense

Tabellen avgrenser domener på scope-nivå. [HTTP_API_CONTRACT.md](HTTP_API_CONTRACT.md) / ADR-0005 presiserer HTTP-/respons-/feilkontrakten. [CONCURRENCY_AND_LIFECYCLE.md](CONCURRENCY_AND_LIFECYCLE.md) / ADR-0006 presiserer concurrency og session-eierskap. DEC-06 presiserer gjenværende sikkerhets-/nettverkspolicy før Ready. En rad er ikke en garanti for at alle punktene i originaldomenet er valgt.

| Domene | Inngår i v1 | Utsatt / ingen leveranseforpliktelse i v1 |
| --- | --- | --- |
| NK-01 HTTP | Requestutførelse, definerte timeout-/cancelregler og nødvendige HTTP-operasjoner for kjernen | Generelt interceptorrammeverk og avansert transportstyring |
| NK-02 Endpoints | Typesikre kall, injisert baseURL, sikker URL-/parameterbygging | Automatisk API-versjonshåndtering og avanserte encodingvarianter |
| NK-03 Respons | JSON, rå Data/tekst, eksplisitt tomt svar, status-/responsvalidering og respons-wrapper | Streaming, AsyncSequence-responser og eget rammeverk for alternative dataformater |
| NK-04 Feil | Forståelige transport-, HTTP-, encoding-/decoding-, timeout- og cancellationkontrakter | Retryklassifisering for en fremtidig resiliensmotor |
| NK-05 Autentisering | Ingen egen auth-modul; vertappens nødvendige integrationsgrense avgjøres i DEC-04/06 | Keychain-adapter, login, OAuth/OIDC, token refresh og flerprofilhåndtering |
| NK-06 Sikkerhet | HTTPS/system trust og trygg håndtering av credentials som grunnkrav | Pinning, mTLS, signering/HMAC, egne trust-policyer og egen sikkerhetsmodul |
| NK-07 Resiliens | Definerte feil, timeout og cancellation | Egen retrypolicy/-motor, circuit breaker, rate limiting og køsystem |
| NK-08 Cache | Bevisst forhold til URLSessions systempolicy, avklares i DEC-06 | Egen cachemodul, offline-/TTL-/fallbackstrategier og stale-while-revalidate |
| NK-09 Overføringer | Vanlige HTTP-payloads innen kjernens kontrakt | Filoverførings-API, multipart, progress, resume og background transfers |
| NK-10 Sanntid | Ikke del av HTTP-kjernen | WebSocket og reconnect |
| NK-11 Lavnivåtransport | Ikke del av HTTP-kjernen | TCP/UDP, Bonjour, QUIC-API, listener og multicast |
| NK-12 Nettverksstatus | Feil fra faktisk HTTP-operasjon håndteres | Egen NWPathMonitor-tjeneste og statusstrøm |
| NK-13 Logging | Trygg logging/diagnostikk med dataminimering og testbar grense | Detaljert task-metrics-/signpostsystem og utvidet observabilityprodukt |
| NK-14 Concurrency | async/await, nødvendig Sendable/isolation, cancellation og definert session-eierskap | Batch-API, generell deduplisering og strøm-/kørammeverk |
| NK-15 Konfigurasjon | Injiserbar klient/sessionkonfigurasjon og definerte requeststandarder | Avanserte mutable policysystemer og modulspesifikke policyer |
| NK-16 Testing | Deterministiske tester, injiserbar transport og negative/cancellationtester for valgt kjerne | Eget distribuert NetworkKitTesting-produkt og tester for utsatte moduler |
| NK-17 Ytelse | Rimelig ressursbruk og representative målinger som del av kvalitet | Egen ytelsesmodul, coalescing og optimaliseringsprosjekt uten målt behov |
| NK-18 Personvern | Ingen sensitive logger/ekstern telemetri som standard og dokumentert håndtering av sessiondata | Lagrings-/slette-API-er for egne cache-, auth- og overføringsmoduler |
| NK-19 Plattform | Faktisk tilgjengelighet, guards og testmatrise for valgte plattformer | Background-, lokalnett-, App Groups- og andre avanserte plattformintegrasjoner |
| NK-20 Utvikleropplevelse | Lite dokumentert API, HTTP-/JSON-/feil-/injeksjons-/testguider, DocC og releasekrav | Eksempler og API-er for utsatte moduler; Combine-adapter |

## Fortsatt åpne kontraktsspørsmål

DEC-04 / ADR-0005 vedtar typed endpoints pluss rå URLRequest, JSON/Data/tekst/EmptyResponse, respons-wrapper, strukturerte feil med separat CancellationError og 2xx som standard med eksplisitte kallunntak. HTTP_API_CONTRACT.md konkretiserer metoder, URL/query, headerprioritet, body og validering. DEC-05 / ADR-0006 vedtar gjenbrukt egen session med injeksjonsmulighet, isolert state, cancellation/shutdown og 30 sekunder inaktivitet / 60 sekunder samlet budsjett med kontrollert klokke. DEC-06 avgjør auth-integrasjon, credentials ved redirects og konkret system-cache-/nettverkspolicy. Disse oppgavene kan ikke utvide v1 til avanserte moduler uten nytt scopevedtak.

OS-minimum er vedtatt i DEC-01 / ADR-0004: iOS/iPadOS 17, macOS 14, watchOS 10 og tvOS 17. Xcode 26.3+, Swift tools 6.2 og Swift 6-språkmodus er valgt. Se [plattformmatrisen](PLATFORM_MATRIX.md). Konkrete API-symboler og faktisk runtime-kompatibilitet er fortsatt ikke verifisert. Ingen avgrensning i tabellen fritar kjernen fra nødvendige sikkerhets-, personvern- eller plattformkrav. Eksempelvis er avansert sikkerhetsmodul utsatt, mens system trust er et grunnkrav i v1.

## Ferdig og endringsstyring

V1 krever oppfylte valgte kontrakter, reelle tester/CI, dokumentert plattformstøtte, sikkerhets-/personverngjennomgang og releaseporten REL-01. Fase 0 og prosjekteierens uttrykkelige klarsignal kreves før implementasjon. Funksjoner legges ikke til i v1 bare fordi de står i spesifikasjonen; scopeendringer må ha begrunnelse og vedtak.
