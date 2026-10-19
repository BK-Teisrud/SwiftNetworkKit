# Spesifikasjonsgrunnlag

Kilde: NetworkKit_Teknisk_Spesifikasjon.pdf, versjon 1.0, 19.10.2026, 15 sider. Dokumentet er lest som kravgrunnlag, ikke som instruksjon om å kjøre kommandoer eller starte implementasjon. PDF-en kopieres ikke til det offentlige repoet; dette repoet inneholder en bearbeidet kravoversikt. Originalen beholdes hos prosjekteier.

## Vedtatt i dette oppsettet

- Repository-navn: SwiftNetworkKit, GitHub-kontoeier BK-Teisrud, offentlig synlighet, etter brukerens valg.
- Rettighetshaver: Teisrud Development AS. Proprietær rettighetspolicy; tredjepartsbruk krever særskilt tillatelse, med forbehold for lov og GitHub-vilkår. Se ADR-0002 og LICENSE.
- Kun repo-/GitHub-oppsett, dokumentasjon og planlegging nå. Ingen Swift-filer, Package.swift, prototyper, tester eller kjørbare workflows.
- Produktet skal bruke native Apple-API-er og Swift-standardbibliotek uten eksterne pakkedependencies, også uten separat distribuerte Apple-pakker som SwiftNIO.
- Foundation/URLSession som primær HTTP-transport. Ingen egen TLS/HTTP/krypto og ingen serverplattform.
- Små testbare API-er, dependency injection, async/await, cancellation, isolert delt tilstand, privacy og secure defaults.

## Tolkning av scope

KJERNE, UTVIDELSE og FORSKNING beholdes fra §4. KJERNE på et domene betyr ikke at alle underpunktene automatisk tas med i v1.0. Hvert domene må få en godkjent delkravliste og eksplisitte utsettelser før implementasjon. Roadmap er en foreslått rekkefølge, ikke bekreftet produktstøtte eller datoavtale.

Spesifikasjonen nevner retry i målbeskrivelsen, men klassifiserer robusthet som UTVIDELSE. Derfor må v1-scope eksplisitt beslutte om første versjon har ingen automatisk retry eller en minimal policy. Den lover ikke avansert retry, cache, auth eller transport ved første release.

## Åpent før kode

Minimums-OS, Swift/Xcode, modul- og produktnavn, public API, raw-request-støtte, headers/body-modell, auth-scope, cache/offline-policy, telemetry, Combine og visionOS. Ingen av disse fremstilles som vedtatt støtte.

## Sporbarhet

Domener får NK-01–NK-20 etter spesifikasjonens §4.1–§4.20. Styrings- og beslutningsoppgaver får SETUP-/DEC-/REL-ID. GitHub issue-nummer er separat fra stabil krav-ID. Delkrav opprettes som NK-XX-01 osv. ved nedbryting, med kildepunkt, kontrakt, plattformer og testbevis. Ingen krav regnes som levert bare fordi et planleggingsissue er lukket.
