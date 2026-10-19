# HTTP-, respons- og feilkontrakt for v1

Status: Planlagt kontrakt, 2026-10-19, se [ADR-0005](../decisions/ADR-0005-http-api-contract.md). Prosjekteier har valgt hovedalternativene; reglene under konkretiserer dem. Ingen implementasjon eller beståtte produkttester finnes.

## Offentlig modell og de to inngangene

| Konsept | Kontrakt |
| --- | --- |
| NetworkClient / APIClient | Injiserbar klientgrense og konkret URLSession-basert klient; ingen global singleton som eneste bruksmåte |
| Endpoint | Beskriver HTTP-kall, responstype/-strategi og eksplisitte kallvalg |
| NetworkConfiguration | Klientens baseURL, standardheaders og øvrige konfigurasjonsvalg; samtidighet og snapshots avgjøres i DEC-05 |
| HTTPMethod | GET, POST, PUT, PATCH, DELETE, HEAD og OPTIONS; også en eksplisitt, gyldig HTTP-metodestreng |
| NetworkResponse | Dekodet verdi, HTTP-status og responsheaders; metadata finnes også for Data/tekst/tomt svar |
| EmptyResponse | Markerer uttrykkelig at det ikke skal dekodes en responsmodell |
| NetworkError | Strukturerte vanlige feil; cancellation holdes separat som CancellationError |

Typed endpoint er standard. Rå URLRequest tilbys som alternativ for kallbygging; konsumenten velger også her en responsstrategi og eventuelt statusunntak. Requestbygging er allerede utført i raw-tilfellet, men validering og samme klientpipeline gjelder fortsatt. Ustøttede inputvarianter avvises, de ignoreres ikke.

Modellen kan håndtere JSON-modeller, Data og tekst uten at alle responstyper påtvinges én generisk JSON-/Decodable-strategi. Ingen eksakte Swift-signaturer, navn på enum-cases eller kildekode er vedtatt her; offentlige konseptnavn og adferd ligger til grunn for senere API-review.

## URL og parametere

BaseURL er eksplisitt injisert og må være en gyldig absolutt HTTP(S)-URL; sikkerhetspolicyen i DEC-06 avgjør hvilke slike URL-er som faktisk er tillatt. En relativ endpoint-path kan ikke utilsiktet erstatte scheme, host eller port. Fragments og URL-userinfo brukes ikke som requestparametere/credential-kanal.

Path bygges av eksplisitte segmenter, med encoding per segment. Segmentdata må ikke tolkes som separatorer, query eller ny origin. Punkt-/traversalsegmenter og malformed input må håndteres eksplisitt med valideringsfeil der de ellers ville endret tiltenkt path. Ferdig prosentkodet tekst er ingen standardinngang; klienten skal unngå dobbel encoding og prosesskrasj på ugyldig encoding.

Query er en ordnet liste med navn og valgfrie verdier. Rekkefølge og gjentatte navn beholdes; arrays uttrykkes som gjentatte navn. En utelatt parameter tas ikke med, nil-verdi betyr navn uten likhetstegn, og tom streng betyr eksplisitt tom verdi. Ingen automatisk bracket-/comma-/form-encoding i v1. Spesialkontrakter kan bygges som rå request, med samme URL-/sikkerhetsvalidering.

URL-bygging skal være komponentbasert, ikke usikker strengkonkatenering. Ingen garanti om manuell HTTP-versjonsforhandling gis.

## Headers

Headernavn sammenlignes uten hensyn til store/små bokstaver. Ett eksplisitt requestvalg erstatter klientens default med samme navn; omvendt prioritet er ikke tillatt. Ugyldige headernavn og CR/LF i input skal gi invalidRequest før nettverk. Motstridende duplikater skal ikke vilkårlig sammenføyes.

JSON får application/json som standard Content-Type, og tekst får text/plain med UTF-8. For Data velges content type eksplisitt, med application/octet-stream som standard når ingen er angitt. Eksplisitt Content-Type fra kallet har forrang, men må være et bevisst kallvalg; den endrer ikke automatisk body-encoder. Ingen body betyr at klienten ikke legger til en body-content-type av seg selv.

Transportstyrte felter som Content-Length skal ikke beregnes manuelt av biblioteket. Endelig systembehandling av slike felter følger URLSession. Auth-provider og redirect-prioritet fastsettes i DEC-06 uten å innføre et generelt interceptorrammeverk.

Responsheaders skal tilby case-insensitive oppslag. Bevar verdier slik URLSession eksponerer dem; ikke lov opprinnelig casing, rå headerrekkefølge eller gjentatte wire-headere som systemet allerede har slått sammen. Sensitive metadata kan være tilgjengelige for vertappen uten dermed å være tillatt i logger eller feiltekst.

## Body og responsstrategier

| Variant | Request | Respons |
| --- | --- | --- |
| JSON | Encodable-baserte payloads med konfigurerbar Apple JSONEncoder-strategi | Eksplisitt valgt modell med Apple JSONDecoder-strategi |
| Data | Rå bytepayload med Content-Type | Rå Data uten JSON-dekoding |
| Tekst | UTF-8-kodet tekst | UTF-8 som standard; ustøttet eller ugyldig deklarert encoding gir decodingfeil, ikke stille datatap |
| Tomt | Request uten body | Eksplisitt EmptyResponse, uten JSON-dekoding |

Encoder-/decoderstrategier velges før utførelse. Ingen mutasjon av en delt instans midt i et request er en del av kontrakten; eierskap og samtidighet fastsettes i DEC-05. Et generelt custom-decoder-/pluginrammeverk inngår ikke.

Status valideres før normal responsdekoding. HEAD/204 kan håndteres med eksplisitt tom-responskontrakt. Dersom en JSON-modell er valgt og body er tom, er det en decoding-/kontraktfeil; klienten lager ikke et kunstig standardobjekt. Tom Data og tom tekst er tillatt når disse responsstrategiene er valgt. En eksplisitt tom respons dekoder ingen payload og returnerer fortsatt status/headers.

Valgt JSON-strategi aksepterer manglende Content-Type, men hvis serveren oppgir Content-Type må den angi application/json eller en subtype med +json. Et annet oppgitt format gir invalidResponse før JSON-dekoding. Raw Data-strategien påtvinges ingen JSON-Content-Type. V1 inkluderer ikke et generelt system for å slå av validering; en server med feilaktig content type kan håndteres gjennom rå Data og eksplisitt appstyrt behandling.

Multipart, body streams, filbaserte upload/download-API-er, progress, streaming, XML-/andre formater og WebSocket er utsatt. En rå URLRequest med httpBodyStream skal avvises som utenfor v1-kontrakten; den er ingen bakvei til streamingstøtte. Hele Data-responser lastes i minnet; v1 skal ikke presenteres som et storfil-/streamingbibliotek.

## HTTP-status og pipeline

Standard er 200–299. Et kall kan eksplisitt erstatte standarden med et ikke-tomt, gyldig sett/område av HTTP-statuskoder. Valget tilhører kallet og må dokumenteres; det finnes ingen skjult global «aksepter alt»-policy. En akseptert status hopper ikke over bodykontrakt eller sikkerhetsregler.

Status gjelder den endelige HTTP-responsen som URLSession gir klienten etter gjeldende redirect-policy. Å akseptere en status gir ikke i seg selv kontroll over URLSessions redirects; det avklares i DEC-06.

Planlagt rekkefølge: valider input → bygg/valider request og encode valgt body → anvend konfigurasjon og vedtatte sikkerhetsgrenser → utfør URLSession → bekreft HTTP-respons → valider status og eventuell content type → håndter valgt responsstrategi → returner NetworkResponse. Cancellation gjelder gjennom operasjonen. Ingen egen retrymotor eller token-refresh-syklus inngår i denne kontrakten.

## Feilkontrakt

| Kategori | Betydning |
| --- | --- |
| invalidRequest | Ugyldig URL, metode, header, konfigurasjon eller ustøttet requestvariant; ingen nettverksutførelse ved lokal avvisning |
| transport | System-/nettverksfeil; underliggende URLError-kode/årsak beholdes der relevant, inkludert trust-/TLS-feil uten credential-dump |
| httpStatus | Endelig HTTP-status er utenfor det eksplisitt godkjente settet; status og nødvendige metadata beholdes |
| invalidResponse | Responsen er ikke HTTP eller bryter responskontrakten, eksempelvis oppgitt feil Content-Type |
| encoding | Requestbody kunne ikke kodes; ingen request sendes |
| decoding | Godkjent HTTP-respons kunne ikke tolkes som valgt modell/tekst |
| timeout | Timeout skilt fra vanlig transportfeil; nøyaktige deadline-/sessionregler avgjøres i DEC-05 |
| CancellationError | Egen feil utenfor NetworkError for faktisk kansellering; normalisering av systemets cancel-signaler avgjøres i DEC-05 |

Ingen feilkategori gir automatisk rett til retry. Feiltekst og diagnostikk skal ikke inneholde tokens, cookies, rå URL-parametere eller payloads som standard. Et underliggende Error-/metadataobjekt er ikke en tillatelse til å logge alt. Policy for eventuell tilgang til HTTP-error-body avgjøres i DEC-06; ingen ubegrenset lagring eller inkludering i feiltekst velges her.

## Senere akseptansebevis

- Samme kontrakt for typed endpoint og rå request; raw kan ikke omgå sikkerhets- eller statusregler.
- GET/POST og øvrige valgte metoder, JSON/Data/tekst/EmptyResponse, 204/HEAD, valgte statusunntak og feil Content-Type.
- URL-segmenter med reservedtegn, query med duplikater/nil/tom verdi, malformed URL/encoding og forsøk på origin-/path-endring.
- Case-insensitive headere, default versus requestvalg, CR/LF-avvisning og eksplisitt Content-Type.
- Transportfeil, timeout, encoding/decodingfeil, invalidResponse og cancellation før/under operasjonen.
- Feil og logger uten sensitive standarddata; responseheaders håndteres med dokumenterte systembegrensninger.

Hvert tilfelle brytes ned til sporbare delissues før utvikling blir Ready. Ingen tester er kjørt. [Plattformmatrisen](PLATFORM_MATRIX.md), QUALITY.md, DEC-05/06 og DEC-07 angir videre krav; F0-porten må fortsatt godkjennes før kode.
