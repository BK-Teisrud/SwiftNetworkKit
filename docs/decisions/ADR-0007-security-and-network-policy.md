# ADR-0007: Sikkerhets-, auth-, lagrings- og nettverkspolicy i v1

Dato: 2026-10-19. Status: Hovedvalg godkjent av prosjekteier; tilhørende standardregler dokumentert som konkretisering.
Oppgave: [DEC-06 / #6](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/6).

## Godkjente hovedvalg

Prosjekteier valgte i chatten:

1. Ingen automatisk cookie-, credential- eller HTTP-cachelagring som standard.
2. En injiserbar auth-provider for headers, i tillegg til eksplisitte request-headers. Appen eier innlogging, tokenlagring og eventuell fornyelse.
3. HTTPS som standard med eksplisitt HTTP-unntak bare for localhost/loopback under lokal utvikling. Ingen TLS-bypass eller global ATS-deaktivering.

## Beslutning

[SECURITY_AND_NETWORK_POLICY.md](../planning/SECURITY_AND_NETWORK_POLICY.md) presiserer disse valgene innen HTTP-kjernen og ADR-0005/0006. Egen session bygger på ephemeral konfigurasjon med eksplisitt deaktiverte lagre; ephemeral alene betyr ikke «ingen lagring i RAM». En app kan bevisst velge annen systemlagring eller injisere en kompatibel session, men da skal den faktiske lagringsprofilen være eksplisitt og ikke beskrives som standardens null-lagring.

Auth-provider er en liten asynkron, kansellerbar og Sendable-kompatibel headergrense. Den får bare nødvendig kontekst og kjører innen samme totale tidsbudsjett. Den er ingen OAuth-/Keychain-/token-refreshmodul. URLSessions system trust beholdes, og mTLS, pinning og egne trust-policyer er utsatt.

Som konkretisering av secure defaults begrenses automatiske redirects til validerte samme-origin GET/HEAD-kall, med endelig antall hopp. Cross-origin, HTTPS-nedgradering og muterende redirect-replay følges ikke automatisk. Rå request er ingen bypass. Logging/feiltekst bruker en liten allowlist med metadata og inkluderer ikke credentials, payload eller rå URL som standard.

En app-eid session er en betrodd injisert avhengighet, ikke en sikkerhetssandbox. Klienten skal kontrollere tilgjengelig konfigurasjon og egen kontroll over task-level policy; bakgrunnssessions og ukontrollerbare delegate-/policykombinasjoner avvises. Vilkårlig appkode, custom transports eller en ondsinnet ekstern session kan ikke sikkerhetssertifiseres av biblioteket.

## Scope og alternativer

Standard systemlagring/cache ville vært enklere for enkelte apper, men prosjekteier valgte minimal automatisk lagring. Annen systemlagring krever et eksplisitt klient-/injeksjonsvalg og appens ansvar for isolasjon/sletting; ingen egen cachemodul innføres.

Kun manuelle auth-headers ville gitt færre abstraheringer. Prosjekteier valgte en liten providergrense i tillegg, med eksplisitt avgrensning mot login, refresh og credential storage.

Kun HTTPS, også lokalt, var alternativet til et snevert utviklingsunntak. Prosjekteier valgte loopback-unntaket. Det gjelder ikke LAN/private IP-nett, .local, generelle hostunntak eller automatisk oppheving av vertappens ATS-policy.

Egen retrymotor, automatisk retry på 401/statusfeil, cache-/offline-/fallbackstrategier, telemetry, avansert security og nye transportmoduler inngår fortsatt ikke i v1. URLSession/OS kan ha interne forbindelsesforsøk; «ingen egen retry» er ikke en garanti for én wire-hendelse.

## Verifikasjon og videre porter

Apples dokumentasjon er lest for ephemeral storage, task-level delegate/redirect og ATS-lokalnett. Begrensningene er dokumentert; ingen implementasjon, nettverksprøve eller sikkerhetstest er gjennomført. Testkrav er angitt for originvalidering, loopback-parsing, credential-isolasjon, redirects, lagre, redaction og injeksjonsavvisning.

DEC-07 og F0-porten gjenstår. Sikkerhetsreview og faktiske plattform-/runtime-bevis kreves før release. Denne beslutningen er ingen sikkerhetssertifisering.

## Kilder

- [Apple: ephemeral](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/ephemeral)
- [Apple: URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- [Apple: task-level redirect](https://developer.apple.com/documentation/foundation/urlsessiontaskdelegate/urlsession%28_%3Atask%3Awillperformhttpredirection%3Anewrequest%3Acompletionhandler%3A%29)
- [Apple: NSAllowsLocalNetworking](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking)
