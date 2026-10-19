# CI- og testplan etter implementasjonsklarsignal

Status: Vedtatt hovedplan 2026-10-19, se [ADR-0008](../decisions/ADR-0008-ci-tools-and-budget.md). Ingen workflow, testtarget, produktkode eller bestått CI finnes nå.

## Planlagte PR-jobber

Alle jobber kjøres på pull requests og relevante push til main etter at ekte CI innføres. Valget er fire plattformfamilier ved hver PR, ikke bare før release. Dokumentasjons-PR-er får ikke en skjult global omgåelse av den vedtatte matrisen.

| Jobbnavn | Runner / verktøy | Faktisk kontroll som må finnes før jobben kan bli grønn |
| --- | --- | --- |
| source-integrity | Standard GitHub-runner; offisielle/bundne systemverktøy | Manifest/dependency-/plattform-/språkmoduskrav, filformat og dokumentasjonslenker. Ingen eksterne Swift-pakkedependencies eller SwiftUI-import i biblioteket |
| macos-core | macos-15, arm64, eksplisitt Xcode 26.3 | Produktbygg med macOS 14-minimum og unit-/direkte integrasjonstester på faktisk runner-OS |
| ios-core | macos-15, arm64, eksplisitt Xcode 26.3 | iOS/iPadOS-produktbygg med 17-minimum og tester på valgt iPhone- og iPad-simulator, baseline runtime 26.2 |
| watchos-core | macos-15, arm64, eksplisitt Xcode 26.3 | watchOS-produktbygg med 10-minimum og tester på valgt watchOS 26.2-simulator, med kompatibel iPhone-paring/harness der dette trengs |
| tvos-core | macos-15, arm64, eksplisitt Xcode 26.3 | tvOS-produktbygg med 17-minimum og tester på valgt Apple TV-simulator, baseline runtime 26.2 |
| documentation | Standard macOS-runner, Xcode 26.3 / DocC | Bygg dokumentasjon for bibliotekets faktiske public API, kontroller warnings/lenker og at guider stemmer med leveransen |
| quality-gate | Liten standardrunner-jobb som samler resultat | Alle obligatoriske jobber har suksess; feil, manglende jobber og uventet skip gir ikke grønt resultat |

source-integrity og dokumentasjonskontroll er støttejobber, ikke nye produktavhengigheter. Eksakte schemes, testplaner og simulator-ID-er bindes og dokumenteres i første reelle CI-PR etter at pakken finnes. En nødvendig app-/testhost er kun testinfrastruktur og øker ikke antallet distribuerte bibliotekmoduler. Dersom valgt testharness ikke kan kjøre på en plattform, skal det løses eller løftes som eksplisitt blocker; bygg alene gis ikke nytt navn som «tester bestått».

## Runner- og toolchainkontroll

Planlagt primær runner er standard macos-15 (arm64). Sett DEVELOPER_DIR til den faktisk installerte Xcode 26.3-installasjonen og kontroller versjonen før bruk; ikke stol på image-default eller macos-latest. Offisielt inventar lest 2026-10-19 viser Xcode 26.3 build 17C529 og SDK-/simulatorruntimes 26.2, mens standard-Xcode er eldre. macOS-host i inventaret er 15.7.9, ikke bibliotekets minimum 14.

Registrer ved hver kjøring imageversjon, host-OS/arkitektur, Xcode-build, Swift-patch, SDK, runtime og valgte destinations. Kontroller at kompilatoren oppfyller Swift tools 6.2 og at prosjektet bruker Swift 6. Plattformminimum skal settes eksplisitt i framtidig manifest. Manglende valgt toolchain/runtime feiler preflight; ikke fall stille tilbake til annet verktøy eller oppgrader minimumene automatisk.

Inventar er tilgjengelighetsgrunnlag, ikke faktisk verifisert CI eller en frosset image. Første CI-PR må bevise at runneren kan kjøre valgte destinations, inkludert watch-paring. Oppdatering av runner/Xcode/runtime går gjennom PR og beholder vedtatte produktminimum. Ingen beta/RC er eneste required gate.

## Teststrategi og sikkerhet

Swift Testing er standard for nye unit-tester og direkte integrasjonstester. XCTest brukes ved konkret platform-/performance-/harnessbehov; bruk ikke assertions fra begge rammeverk vilkårlig i samme test. Begge kommer fra det valgte Apple-verktøygrunnlaget, uten eksterne Swift Package-dependencies.

Bruk URLProtocol/mocktransport og kontrollert intern klokke til normalflyt, feil, timeout, cancellation, snapshots, concurrency, session-eierskap, shutdown og securitypolicy. Bruk bare syntetiske data og testcredentials. Ingen tester er avhengige av offentlige tredjeparts-API-er eller ekte tokens. En kontrollert loopback-testtjeneste eller fysisk testharness kan brukes der transportegenskaper må verifiseres; dette er ingen backend som produkt.

URLProtocol-tester alene verifiserer ikke TLS/system trust, ekte redirectflyt, cache/cookie-lagring eller OS-spesifikke oppførsel. Slike kontrakter får reelle kontroller der de gjelder før release. Ikke sett en vilkårlig coverage-prosent som erstatning for kontraktsdekning; dokumenter hvilke normal-/feil-/race-/sikkerhetstilfeller som faktisk er testet.

Bruk bare GitHub-eide actions som er nødvendige, låst til full commit-SHA. Lokale workflowsteps bruker Apples/offisielle verktøy og tilgjengelige systemverktøy. Ingen tredjeparts Xcode-installer, SwiftLint/SwiftFormat/xcbeautify eller coverage-SaaS innføres bare fordi de er preinstallert på imagen. Ingen eksterne reusable workflows. DocC bygges med Xcode-verktøy, uten separat tredjeparts dokumentasjonsplugin.

Read-only GITHUB_TOKEN er standard. Checkout skal ikke beholde credentials til upålitelig kode. Ingen secrets til fork-PR-er, ingen pull_request_target som kjører PR-kode, ingen betrodde artifacts/caches fra upålitelig PR som senere publiseres med write-token. Ingen automatisk release-/publiseringsjobb eller nytt secret opprettes av CI-planen.

## Kontrollert ressursbruk og kostnader

Kun standard GitHub-hostede runners i offentlig repo er godkjent. Ingen larger runners, abonnementer, selvhostede tjenester eller betalte tillegg. En framtidig endring til privat repo krever ny vurdering av pris/minutter før videre kjøring; gratis compute for offentlige standardrunners er ikke en garanti om gratis lagring eller alle kontotjenester.

Første CI-versjon har ingen artifact-upload og ingen eksplisitt Actions-cache. Behold bare nødvendige, sanerte vanlige jobblogger innen kontoen/repoets gjeldende grenser. Dersom testresultatbundler eller annen opplasting trengs senere, vedtas liten størrelse/retensjon og kontrolleres mot gjenværende gratis lagring før aktivering. Ingen fakturerings-/abonnements-/budsjettinnstillinger for hele kontoen er endret nå.

Planlagt initial ressursramme er maks to samtidige macOS-matrisejobber per workflow og 30 minutters timeout per tung jobb. Ny push på samme PR erstatter/kansellerer foreldet PR-kjøring med ryddig avbrudd. Ikke kanseller en verifikasjon som allerede brukes som releasebevis. Disse workflowgrensene er planlagt, ikke konfigurert uten en workflow.

Ved runtime-/tidsproblemer skal jobben feile med en konkret årsak. Ikke bytt til betalt runner, installasjon av uavklarte verktøy eller hopping over tester uten eget vedtak.

## Required check innføres etter bevis

1. Etter implementasjonsklarsignal opprettes en faktisk pakke og meningsfulle tester sammen med første CI-PR.
2. Alle obligatoriske jobber kjører på PR-en og deretter på main. En manglende Package.swift eller tom testsuite er ingen suksess.
3. Kontroller at quality-gate rapporteres med stabilt checknavn og samler alle påkrevde plattform-/test-/docjobber uten grønn skip-path.
4. Legg først da quality-gate til som required status check, med korrekt Actions-integrasjon og oppdatert branch-policy. Ingen ondsinnet/tilfeldig check med samme navn skal regnes som likt bevis.
5. Kontroller en ny PR mot håndhevet regel. Eventuell admin-bypass må vurderes før required-check innføres, slik at den ikke blir en rutinemessig omgåelse.

Ingen required status check legges til nå. Ingen status som bare bekrefter at «kode ikke finnes» innføres.

## Egen releasekontroll og minimums-OS

PR-runtimes 26.2 og macOS-host 15.x dekker ikke minimum iOS/iPadOS 17, macOS 14, watchOS 10 eller tvOS 17. Det kontrollerte macos-15-inventaret gir ikke disse som et komplett minimumssett. Planen lover derfor ikke at alle minimumsruntimes finnes på standardrunners.

Før første release kreves registrerte bevis på de valgte minimumene: relevant offisiell simulator/runtime der tilgjengelig og kompatibel, eller eksisterende fysiske enheter/Mac-er med egnet app-/testharness. macOS minimum må være et faktisk runtimebevis, ikke bare deployment-target under nyere host. Ikke anta at en annen gammel runner kan bygge med Xcode 26.3 bare fordi den har riktig host-OS.

Tilgang til minimumsruntimes/enheter er ennå ikke verifisert eller anskaffet. Ingen utstyrskjøp, betalt tjeneste eller selvhostet GitHub-runner er autorisert. Hvis slikt bevis ikke kan skaffes innen vedtatt ramme, skal release blokkeres eller et eksplisitt nytt vedtak endre støttepåstanden; matrisen merkes aldri «bestått» ut fra antatt kompatibilitet.

Releasekontrollen omfatter også representative nyere stabile runtimes, relevante fysiske scenarier, en dokumentert vurdering av Mac-arkitekturer, sikkerhet/personvern, offentlig API/DocC, rettighetspolicy og representative ytelses-/minnemålinger. Installasjon fra releasekandidatens commit/tag må verifiseres før endelig publisering, slik at feil ikke først oppdages etter en eventuell uforanderlig release.

Oppdater [PLATFORM_MATRIX.md](PLATFORM_MATRIX.md) og REL-01 med commit, miljø, testnavn/resultat, relevante kjente begrensninger og eventuelle godkjente scopeendringer. Ingen releasekontroller er kjørt nå.
