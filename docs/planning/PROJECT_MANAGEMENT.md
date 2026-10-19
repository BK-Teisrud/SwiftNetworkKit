# Prosjektstyring

GitHub Issues beskriver oppgaver og akseptansekriterier. Milepæler er leveranseporter. Projects viser arbeidsstatus; roadmap og ADR-er begrunner valgene. Maintainer @BK-Teisrud prioriterer. Prosjektet [SwiftNetworkKit Roadmap](https://github.com/users/BK-Teisrud/projects/6) er privat; repoets issues er offentlige.

## Én arbeidsstatus

Prosjektfeltet Status er eneste arbeidsstatus: Backlog → Ready → In Progress → In Review → Done. Blocked angir en konkret sperre; Not Planned brukes for avvist/duplikat. Tidligere status-labels er fjernet for å unngå dobbeltføring. Issues sin open/closed og state reason angir faktisk avslutning. Done krever completed og oppfylte akseptansekriterier; å dra et kort til Done lukker ikke issue.

Ready krever uttrykkelig kodegodkjenning der relevant, lukkede blokkere, tydelig kontrakt/testplan og symbolkontroll for faktisk valgte API-er. Dependency-lenker er planleggingshjelp, ingen automatisk merge-sperre. En gjenåpnet oppgave går til Backlog og må triageres på nytt. Not planned settes manuelt i prosjektet etter lukking, fordi Item closed setter Done uten skille på årsak. Ferdig-visningen filtrerer på completed og skjuler dermed avviste oppgaver uansett prosjektfelt.

Maks én aktiv implementasjonsoppgave per utvikler og to review-PR-er. Kun Ready trekkes inn. P0 er hendelse/port, P1 nødvendig kjerne, P2 senere tillegg, P3 forskning. Prioritet gir ikke tillatelse til å kode.

## Felter og visninger

Status, Priority (P0–P3), Scope (KJERNE/UTVIDELSE/FORSKNING/STYRING), Order og innebygde Title/Assignees/Milestone/Parent issue vises i arbeidsoversiktene. Labels beskriver type/scope/prioritet; ved triage samsvares Priority/Scope med labels. Dette synkroniseres ikke automatisk. Ingen oppdiktede start-/sluttdatoer.

| Visning | Bruk |
| --- | --- |
| Backlog | Alle åpne oppgaver, også epics og senere scope |
| Arbeidsbrett | Status-kolonner, også Done; Not Planned skjules |
| Roadmap | Faseoversikt uten oppdiktede daterte leveransebarer |
| Fase 0 | Åpne oppsettsoppgaver i F0 |
| Beslutninger | Beslutningsissues |
| Utvidelser og forskning | Utsatt scope |
| Arbeidskø | Åpne konkrete oppgaver uten epics/utvidelser/forskning, flat tabell sortert Order stigende |
| Ferdig | Lukkede issues med reason:completed |

Se [WORK_QUEUE.md](WORK_QUEUE.md) for den nummererte rekkefølgen. Order 0 er startporten; I01–I23 er 1–23; releaseporten er 24. Ingen produktoppgaver er Ready før kodegodkjenning. Epics brukes til sporbarhet, ikke som enorme enkeltoppgaver.

## Innebygde workflows

Dette er Projects-funksjoner; ingen GitHub Actions-workflows er opprettet.

| Workflow | Tilstand / begrunnelse |
| --- | --- |
| Auto-add to project | På, bare SwiftNetworkKit, filter is:issue; nye/oppdaterte rotissues importeres |
| Auto-add sub-issues | På; underoppgaver beholdes i samme prosjekt |
| Item added | På → Backlog; triage av Priority/Scope/Order kreves |
| Item closed | På → Done; Not Planned korrigeres manuelt som beskrevet over |
| Item reopened | På → Backlog |
| Pull request merged | På → Done for PR-elementet; issue lukkes først ved faktisk avslutning |
| Auto-close issue | Av; statusdrag skal ikke avslutte arbeid |
| Pull request linked to issue | Av; en lenke skal ikke omgå startport eller starte arbeid |
| Auto-archive / review approved / changes requested | Av; bevar historikk og unngå falske solo-reviewoverganger |

Oppsettsissue #40 brukes til funksjonstest av import, Done uten lukking, completed og reopened. Resultat og avgrensninger registreres i [oppsettsstatus](../governance/SETUP_STATUS.md). PR-/subissue-reglene er konfigurert og lest, men skal ikke fremstilles som separat ende-til-ende-testet uten bevis.

## Vedlikehold

Ukentlig triage: nye issues, manglende felt, blokkere, WIP og neste Ready. Før faseovergang kontrolleres faktiske bevis. Etter release vurderes feil og risiko. Ingen sprintdato eller SLA er funnet på. Følg blokkert arbeid, gjennomløpstid og eldste WIP; antall commits er ikke produktkvalitet.
