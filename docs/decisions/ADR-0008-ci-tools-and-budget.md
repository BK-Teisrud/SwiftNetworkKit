# ADR-0008: CI, offisielle verktøy og kostnadsramme

Dato: 2026-10-19. Status: Hovedvalg godkjent av prosjekteier; gjennomføringsplan og sikkerhetsdetaljer dokumentert som konkretisering.
Oppgave: [DEC-07 / #7](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/7).

## Godkjente hovedvalg

Prosjekteier valgte standard GitHub-hostede runners uten betalte tillegg, og bygg for alle fire plattformfamilier ved hver PR med tester på valgte tilgjengelige runtimes samt egne releasekontroller. Dette gjelder framtidig CI etter uttrykkelig implementasjonsklarsignal. Ingen workflows opprettes nå.

## Beslutning

[CI_AND_TEST_PLAN.md](../planning/CI_AND_TEST_PLAN.md) beskriver jobber, runner-/toolchain-baseline, testverktøy, kvalitetsport og releasebevis. Apple-verktøyene Xcode/xcodebuild, Swift/Swift Package Manager, Swift Testing/XCTest og DocC er grunnlaget. Ingen eksterne Swift-pakker, formatter-/lint-/coverage-SaaS, tredjeparts setup-actions eller selvhostede runners innføres.

macos-15 på standard Apple Silicon-runner er planlagt primær baseline med eksplisitt valg av /Applications/Xcode_26.3.app og kontroll av Xcode/Swift/SDK/runtime. Offisielt runnerinventar lister Xcode 26.3 (17C529), SDK-/simulatorruntimes 26.2 for iOS/watchOS/tvOS og macOS-vert 15.7.9. Standard-Xcode i den kontrollerte imagen er eldre, og kan derfor ikke brukes ubevisst. Runnernavn er ikke en frosset VM-image; verktøy/runtimes må kontrolleres ved hver kjøring.

Swift Testing er primært for nye unit-/direkte integrasjonstester. XCTest supplerer der plattform-/performance-/harness-behov tilsier det. Bruk innebygde verktøy fra valgt toolchain uten ekstern testpakke. Mocks, URLProtocol og intern kontrollert klokke brukes til deterministiske tester; testserver er valgfri kontrollert testinfrastruktur ved dokumentert behov, ikke en produktmodul.

## Kostnad og tilgang

Kun standardrunner-kjøring i offentlig repo er godkjent. Ingen betalte runners, abonnementer, selvhostede tjenester, betalt artifact-/cachelager eller tilleggskjøp. Artifact-upload og eksplisitt Actions-cache er av i første CI-versjon. Faktureringsgrenser for hele kontoen er ikke endret; en repositorypolicy alene er ikke en teknisk garanti mot alle kontoavgifter. Endret synlighet eller lagrings-/runnerbruk krever ny vurdering før kjøring.

GITHUB_TOKEN forblir read-only og kan ikke godkjenne PR-er. Bare lokale/GitHub-eide actions er tillatt; full commit-SHA er nå påkrevd gjennom faktisk repositoryinnstilling og lest tilbake som true. Ingen ny action, secret eller workflow er opprettet. Eksterne reusable workflows innføres ikke, slik at SHA-kravet ikke presenteres som dekning for alle typer eksterne referanser.

## Alternativer og begrunnelse

Lokale kontroller først og rask macOS/iOS-PR-kontroll med full matrise bare ved release var foreslåtte alternativer. Prosjekteier valgte fire plattformer ved hver PR og egne releaseporter. Standardrunners passer offentlig repo uten godkjent runnerkostnad. Betalte større maskiner eller eksterne tjenester inngår ikke.

Minimums-OS-runtimebevis er separat fra PR-runtimes. De valgte minimumene iOS/iPadOS 17, macOS 14, watchOS 10 og tvOS 17 finnes ikke som fullstendig sett i det kontrollerte macos-15-inventaret. De skal derfor ikke telles som testet i standardmatrisen. Eksplisitt manual-/enhetsbevis eller annen verifisert tilgjengelig offisiell runtime kreves før første release; hvis bevis ikke kan skaffes, blokkeres støttepåstanden og avviket løftes til prosjekteier.

## Innføringsport

En framtidig quality-gate må først vise reelle produktbygg/tester på main og i PR før den gjøres obligatorisk i regelsettet. Ingen check som alltid er grønn eller hopper over manglende Package.swift. Første reelle CI-PR markerer ikke seg selv som ferdig før alle valgte kontroller faktisk kjører. Fram til dette er branchregelen basert på dokumentert manuell verifikasjon.

DEC-07 lukker planvalg og verktøypolicy, ikke implementasjon eller en grønn CI-pipeline. F0-porten og eget klarsignal gjenstår. Endringer i runnerinventar håndteres som vedlikehold med eksplisitt vurdering, ikke automatisk heving av OS-minimum eller toolchainkrav.

## Kontroll og kilder

- Aktuell Actions-policy lest tilbake: selected actions, GitHub-eide tillatt, verified/andre patterns av, read-only token, ingen PR-approval, sha_pinning_required true, null workflows.
- [GitHub: runnerreferanse](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
- [GitHub: Actions-prisregler](https://docs.github.com/en/billing/concepts/product-billing/github-actions)
- [Offisielt macos-15 arm64-inventar](https://github.com/actions/runner-images/blob/82d1b86ad393865982dd29535cb8d3adbc68e41e/images/macos/macos-15-arm64-Readme.md), image 20260907.0337.1, lest 2026-10-19; ingen jobber er kjørt mot det.
- [GitHub: Actions-innstillinger](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-your-repository)
- [Apple: testing](https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project)
