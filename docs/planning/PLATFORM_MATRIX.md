# Plattform- og verktøymatrise

Status: Vedtatt støtteplan 2026-10-19, se [ADR-0004](../decisions/ADR-0004-platforms-and-toolchain.md). Dette er ingen erklæring om verifisert produktstøtte; biblioteket er ennå ikke implementert.

## Vedtatt leveransegrunnlag

| Plattform | Minimums-OS i v1 | SDK observert lokalt | Bygg | Unit / integrasjon | Testet runtime / enhet |
| --- | --- | --- | --- | --- | --- |
| iOS | 17.0 | iOS 26.2 | Ikke kjørt | Ikke kjørt | Ikke verifisert |
| iPadOS | 17.0 | iOS/iPadOS 26.2 | Ikke kjørt | Ikke kjørt | Ikke verifisert |
| macOS | 14.0 | macOS 26.2 | Ikke kjørt | Ikke kjørt | Ikke verifisert |
| watchOS | 10.0 | watchOS 26.2 | Ikke kjørt | Ikke kjørt | Ikke verifisert |
| tvOS | 17.0 | tvOS 26.2 | Ikke kjørt | Ikke kjørt | Ikke verifisert |
| visionOS | Utsatt; ingen v1-støtte | Ikke del av valgt leveranse | Ikke del av v1 | Ikke del av v1 | Ikke del av v1 |

Et nyere SDK er verktøyets API-grunnlag, ikke et krav om at vertappen kjører denne OS-versjonen. iOS og iPadOS deler SDK-/deploymentgrunnlag, men relevante enhets-/miljøforskjeller må fortsatt vurderes. Ingen Mac Catalyst-, Linux-, Windows- eller Android-støtte er valgt.

## Verktøy

| Felt | Vedtatt krav | Observert lokalt 2026-10-19 |
| --- | --- | --- |
| Xcode | 26.3 eller nyere stabil versjon, med faktisk verifikasjon før støtte hevdes | 26.3, build 17C529 |
| Swift tools | Minimum 6.2 | Apple Swift 6.2.4 |
| Swift-språkmodus | Swift 6, streng samtidighetskontroll | Ikke konfigurert i noen pakke ennå |
| Vertens macOS | Må oppfylle systemkravet til valgt Xcode | 15.8.1 |
| Vertens arkitektur | Ingen CI-runner valgt ennå | x86_64 rapportert av kompilatoren |
| CI-SDK / runtime / runner | Eksakte verdier og kapasitet vedtas i DEC-07 | Ingen CI opprettet |

Systemkravet til utviklermaskinen er separat fra bibliotekets minimum macOS 14.0. En lokal versjonskontroll er ikke et testresultat for biblioteket.

## Påkrevd symbolkontroll før utviklingsoppgaver blir Ready

For hvert valgt symbol/API registreres: krav-ID, fullt symbolnavn, framework, SDK som ble kontrollert, tilgjengelighet per valgt OS, eventuell guard/fallback og hvordan adferden skal testes. Bruk SDK-/Apple-dokumentasjon; ikke anta tilgjengelighet ut fra frameworknavnet.

Foreløpige API-familier som må gjennomgås når kontraktene velges:

| Område | Grunnlag | Kontroll som gjenstår |
| --- | --- | --- |
| HTTP/session | Foundation / URLSession / URLRequest | Eksakte async-metoder, sessionkonfigurasjon, delegates, timeout og cancellation |
| URL/JSON | URLComponents / Codable / JSONEncoder / JSONDecoder | Faktiske valgte overloads, parametersemantikk og encoder-/decoderstrategier |
| Logging | OSLog | Konkret logging-API, privacy-markeringer og dataminimering |
| Samtidighet | Swift Concurrency | Sendable, isolation, cancellation og eventuell clock-API; språk- og OS-krav vurderes separat |
| Testing | Apples/offisielle testverktøy | Valg i DEC-07, tilgjengelige runtimes og plattformspesifikke begrensninger |

Tabellen er en arbeidsliste, ikke en påstand om at bestemte symboler er verifisert. Nye Foundation-/OSLog-/Concurrency-API-er kan ha høyere OS-krav enn produktets valgte minimum.

## Krav til fremtidig testbevis

Registrer per kontroll: commit-SHA, dato, Xcode-build, Swift-versjon, SDK, faktisk runtime og arkitektur, simulator/enhet, testtype og resultat eller konkret begrunnelse for manglende kjøring.

Planen skal dekke bygg for alle valgte plattformer og relevante normal-/feil-/cancellation-/concurrencytester. Testing på minimums-OS og representative nyere stabile runtimes planlegges i DEC-07. Hvis en minimumsruntime ikke kan kjøres i tilgjengelig CI, må et eksplisitt alternativ med reelt testbevis avklares før release; et nyere simulatorbygg alene dekker ikke dette.

Fysisk enhetstest brukes der scenarioet krever det. Bakgrunnsoverføringer, Keychain-grupper og lokalnett er utsatt etter v1-scope og er ikke påstått støttet gjennom denne matrisen. Ingen byggetest eller runtime-verifikasjon er bestått ennå.
