# Kvalitetsporter og fremtidig teststrategi

Dette er krav til senere implementasjon. Ingen tester eller CI har kjørt for et bibliotek som ennå ikke finnes.

## Før implementasjon

Godkjent v1-scope, lisens, plattform-/verktøymatrise, API-/feilmodell, concurrency/cancellation og teststrategi. Hvert inkludert delkrav har input/output-kontrakt, normalflyt, feilflyt, tilgjengelighet og krav-ID.

## Pull request etter implementasjonsstart

- Bygg med valgt Swift/Xcode og strict concurrency; ingen udokumenterte warnings eller unchecked Sendable-unntak.
- Deterministiske unit-tester uten offentlig nettverk. Mock client, URLProtocol og kontrollert klokke der passende.
- Suksess, feil, encoding/decoding, tomme responser, timeout, cancellation, redirects og cleanup.
- Sikkerhetskritiske negative tester: redaction, credential-isolasjon, host-skifte og idempotens.
- Samtidighetstester for delt state, bounded køer og single-flight når slike funksjoner velges.
- Public API, availability, DocC og migrasjon oppdatert; ingen eksterne Swift Package-dependencies.

## Plattformmatrise

[PLATFORM_MATRIX.md](../planning/PLATFORM_MATRIX.md) og ADR-0004 fastsetter iOS/iPadOS 17, macOS 14, watchOS 10 og tvOS 17, med Xcode 26.3+, Swift tools 6.2 og Swift 6-språkmodus. Matrisen viser planlagt støtte og manglende bygg-/runtime-bevis. Oppdater den med testet OS, Swift, Xcode/SDK, build, unit, integration og device-verifikasjon etter faktisk kjøring. VisionOS er utsatt. Konkrete API-symboler kontrolleres mot alle minimumene før deloppgaver blir Ready. Simulatorbygg er ikke bevis for bakgrunnskjøring, Keychain, entitlements eller fysisk nettverk på enheter.

## CI-innføring

Fase 0 beskriver konkrete jobs og stabilt navn på en samlet gate, for eksempel `quality-gate`. Fase 1 oppretter build/test/DocC/dependency-kontroll med Apples/offisielle verktøy. Ingen generisk workflow som alltid blir grønn eller hopper over produktkontroller ved manglende Package.swift. Aktiver required status check først etter vellykket reell kjøring på main og en PR. Unngå path filters som etterlater påkrevde sjekker ventende.

GITHUB_TOKEN gis read-only som standard; særskilte write-jobber begrunnes. Ingen pull_request_target som kjører upålitelig kode, ingen secrets i fork-PR-er. Verktøy og actions velges i ADR-DEC-07; eksterne actions krever eksplisitt avklaring mot kravet om offisielle verktøy og låses til full commit-SHA. Dependabot/workflow opprettes først når faktiske manifests og vedtatte verktøy finnes.

## Release

Testmatrise og plattformbegrensninger dokumentert, sikkerhetsgjennomgang utført, lisens valgt, offentlig API/DocC komplett, brukseksempler og migration ved behov, changelog og kjente problemer. Ingen vilkårlig coverage-prosent; mål dekning og krev bevis for alle valgte kontrakter og negative sikkerhetstilfeller. Benchmarks måler representativ p50/p95/minne med dokumentert maskin og scenario før terskler bestemmes.
