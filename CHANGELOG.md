# Endringslogg

## Unreleased

### Prosjektoppsett

- GATE-00 / #28 vedtatt: samlet F0-planlegging og standarddetaljer godkjent av prosjekteier. Implementasjon er ikke autorisert; ingen kode. OPS-01 / #30 og F0-milepælen holdes åpne for gjenstående repoarbeid.

- Repo, arbeidsflyt, sikkerhetspolicy, roadmap, kravsporbarhet og oppgavemaler etablert.
- Ingen bibliotekskode eller produktrelease. Ingen SemVer-tag opprettet.
- DEC-07 vedtatt: standard GitHub-runners uten betalte tillegg, fire PR-plattformfamilier og egen release-/minimums-OS-kontroll. SHA-pinning for Actions er aktivert; ingen workflows er opprettet.
- DEC-06 vedtatt: ingen automatiske cookie-/credential-/cachelagre, injiserbar auth-header-provider, HTTPS med eksplisitt loopback-unntak og avgrenset redirect-/injeksjons-/diagnostikkpolicy.
- DEC-05 vedtatt: gjenbrukt egen session pluss injeksjon, 30 sekunder inaktivitet / 60 sekunder samlet budsjett, isolert state, cancellation og kontrollert shutdown.
- DEC-04 vedtatt: typed endpoints og rå URLRequest, respons-wrapper, JSON/Data/tekst/tomt, strukturerte feil med separat CancellationError og eksplisitte HTTP-statusunntak.
- DEC-01 vedtatt: iOS/iPadOS 17, macOS 14, watchOS 10 og tvOS 17; Xcode 26.3+, Swift tools 6.2 og Swift 6-språkmodus. Plattformmatrise skiller støtteplan fra utestående testbevis.
- DEC-02 vedtatt: HTTP-kjerne først. Repo/pakke SwiftNetworkKit; produkt/modul/importnavn NetworkKit, én bibliotekmodul i v1.
- DEC-03 vedtatt: Teisrud Development AS er rettighetshaver; proprietær rettighetspolicy med særskilt skriftlig tillatelse for tredjepartsbruk.
