# Testmiljøer og bevisplan

Inventar lest 2026-10-19 med xcrun simctl list runtimes --json. Dette er installasjonsbevis; ingen simulator er startet og ingen produkttest er kjørt. Xcode/Swift/host er dokumentert i [PLATFORM_MATRIX.md](PLATFORM_MATRIX.md).

| Installert runtime | Build | Tilgjengelig ifølge simctl | Arkitekturer |
| --- | --- | --- | --- |
| iOS 18.2 | 22C150 | Ja | x86_64, arm64 |
| iOS 18.5 | 22F77 | Ja | x86_64, arm64 |
| iOS 26.2 | 23C54 | Ja | x86_64, arm64 |
| tvOS 18.2 | 22K154 | Ja | x86_64, arm64 |
| tvOS 18.5 | 22L572 | Ja | x86_64, arm64 |
| tvOS 26.2 | 23K51 | Ja | x86_64, arm64 |
| watchOS 11.2 | 22S99 | Ja | x86_64, arm64 |
| watchOS 11.5 | 22T572 | Ja | x86_64, arm64 |
| watchOS 26.2 | 23S303 | Ja | x86_64, arm64 |

Ingen iOS/iPadOS 17-, watchOS 10- eller tvOS 17-runtime finnes i dette inventaret. macOS 14-testvert er ikke bekreftet; lokal vert er tidligere observert som macOS 15.8.1. Runtimenes isAvailable er ingen garanti for at et bestemt scheme/destination kjører med valgt Xcode.

Eier oppgir tilgang til iPhone/iPad, Mac, Apple Watch og Apple TV med nyeste oppdateringer. Dette er eieropplysninger; eksakte modeller/OS-builds er ikke innhentet, og serienumre/UDID-er skal ikke publiseres. Før I22 registreres nødvendig modell/OS/arkitektur og kompatibilitet uten private identifikatorer.

## Gjennomføring etter kodegodkjenning

1. I06 kontrollerer faktisk runner-image, Xcode, schemes og destinations og kjører alle fire plattformfamilier. Ingen betalte runners eller installasjoner er forhåndsgodkjent.
2. I17 samler deterministiske kontrakttester og kontrollerte URLSession-integrasjonstester. Bruk isolert lokal tjeneste/mock, ingen produksjonstjeneste eller ekte credentials.
3. I21 skaffer dokumentert tilgang til minimumsruntimes/testverter. Undersøk offisielle kompatible runtime-/Xcode-kombinasjoner eller tilgjengelig eldre testmaskin først. Ingen automatisk nedgradering av brukerens oppdaterte enheter. Kjøp/oppgraderinger krever eget vedtak.
4. I22 tester representative nyere fysiske enheter og reelle nettverksskifter der relevant. Minimumsbevis og nyere enhetsbevis føres separat.
5. I23 og REL-01 krever alle valgte bevis før release. Mangler markeres blokkert, ikke bestått.

Per kjøring: issue/test-ID, commit-SHA, dato, Xcode-build, Swift/SDK, OS-build/arkitektur, simulator eller enhetstype, kommando/scenario, forventning/resultat og lenke til sanitert bevis. Tillatelser, entitlements og privacy vurderes mot faktisk v1-bruk. Ingen irrelevante F3–F6-krav trekkes inn.
