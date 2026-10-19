# Samlet F0-grunnlag til prosjekteierens godkjenning

Status: Avventer prosjekteierens samlede vurdering. Ingen godkjenning til implementasjon er gitt.
Dato: 2026-10-19. Arkitekturport: [GATE-00 / #28](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/28).

## Vedtakene som skal vurderes samlet

| Oppgave | Vedtak | Autoritativ dokumentasjon |
| --- | --- | --- |
| DEC-03 / #3 | Teisrud Development AS er rettighetshaver. Proprietært; tredjepartsbruk krever særskilt skriftlig tillatelse, med forbehold for lov/GitHub-vilkår. Repoet er offentlig under BK-Teisrud | [ADR-0002](../decisions/ADR-0002-ownership-and-rights.md), LICENSE |
| DEC-02 / #2 | HTTP-kjerne først; repo/pakke SwiftNetworkKit, bibliotekprodukt/modul/importnavn NetworkKit, én bibliotekmodul | [ADR-0003](../decisions/ADR-0003-v1-scope-and-naming.md), [v1-scope](V1_SCOPE.md) |
| DEC-01 / #1 | iOS/iPadOS 17, macOS 14, watchOS 10, tvOS 17. Xcode 26.3+, Swift tools 6.2, Swift 6-modus. VisionOS utsettes | [ADR-0004](../decisions/ADR-0004-platforms-and-toolchain.md), [plattformmatrise](PLATFORM_MATRIX.md) |
| DEC-04 / #4 | Typed + raw requests; respons-wrapper; JSON/Data/tekst/tomt; strukturerte feil med separat CancellationError; 2xx med eksplisitte kallunntak | [ADR-0005](../decisions/ADR-0005-http-api-contract.md), [HTTP-kontrakt](HTTP_API_CONTRACT.md) |
| DEC-05 / #5 | Gjenbrukt egen session pluss app-eid injeksjon. 30 sekunder inaktivitet / 60 sekunder samlet budsjett, konfigurerbart. Isolert state, entydig cancellation/timeout og kontrollert shutdown | [ADR-0006](../decisions/ADR-0006-concurrency-and-lifecycle.md), [livssyklus](CONCURRENCY_AND_LIFECYCLE.md) |
| DEC-06 / #6 | Automatiske lagre av som standard; liten auth-header-provider; HTTPS med eksplisitt lokalt HTTP-unntak uten credentials; avgrensede redirects, injeksjon og sanerte logger | [ADR-0007](../decisions/ADR-0007-security-and-network-policy.md), [sikkerhetspolicy](SECURITY_AND_NETWORK_POLICY.md) |
| DEC-07 / #7 | Standard GitHub-runners uten betalte tillegg. Fire PR-plattformfamilier og egne minimums-OS-/releasebevis. Offisielle testverktøy og SHA-låste Actions | [ADR-0008](../decisions/ADR-0008-ci-tools-and-budget.md), [CI-/testplan](CI_AND_TEST_PLAN.md) |

De godkjente hovedvalgene og dokumenterte standarddetaljene skal vurderes samlet. Ingen funksjoner eller tester er fremstilt som implementert. Issues er live status; denne oversikten er beslutningsgrunnlaget.

## Viktige konsekvenser av standarddetaljene

- Rå request følger samme tids-/sikkerhets-/statusregler; den er ingen generell bypass. JSON med tom body gir ikke et kunstig objekt.
- Default 30/60 er ikke en hard sanntidsgaranti for synkron appkode; strengere grenser i en app-eid session består.
- Shutdown kansellerer egne operasjoner og ugyldiggjør kun egen session. Ingen separat graceful-drain-modus i v1.
- Ephemeral alene er ikke lik ingen RAM-lagring; lagre deaktiveres eksplisitt i standardprofilen. Annen systemlagring krever et uttrykkelig appvalg.
- Auth-provider gjør ingen login/refresh. Ingen credentials over HTTP, heller ikke lokalt. Redirectstandard er samme-origin GET/HEAD, maks fem hopp; ingen automatisk mutasjonsreplay/cross-origin/downgrade.
- Ingen generell error-body-capture, ekstern telemetri, egen retry-/cache-/offline-/streamingmodul eller nye pakkedependencies i v1.
- CI-planen gir ikke automatisk minimums-OS-testdekning. Minimumsruntimes/enheter er ikke bekreftet tilgjengelige; manglende releasebevis skal ikke skjules med nyere simulatorresultater.

## Hva F0-godkjenning betyr

Prosjekteier kan godkjenne dette som planleggings- og arkitekturgrunnlag og samtidig beslutte at implementasjon fortsatt er stanset. En slik godkjenning betyr ikke at biblioteket, manifest, tester, workflows eller produktrelease kan opprettes.

Før utviklingsoppgaver blir Ready må relevante kontrakter være brutt ned til konkrete delissues med nødvendige symbol-/availabilitykontroller og testbare kriterier. Før en release må reelle tester, sikkerhetsreview, runtime-/minimums-OS-bevis og alle leveransekrav være oppfylt.

Bare et senere uttrykkelig implementasjonsklarsignal endrer kodeforbudet. Ingen PR eller lukking av en beslutningsoppgave gir dette automatisk. Ved fortsatt kodepause skal GATE-00 dokumentere både godkjent planlegging og «implementasjon ikke autorisert» eksplisitt.

## Kjente gjenstående forhold i GitHub-oppsettet

Gjennomgangen av selve repooppsettet identifiserte prosjektvisninger/statusdobbeltføring, admin-bypass, tag-/releasebeskyttelse, web sign-off og privat kontaktkanal som videre vurderingspunkter i OPS-01 / #30. SHA-låsing for Actions er nå aktivert. De andre punktene er ikke endret gjennom DEC-beslutningene og må ikke fremstilles som ferdig utbedret.

Ingen kontofakturering, abonnement, nye samarbeidspartnere, secrets eller eksterne apper er opprettet. Ingen Swift-filer, Package.swift, workflows eller releasetagger er lagt til.

## Godkjenning

Avventer svar i chatten og registrering i GATE-00. Dokumentet skal ikke omtales som godkjent før prosjekteier har svart. Eventuelle ønskede endringer tas gjennom dokumentasjons-PR før endelig godkjenning.
