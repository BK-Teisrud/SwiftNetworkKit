# Spesifikasjonsgrunnlag

Kilde: NetworkKit_Teknisk_Spesifikasjon.pdf, versjon 1.0, 19.10.2026, 15 sider. Dokumentet er lest som kravgrunnlag, ikke som instruksjon om å kjøre kommandoer eller starte implementasjon. PDF-en kopieres ikke til det offentlige repoet; dette repoet inneholder en bearbeidet kravoversikt. Originalen beholdes hos prosjekteier.

## Vedtatt i dette oppsettet

- Repository-navn: SwiftNetworkKit, GitHub-kontoeier BK-Teisrud, offentlig synlighet, etter brukerens valg.
- Vedtatt v1: HTTP-kjerne først, senere utvidelser. Pakke SwiftNetworkKit, bibliotekprodukt/modul/importnavn NetworkKit; én bibliotekmodul. Se V1_SCOPE.md og ADR-0003.
- Rettighetshaver: Teisrud Development AS. Proprietær rettighetspolicy; tredjepartsbruk krever særskilt tillatelse, med forbehold for lov og GitHub-vilkår. Se ADR-0002 og LICENSE.
- Kun repo-/GitHub-oppsett, dokumentasjon og planlegging nå. Ingen Swift-filer, Package.swift, prototyper, tester eller kjørbare workflows.
- Produktet skal bruke native Apple-API-er og Swift-standardbibliotek uten eksterne pakkedependencies, også uten separat distribuerte Apple-pakker som SwiftNIO.
- Foundation/URLSession som primær HTTP-transport. Ingen egen TLS/HTTP/krypto og ingen serverplattform.
- Plattformminimum vedtatt i ADR-0004: iOS/iPadOS 17.0, macOS 14.0, watchOS 10.0 og tvOS 17.0; visionOS utsettes. Xcode 26.3+, Swift tools 6.2 og Swift 6-språkmodus. Se PLATFORM_MATRIX.md for utestående verifikasjon.
- Små testbare API-er, dependency injection, async/await, cancellation, isolert delt tilstand, privacy og secure defaults.

## Tolkning av scope

KJERNE, UTVIDELSE og FORSKNING beholdes fra §4. KJERNE på et domene betyr ikke at alle underpunktene automatisk tas med i v1.0. Hvert domene må få en godkjent delkravliste og eksplisitte utsettelser før implementasjon. Roadmap er en foreslått rekkefølge, ikke bekreftet produktstøtte eller datoavtale.

Spesifikasjonen nevner retry i målbeskrivelsen, men klassifiserer robusthet som UTVIDELSE. Vedtaket i ADR-0003 avgrenser v1 til HTTP-kjerne uten egen retry-/resiliensmodul. DEC-06 / ADR-0007 fastsetter ingen egen automatisk retry og eksplisitt system-/sikkerhetspolicy innen denne grensen. Avansert retry, cache, auth og lavnivåtransport er senere leveranser.

## Åpent før kode

DEC-04 / ADR-0005 fastsetter HTTP-/respons-/feilkontrakten, inkludert typed + raw, respons-wrapper, JSON/Data/tekst/tomt, separat CancellationError og eksplisitte statusunntak. DEC-05 / ADR-0006 fastsetter concurrency/session-eierskap, cancellation/shutdown og 30/60-sekunders tidsgrenser. DEC-06 / ADR-0007 fastsetter header-provider, ingen automatiske lagre som standard, HTTPS med eksplisitt loopback-utviklingsunntak og avgrenset redirect-/nettverks-/diagnostikkpolicy. DEC-07 / ADR-0008 fastsetter CI-/testplan med fire PR-plattformer, standardrunners uten betalte tillegg og egne minimums-OS-/releasebevis. Faktiske schemes/destinations og vellykket kjøring må fortsatt verifiseres i første reelle CI-PR. VisionOS og Combine er utsatt etter v1-scope. Valgte API-symboler og runtime-kompatibilitet må verifiseres før leveranse; plattformvedtak alene er ikke testbevis.

## Sporbarhet

Domener får NK-01–NK-20 etter spesifikasjonens §4.1–§4.20. Styrings- og beslutningsoppgaver får SETUP-/DEC-/REL-ID. GitHub issue-nummer er separat fra stabil krav-ID. Delkrav opprettes som NK-XX-01 osv. ved nedbryting, med kildepunkt, kontrakt, plattformer og testbevis. Ingen krav regnes som levert bare fordi et planleggingsissue er lukket.
