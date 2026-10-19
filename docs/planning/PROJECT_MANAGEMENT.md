# Prosjektstyring

## Kilder og ansvar

GitHub Issues er autoritativ oppgavebeskrivelse; milepæler angir leveranseporter. Projects gir arbeidsoversikt. Roadmap og ADR-er forklarer hvorfor. Ikke vedlikehold parallelle, avvikende oppgavetekster i prosjektkort. Maintainer @BK-Teisrud eier prioritering og triage. Dokumentasjonen viser baseline; live issue-status er gjeldende.

## Brett

Navn: SwiftNetworkKit Roadmap. Prosjektet holdes privat inntil innholdet er vurdert for offentlig visning; repoets issues er offentlige. Felter: Status (Todo / In Progress / Done; Todo brukes som Backlog/Ready skilt med status-label), Priority (P0/P1/P2/P3), Scope (KJERNE/UTVIDELSE/FORSKNING/STYRING). Bruk innebygde Assignees, Labels, Milestone og Repository. Ingen start-/sluttdatoer settes uten estimat og kapasitet.

Ønskede visninger når UI-oppsett er tilgjengelig:

| Visning | Oppsett |
| --- | --- |
| Backlog | Tabell, åpne issues, sortert Priority og milestone |
| Arbeidsbrett | Board gruppert Status, filtrert åpne issues |
| Fase 0 | Milestone F0, vis avhengigheter og beslutninger |
| Roadmap | Roadmap-layout med Start date/Target date først når datoer er vedtatt |
| Beslutninger | type: decision |
| Utvidelser/forskning | scope: extension / scope: research |

Visningene er ønsket UI-konfigurasjon og må verifiseres separat; API-opprettelse av et prosjekt innebærer ikke at visningene finnes.

## Status og WIP

status: triage → status: ready → status: in-progress → status: review → lukket som completed. status: blocked er eksplisitt; issue-body peker til blokkerende ID/issue. Prosjektstatus Todo omfatter triage/ready/blocked, In Progress omfatter in-progress/review, Done krever lukket med completed. Avvist/duplikat lukkes som not planned med forklaring, og holdes utenfor leveranseoversikten.

Maks ett aktivt implementasjonsissue per utvikler og maks to aktive review-PR-er. Kun Ready kan trekkes inn. P0 = hendelse eller releaseblokker; P1 = neste nødvendige kjernearbeid; P2 = planlagt tillegg; P3 = usikker forskning. Høy prioritet er ikke tillatelse til å starte kode nå.

## Rytme

Ukentlig triage: avklar nye issues, avhengigheter, risiko og neste Ready-arbeid. Før faseovergang: kontroller akseptansebevis og vedta scope. Etter release: vurder feil, sikkerhet og avvik. Ingen sprintdato eller leveringsgaranti er funnet på. Iterasjoner kan innføres etter kapasitet er kjent.

## Automatisering

Ingen kjørbare workflows nå. Prosjektets innebygde item-closed/PR-merged → Done og item-reopened → Todo aktiveres bare hvis tilgjengelig og verifisert; ellers oppdaterer maintainer manuelt. Ingen påstand om automatisk labelsynk, issueimport eller avhengighetshåndheving. Ved hver triage kontrolleres at nye issues er lagt til prosjektet, og at status/labels stemmer.

## Måling

Følg antall blokkerte oppgaver, gjennomløpstid fra In Progress til Done, eldste WIP og antall åpne releaseblokker. Ikke bruk antall commits eller lukkede issues som mål på produktkvalitet.
