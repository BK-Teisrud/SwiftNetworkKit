# ADR-0009: F0-planlegging godkjent; implementasjon ikke autorisert

Dato: 2026-10-19. Status: Godkjent av prosjekteier i chatten.
Oppgave: [GATE-00 / #28](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/28).

## Godkjenning

Prosjekteier fikk et uttrykkelig spørsmål om godkjenning av det samlede F0-grunnlaget, inkludert dokumenterte standarddetaljer, med lenke til F0_REVIEW.md og klart skille mellom planlegging og kodearbeid.

Prosjekteiers svar var: «Godkjenn F0-planleggingen; fortsatt ingen kode».

Vurderingsgrunnlaget er oversikten og dokumentene publisert gjennom PR #38, commit 2c5ee834a26df761a044bb478bd64fa69381534c. De sju enkeltbeslutningene i ADR-0002–ADR-0008 og deres tilhørende kontrakter godkjennes dermed samlet. Tidligere ADR-er beholdes som historikk; denne ADR-en registrerer den samlede aksepten.

## Beslutning

- Planleggings- og arkitekturgrunnlaget er godkjent.
- Implementasjon er ikke autorisert og har ikke startet.
- Ingen Swift-kode, Package.swift, testtargets, kjørbare workflows, prototyper eller produktrelease skal opprettes uten et senere, uttrykkelig klarsignal fra prosjekteier.
- GATE-00 kan lukkes som ferdig planleggingsbeslutning med dette uttrykkelige utfallet. Lukking er ikke tillatelse til å starte utvikling.

## Konsekvenser

Ingen vedtatte API-/sikkerhets-/testegenskaper hevdes implementert eller testet. Før senere utviklingsoppgaver blir Ready kreves konkret nedbryting, nødvendige symbol-/availabilitykontroller og testbare kriterier etter kontraktene. Faktisk CI, minimums-OS-/runtimebevis, sikkerhetsreview og releaseporter gjenstår til en senere autorisert fase.

OPS-01 / #30 holdes åpen for gjenstående GitHub-oppsett og kontrollpunkter. Det er en separat oppgave. F0-milepælen holdes åpen så lenge den har dette utestående arbeidet; «åtte av åtte beslutningsoppgaver» er ikke en påstand om at alt repoarbeid eller hele milepælen er ferdig.

En framtidig endring av scope, rettigheter, plattformvalg, kontrakter, verktøy eller kostnadsramme må dokumenteres med begrunnelse og nødvendig eiergodkjenning. Et framtidig implementasjonsklarsignal registreres separat; denne beslutningen kan ikke tolkes som et slikt signal.

## Verifikasjon

DEC-01–DEC-07 er dokumentert og avsluttet gjennom PR #32–#38. F0-godkjenningen publiseres gjennom en egen dokumentasjons-PR som lukker #28. JSON, lokale dokumentlenker og diff kontrolleres; fravær av Swift-filer, Package.swift og workflows bekreftes. GitHub har null registrerte workflows, og SHA-låsing for Actions er aktivert. Ingen produktbygg, tester eller publisering utføres som del av dette vedtaket.
