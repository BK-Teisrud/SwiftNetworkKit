# Release, versjonering og vedlikehold

Ingen release, tag eller pakke publiseres i oppsettsfasen. Repoet er ikke installerbart ennå.

Etter implementasjonsbeslutning brukes SemVer: 0.x for eksplisitt ustabile prereleases; 1.0.0 først når godkjent kjernescope og releaseport er oppfylt. Fra 1.0: patch for bakoverkompatible feilrettinger, minor for kompatible tillegg, major for brudd. Tagformat vMAJOR.MINOR.PATCH; prerelease eksempel v0.1.0-alpha.1.

## Releaseprosedyre

1. Egen release-PR med scope, verifisert commit, changelog, API-/plattformendringer, kjente problemer og migrasjon.
2. Bekreft grønn faktisk CI, kravsporbarhet, lisens og sikkerhetsvurdering. Fjern aldri funn bare for å få en release ut.
3. Merge til main. Maintainer oppretter verifiserbar annotert/signert tag på godkjent commit; tagger flyttes aldri.
4. Opprett GitHub Release med eksplisitte release notes og SHA. Prerelease markeres som sådan. Ingen auto-publisering nå.
5. Verifiser at fremtidig SPM-produkt kan resolves/buildes fra taggen og at dokumentasjonen peker til riktig versjon.

En feilrelease korrigeres med ny patch/tag. Marker berørt release tydelig; ikke skriv om publisert historikk. Sårbarheter følger SECURITY.md og eventuelt advisory.

## Kompatibilitet

Høyere minimums-OS, inkompatible public API-/Sendable-/feilendringer eller bortfall av dokumentert adferd regnes som breaking fra 1.0. Deprecations dokumenteres med erstatning; planlagt fjerning tidligst neste major, bortsett fra dokumenterte sikkerhetstiltak. Siste stabile minor på gjeldende major får ordinære rettinger. Eldre major støttes bare ved eksplisitt vedtak; lov ikke ubegrenset backport.
