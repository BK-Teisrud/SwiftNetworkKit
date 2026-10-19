# Forvaltning

Rettighetshaver: Teisrud Development AS, etter prosjekteierens beslutning i ADR-0002. GitHub-kontoeier og maintainer: @BK-Teisrud. Tredjepartsbruk reguleres av LICENSE og eventuell særskilt skriftlig tillatelse fra selskapet. Eieren vedtar scope, prioritet, rettigheter, plattformstøtte og release. Bidragsytere foreslår endringer gjennom issues og pull requests.

## Beslutninger

Varige valg føres i ADR-er med status Foreslått, Godkjent, Erstattet eller Avvist. Arkitektur, offentlig API, lagring, autentisering, nye moduler, verktøyavhengigheter og sikkerhetsunntak krever beslutningsgrunnlag. Endring av roadmap krever oppdatert milepæl, backlog, risiko og begrunnelse.

## Tilgang og review

Minst mulig tilgang. Ingen ekstra samarbeidspartnere, deploy keys, apper, webhooks eller secrets opprettes som del av dette oppsettet. Eieren bør bruke 2FA/passkey og recovery-koder; dette er en kontoinnstilling og er ikke verifisert her.

Solo-profil: alle endringer etter bootstrap går gjennom PR; ingen påkrevd ekstern godkjenning fordi forfatter ikke kan godkjenne egen PR. CODEOWNERS angir ansvar, men er ikke alene en review-sperre. Sikkerhetsrelevante endringer får eksplisitt risikovurdering og dokumentert egenkontroll.

Team-profil aktiveres først når en annen kvalifisert person har write-tilgang: minst én godkjenning, Code Owner review, avvis foreldede godkjenninger og krev godkjenning av siste push fra en annen person. Ingen udokumentert bypass.

Akutte hendelser: opprett privat sikkerhetssak, begrens skade og dokumenter tiltak. Regelbypass brukes kun av repo-admin, via PR, med begrunnelse og etterkontroll senest neste arbeidsdag. Konto-/organisasjonseier kan fortsatt endre reglene; repooppsett kan ikke eliminere denne fullmakten.
