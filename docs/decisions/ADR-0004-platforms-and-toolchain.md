# ADR-0004: Plattformminimum og verktøygrunnlag for v1

Dato: 2026-10-19. Status: Godkjent av prosjekteier i chatten.
Oppgave: [DEC-01 / #1](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/1).

## Godkjente valg

Prosjekteier har uttrykkelig valgt alle følgende:

- iOS/iPadOS, macOS, watchOS og tvOS i første stabile versjon. VisionOS utsettes.
- Minimum iOS/iPadOS 17.0, macOS 14.0, watchOS 10.0 og tvOS 17.0.
- Minimum Xcode 26.3, Swift tools 6.2 og Swift 6-språkmodus med streng samtidighetskontroll.

Repo/pakkenavn SwiftNetworkKit og produkt/modul NetworkKit følger ADR-0003. Dette vedtaket gjelder planlagt støtte og utviklingskrav; det bekrefter ikke fungerende produktkode eller tester.

## Beslutning og matrise

[PLATFORM_MATRIX.md](../planning/PLATFORM_MATRIX.md) er autoritativ plattform- og verifikasjonsmatrise. Minimums-OS gjelder hvor konsumentappen skal kjøre. Xcode/Swift gjelder hvor pakken bygges. SDK-versjon er separat fra minimums-OS.

Bruk Xcode 26.3 som første planlagte referanse for bygg og tester. Før fremtidig CI opprettes i DEC-07/F1, registreres eksakt Xcode-build, kompilator, SDK, runner-arkitektur og test-runtime. Nyere stabile Xcode-versjoner kan tas i bruk etter kontroll; «26.3+» er ikke bevis for at alle fremtidige versjoner fungerer. Beta/RC er ikke eneste kvalitetsport.

Swift tools-minimum er 6.2. Senere pakkemanifest skal velge Swift 6-språkmodus uttrykkelig. Streng samtidighetskontroll gjelder fra starten; en Swift 5-modus inngår ikke som alternativ støtteprofil i v1. Dette oppretter ikke noe manifest nå.

## Observert miljø

Read-only kontroll 2026-10-19 viser Xcode 26.3 (17C529), Apple Swift 6.2.4 og macOS 15.8.1. SDK-listen viser iOS/iPadOS 26.2, macOS 26.2, watchOS 26.2 og tvOS 26.2. Kompilatoren rapporterer et x86_64-vertsmiljø. Ingen produktbygg, pakkeløsing, simulatoroppstart eller runtime-tester er kjørt.

Apples støtteside oppgir en annen Swift-patch for Xcode 26.3 enn den lokale kompilatoren rapporterer. Swift 6.2-familien er felles; de lokale utskriftene er grunnlaget for det observerte miljøet. Eksakte patch-/build-identiteter må derfor registreres på den runneren som faktisk brukes fremfor å antas ut fra Xcode-navnet alene.

## Alternativer og begrunnelse

- Bare iOS/macOS ville gitt færre plattformer å kontrollere. Prosjekteier ønsker også watchOS og tvOS fra v1.
- Eldre minimum (iOS/tvOS 15, macOS 12, watchOS 9) ville inkludert flere eldre OS-er. Prosjekteier valgte en høyere felles baseline.
- Nyere minimum (iOS/tvOS 18, macOS 15, watchOS 11) ville utelatt flere eldre OS-er. Ikke valgt.
- Xcode 27.1 / Swift 6.4 ville krevd en annen lokal macOS-baseline. Prosjekteier valgte verktøygrunnlaget som passer den observerte installasjonen.

## Tilgjengelighet og releasebevis

Konkrete API-symboler fastsettes videre i DEC-04–DEC-06 og kontrolleres mot valgt SDK og alle fire OS-minimum før deloppgaver blir Ready. OS-/frameworknavn er ikke bevis for identisk adferd på alle plattformer. Nødvendige availability-/compile-time-grenser skal dokumenteres og senere verifiseres.

Bygg med et deklarert minimum er ikke det samme som runtime-test på minimums-OS. Matrisen skal vise både bygg og faktisk testet runtime med resultat. Manglende simulator/enhet/runner skal vises som manglende bevis og håndteres før støtte annonseres ved release. Ingen bestemt runner eller testkostnad er valgt her; det avgjøres i DEC-07.

Denne ADR-en lukker plattform-/verktøyvalget. Den lukker ikke symbolgjennomgang, implementasjon, tester eller F0-porten. Heving av minimums-OS etter 1.0 behandles etter releasepolicyens breaking-change-regler.

## Kilder

- [Apple: SDKs and system requirements](https://developer.apple.com/xcode/system-requirements)
- [Apple: Creating a standalone Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode)
- Lokal kontroll: xcodebuild -version, xcrun swift --version, sw_vers -productVersion og xcodebuild -showsdks.

ADR-0001 og tidligere ADR-er beholdes som historikk. Åpne plattform- og verktøyvalg fra disse avklares av denne beslutningen.
