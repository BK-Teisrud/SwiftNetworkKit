# SwiftNetworkKit

Native nettverksbibliotek for Apple-plattformer, planlagt som Swift Package uten eksterne pakkedependencies.

**Status: planlegging. Ingen bibliotekskode, Swift Package, tester eller produktrelease er opprettet.** Repoet inneholder prosjektgrunnlag og GitHub-oppsett. Ikke legg dette til som en fungerende dependency.

## Prosjektgrunnlag

Foundation/URLSession er primær HTTP-transport. Swift Concurrency, injiserbare tjenester, system trust og personverntrygge standardverdier er førende. Network.framework vurderes for særskilte lavnivåbehov. Ingen egen HTTP-, TLS- eller kryptografistakk og ingen backend som produkt.

Repoet og pakken heter **SwiftNetworkKit**. Bibliotekproduktet, modulen og importnavnet blir **NetworkKit**, med én bibliotekmodul i v1. Første stabile versjon avgrenses til HTTP-kjernen; øvrige moduler kommer senere. Dette er vedtatt planlegging, ikke opprettede targets eller ferdig funksjonalitet. Se [v1-scope](docs/planning/V1_SCOPE.md) og [ADR-0003](docs/decisions/ADR-0003-v1-scope-and-naming.md).

## Dokumentasjon

- [Oppsettsstatus og verifikasjon](docs/governance/SETUP_STATUS.md)
- [Alle GitHub-innstillinger og regler](docs/governance/GITHUB_CONFIGURATION.md)
- [Arbeidsflyt og prosjektstyring](docs/planning/PROJECT_MANAGEMENT.md)
- [HTTP-, respons- og feilkontrakt](docs/planning/HTTP_API_CONTRACT.md)
- [Plattform- og verktøymatrise](docs/planning/PLATFORM_MATRIX.md)
- [Roadmap og leveranseporter](docs/planning/ROADMAP.md)
- [Kravsporbarhet og backlog](docs/planning/BACKLOG.md)
- [Spesifikasjonsgrunnlag](docs/planning/SPECIFICATION_BASELINE.md)
- [Beslutningslogg](docs/decisions/README.md)
- [Kvalitet og teststrategi](docs/governance/QUALITY.md)
- [Release- og kompatibilitetspolicy](docs/governance/RELEASE_POLICY.md)
- [Risikoregister](docs/planning/RISKS.md)
- [Bidrag](CONTRIBUTING.md), [sikkerhet](SECURITY.md), [forvaltning](GOVERNANCE.md)

## Plattform og lisens

Vedtatt for v1: **iOS/iPadOS 17+, macOS 14+, watchOS 10+ og tvOS 17+**. VisionOS utsettes. Utviklingsgrunnlag: **Xcode 26.3+, Swift tools 6.2 og Swift 6-språkmodus med streng samtidighetskontroll**. Se [plattformmatrisen](docs/planning/PLATFORM_MATRIX.md) og [ADR-0004](docs/decisions/ADR-0004-platforms-and-toolchain.md). Dette er vedtatte mål; ingen produktbygg eller runtime-tester er kjørt.

**Rettighetshaver: Teisrud Development AS. SwiftNetworkKit er proprietært.** Tredjepartsbruk krever særskilt skriftlig tillatelse fra selskapet, med forbehold for lovbestemte rettigheter og GitHubs gjeldende vilkår. Offentlig synlighet gir adgang til visning og forking gjennom GitHub, men prosjektet gir ingen ytterligere åpen kildekode-lisens eller generell tillatelse til bruk i apper.

Se [rettighetsnotisen](LICENSE) og [beslutningen om eierskap og rettigheter](docs/decisions/ADR-0002-ownership-and-rights.md). Be maintainer @BK-Teisrud om en bekreftet kontaktkanal for tillatelser; ikke del fortrolige opplysninger offentlig.
