# Oppsettsstatus og verifikasjon

Dato: 2026-10-19. Repo: [BK-Teisrud/SwiftNetworkKit](https://github.com/BK-Teisrud/SwiftNetworkKit). Prosjekt: [SwiftNetworkKit Roadmap](https://github.com/users/BK-Teisrud/projects/6), privat og koblet til repoet.

## Opprettet og kontrollert mot GitHub API

| Område | Verifisert resultat |
| --- | --- |
| Repository | Offentlig, default main, korrekt eier/navn/beskrivelse og seks topics |
| Merge | Kun squash; auto-merge av; branch cleanup og update branch på; web sign-off på |
| Funksjoner | Issues og Projects på; Wiki og Discussions av |
| Main | Aktivt ruleset 25428389: PR, løste tråder, lineær historikk, ingen force-push/sletting; admin-bypass bare gjennom PR |
| Releasetagger | Aktivt ruleset 25428391: v* creation/update/deletion begrenset; repo-admin kan utføre releaseoperasjoner |
| Security | Secret scanning og push protection enabled; privat rapportering enabled; vulnerability-alerts svarte HTTP 204 |
| Actions | Read-only GITHUB_TOKEN, PR-approval av, bare lokale/GitHub-eide actions tillatt; full SHA-pinning påkrevd og lest tilbake; null workflows |
| Labels | Alle 21 prosjektlabels finnes. GitHubs standardlabels er beholdt |
| Milepæler | Sju, F0–F6, uten vedtatte forfallsdatoer |
| Issues | 30 startissues med eier, labels, milepæl og akseptansekriterier |
| Avhengigheter | 37 blocked-by-relasjoner mellom beslutninger, arkitekturport, domener og release |
| Prosjekt | 30 issues, felter for Status/Priority/Scope samt Start date/Target date |
| Visninger | Backlog, Arbeidsbrett, Roadmap, Fase 0, Beslutninger, Utvidelser og forskning; arbeidsbrettets kolonner er Status |
| Prosjektautomasjon | Seks innebygde workflows rapportert enabled; intern overgangskonfigurasjon og ende-til-ende-effekt er ikke funksjonstestet |
| Dokumentasjon | README, governance, bidrag, security, samarbeidsregler, changelog, ADR, roadmap, risiko, kravsporbarhet og maler |

Konfigurasjonsgrunnlag ligger i .github/settings og .github/rulesets. Innstillinger er lest tilbake; de er ikke bare forslag i filer. GitHub kan bruke noe tid på å oppdatere prosjekttellinger etter mutasjoner; endelig kontroll krever 30 unike issue-numre og riktige feltverdier.

## Bevis og kontroller

- Effektiv branch-policy er lest med GET /repos/BK-Teisrud/SwiftNetworkKit/rules/branches/main, ikke bare ruleset-definisjonen.
- Repository-settings, begge rulesets, Actions-policy, sikkerhetsfunksjoner, labels og milepæler er lest tilbake.
- Prosjektets visninger, kolonnegruppering, felt og issuekoblinger er lest tilbake via GraphQL/CLI.
- JSON og YAML, lokale dokumentlenker og filinventar kontrolleres før siste dokumentasjons-PR.
- Ingen Swift-filer, Package.swift, testfiler, kjørbare workflows eller releasetagger er lagt til. Ingen produktbygg/test kan hevdes bestått.

## Bevisste åpne valg

Lisens/rettighetshaver er vedtatt i DEC-03 / ADR-0002: Teisrud Development AS og proprietær rettighetspolicy. DEC-02 / ADR-0003 fastsetter HTTP-kjerne først, pakkenavn SwiftNetworkKit og bibliotekprodukt/modul/importnavn NetworkKit med én bibliotekmodul. V1_SCOPE.md avgrenser domenene. DEC-01 / ADR-0004 vedtar iOS/iPadOS 17, macOS 14, watchOS 10 og tvOS 17, med Xcode 26.3+, Swift tools 6.2 og Swift 6-språkmodus. PLATFORM_MATRIX.md skiller vedtak fra utestående symbol-/bygg-/runtime-verifikasjon. DEC-04 / ADR-0005 fastsetter HTTP-/respons-/feilkontrakten. DEC-05 / ADR-0006 fastsetter concurrency/session-eierskap, isolerte snapshots, cancellation/shutdown og 30/60-sekunders grenser. DEC-06 / ADR-0007 fastsetter lagre av som standard, header-provider, HTTPS med loopback-utviklingsunntak og avgrensede redirects/logging/injeksjonsprofiler. DEC-07 / ADR-0008 fastsetter fire PR-plattformer på standardrunners uten betalte tillegg, konkret jobb-/testplan og egne releasebevis. Ingen workflows er opprettet; første reelle CI-PR må verifisere faktiske schemes/destinations/toolchain og gates. Sikkerhets-, minimums-OS- og øvrige runtimebevis gjenstår før release. En avgrenset SDK-deklarasjonskontroll er gjort for enkelte Foundation-symboler, uten produktbygg eller runtime-tester. Fase 0 gir ikke automatisk tillatelse til å starte kode.

Ingen CI-checks er påkrevd ennå, fordi biblioteket ikke finnes. Ingen ekstern reviewer er påkrevd i solo-profil. Ingen signerte commits er påkrevd før signeringsoppsett for relevante aktører er avklart. Kontosikkerhet/2FA er ikke verifisert eller endret. Ingen brukere, nøkler, secrets eller webhooks er lagt til. LICENSE inneholder en proprietær rettighetsnotis etter prosjekteierens valg. Ingen åpen kildekode-lisens eller generell tredjepartstillatelse er gitt.

Oppsettet dokumenterer også begrensninger: Prosjektets interne workflow-overganger er ikke funksjonstestet; fremtidige status-/labelendringer og nye rotissues kontrolleres ved triage. Roadmap-datoer og datointervall velges først når kapasitet er avklart. Ingen automatisk kvalitetsgaranti eller universell plattformstøtte er påstått.

## Neste arbeid

Prosjekteier gjennomgår OPS-01 og beslutningsoppgavene i F0. Arbeid med biblioteket starter først etter eget klarsignal. Dette repooppsettet inneholder ingen implementasjon.
