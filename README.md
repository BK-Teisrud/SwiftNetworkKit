# SwiftNetworkKit

Native nettverksbibliotek for Apple-plattformer, planlagt som Swift Package uten eksterne pakkedependencies.

**Status: planlegging. Ingen bibliotekskode, Swift Package, tester eller produktrelease er opprettet.** Repoet inneholder prosjektgrunnlag og GitHub-oppsett. Ikke legg dette til som en fungerende dependency.

## Prosjektgrunnlag

Foundation/URLSession er primær HTTP-transport. Swift Concurrency, injiserbare tjenester, system trust og personverntrygge standardverdier er førende. Network.framework vurderes for særskilte lavnivåbehov. Ingen egen HTTP-, TLS- eller kryptografistakk og ingen backend som produkt.

Repoet heter **SwiftNetworkKit**. Arbeidsnavnet **NetworkKit** og targetnavnene i spesifikasjonen er foreløpige; modulnavn besluttes separat.

## Dokumentasjon

- [Oppsettsstatus og verifikasjon](docs/governance/SETUP_STATUS.md)
- [Alle GitHub-innstillinger og regler](docs/governance/GITHUB_CONFIGURATION.md)
- [Arbeidsflyt og prosjektstyring](docs/planning/PROJECT_MANAGEMENT.md)
- [Roadmap og leveranseporter](docs/planning/ROADMAP.md)
- [Kravsporbarhet og backlog](docs/planning/BACKLOG.md)
- [Spesifikasjonsgrunnlag](docs/planning/SPECIFICATION_BASELINE.md)
- [Beslutningslogg](docs/decisions/README.md)
- [Kvalitet og teststrategi](docs/governance/QUALITY.md)
- [Release- og kompatibilitetspolicy](docs/governance/RELEASE_POLICY.md)
- [Risikoregister](docs/planning/RISKS.md)
- [Bidrag](CONTRIBUTING.md), [sikkerhet](SECURITY.md), [forvaltning](GOVERNANCE.md)

## Plattform og lisens

Mål: iOS/iPadOS, macOS, watchOS og tvOS. visionOS er en mulig utvidelse. Minimums-OS, Swift- og Xcode-versjoner er ikke vedtatt. Det finnes ingen verifisert støttematrise ennå.

Lisens er ikke valgt. Offentlig synlighet gir ikke i seg selv en åpen kildekode-lisens. Prosjektet gir foreløpig ingen særskilt lisens til bruk, endring eller redistribusjon. Avklar rettighetshaver og lisens før eksterne kodebidrag og første produktrelease.
