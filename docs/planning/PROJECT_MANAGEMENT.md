# Prosjektstyring

## Kilder og ansvar

GitHub Issues er autoritativ oppgavebeskrivelse; milepæler angir leveranseporter. Projects gir arbeidsoversikt. Roadmap og ADR-er forklarer hvorfor. Ikke vedlikehold parallelle, avvikende oppgavetekster i prosjektkort. Maintainer @BK-Teisrud eier prioritering og triage. Dokumentasjonen viser baseline; live issue-status er gjeldende.

## Brett

Navn: SwiftNetworkKit Roadmap. Prosjektet holdes privat inntil innholdet er vurdert for offentlig visning; repoets issues er offentlige. Felter: Status (Todo / In Progress / Done; Todo brukes som Backlog/Ready skilt med status-label), Priority (P0/P1/P2/P3), Scope (KJERNE/UTVIDELSE/FORSKNING/STYRING). Bruk innebygde Assignees, Labels, Milestone og Repository. Ingen start-/sluttdatoer settes uten estimat og kapasitet.

Opprettede visninger (API-verifisert):

| Visning | Oppsett |
| --- | --- |
| Backlog | Tabell, åpne issues; Priority og Milestone er tilgjengelige felt |
| Arbeidsbrett | Board gruppert Status, filtrert åpne issues |
| Fase 0 | Milestone F0, vis avhengigheter og beslutninger |
| Roadmap | Roadmap-layout opprettet; Start date/Target date finnes, men datoer er ikke satt |
| Beslutninger | type: decision |
| Utvidelser/forskning | scope: extension / scope: research |

Alle seks visninger er lest tilbake fra GitHub. Arbeidsbrettet har Status som kolonnefelt. Ingen egendefinert sortering eller datointervall-kobling er påstått konfigurert; dette kan tilpasses når arbeidet planlegges. Roadmap vil ikke vise daterte bars før datoer er vedtatt.

## Status og WIP

status: triage → status: ready → status: in-progress → status: review → lukket som completed. status: blocked er eksplisitt; issue-body peker til blokkerende ID/issue. Prosjektstatus Todo omfatter triage/ready/blocked, In Progress omfatter in-progress/review, Done krever lukket med completed. Avvist/duplikat lukkes som not planned med forklaring, og holdes utenfor leveranseoversikten.

Maks ett aktivt implementasjonsissue per utvikler og maks to aktive review-PR-er. Kun Ready kan trekkes inn. P0 = hendelse eller releaseblokker; P1 = neste nødvendige kjernearbeid; P2 = planlagt tillegg; P3 = usikker forskning. Høy prioritet er ikke tillatelse til å starte kode nå.

## Rytme

Ukentlig triage: avklar nye issues, avhengigheter, risiko og neste Ready-arbeid. Før faseovergang: kontroller akseptansebevis og vedta scope. Etter release: vurder feil, sikkerhet og avvik. Ingen sprintdato eller leveringsgaranti er funnet på. Iterasjoner kan innføres etter kapasitet er kjent.

## Automatisering

Ingen GitHub Actions-workflows er opprettet. Prosjektet har seks innebygde workflows som API-et rapporterer som enabled: Auto-add sub-issues to project, Auto-close issue, Item added to project, Item closed, Pull request linked to issue og Pull request merged. Dette er GitHub Projects-funksjoner, ikke produktkode.

Navn og enabled-status er verifisert; de interne overgangsinnstillingene er ikke eksponert i den brukte API-lesingen og er ikke funksjonstestet. Behandle derfor Done som en ferdigmarkering som kan lukke et issue via Auto-close issue; kontroller akseptanse først. Reopened → Todo er ikke verifisert og må kontrolleres manuelt. Ingen påstand om automatisk labelsynk eller full automatisk import av nye rotissues. Ved hver triage kontrollerer maintainer prosjektmedlemskap, status og labels. De 30 startissues er lagt til eksplisitt med Status, Priority og Scope.

## Måling

Følg antall blokkerte oppgaver, gjennomløpstid fra In Progress til Done, eldste WIP og antall åpne releaseblokker. Ikke bruk antall commits eller lukkede issues som mål på produktkvalitet.
