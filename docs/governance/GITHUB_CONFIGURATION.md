# GitHub-konfigurasjon

Repo: BK-Teisrud/SwiftNetworkKit. Dette dokumentet beskriver ønsket konfigurasjon; [oppsettsstatus](SETUP_STATUS.md) angir hva som faktisk er aktivert og verifisert. JSON-filer i .github/settings og .github/rulesets er versjonerte konfigurasjonsgrunnlag, ikke automatisk GitHub-synk.

## Generelt

| Innstilling | Valg og begrunnelse |
| --- | --- |
| Synlighet / eier | Public / BK-Teisrud, uttrykkelig valgt av eier |
| Default branch | main |
| Issues / Projects | På; oppgaver og leveranseoversikt |
| Wiki / Discussions | Av; docs i Git og issues gir én kilde |
| Merge | Bare squash; PR-tittel og body som commitgrunnlag |
| Branch cleanup / update | Automatisk sletting etter merge; update branch tillatt |
| Auto-merge | Av inntil ekte kvalitetsporter er etablert |
| Web sign-off | På; attestering, ikke kryptografisk signatur eller egen lisensavtale |
| Template repo / Pages / deploy | Ikke aktivert; ingen nettside eller distribusjon nå |
| Topics | swift, networking, apple, swift-package-manager, urlsession, swift-concurrency |

## Main-regel: main-protection-solo

Aktiv for default branch: ingen sletting, ingen force-push, lineær historikk, PR kreves, alle review-tråder løst, kun squash. Null obligatoriske approvals i solo-profil. Foreldede approvals avvises om de finnes. Admin-bypass er bare tillatt gjennom PR; admin kan administrere selve reglene. Ingen required status checks før reell CI finnes. Dette er en dokumentasjonsfase med manuell verifikasjon, ikke en påstand om automatisert kvalitetskontroll.

Team-overgang: minst én annen kvalifisert write-bruker/CODEOWNER før aktivering av én approval, Code Owner review og godkjenning av siste push fra annen person. Ikke aktiver krav som låser eneste maintainer ute.

## Releasetagger: release-tags-protection

refs/tags/v* beskyttes mot oppretting, oppdatering og sletting for vanlige write-brukere. Repository admin har bypass for å opprette godkjente releasetagger; policy forbyr flytting/sletting også for admin. Ingen tag opprettes nå. Ikke markedsfør tagbeskyttelsen som absolutt vern mot repo-admin.

## Sikkerhet

Dependency graph og Dependabot alerts ønskes aktivert. Secret scanning og push protection ønskes aktivert der repo/konto støtter det. Privat sårbarhetsrapportering aktiveres. Ingen Dependabot-versjonsfil uten manifests; security updates kan ikke gi meningsfull produktbeskyttelse før pakke/dependencies finnes. Code scanning/CodeQL må vurderes etter verktøy- og språkmatrix, og er ikke satt opp nå.

Actions: read-only GITHUB_TOKEN, ingen tillatelse til å opprette/godkjenne PR-er, kun lokale og GitHub-eide actions tillates som forberedende restriksjon. Ingen workflows eller runner-minutter brukes av oppsettet. Full commit-SHA er nå påkrevd gjennom repositoryinnstillingen sha_pinning_required=true, lest tilbake 2026-10-19. DEC-07 / ADR-0008 fastsetter videre CI-/testplan; ingen eksterne reusable workflows eller tredjeparts setup-actions er valgt. Ingen selvhostede runners, secrets, environments, deployments, webhooks eller ekstra apps er opprettet.

Rettighetshaver og rettighetspolicy er vedtatt i ADR-0002: Teisrud Development AS, proprietært, bruk etter særskilt skriftlig tillatelse. Repoet forblir offentlig under BK-Teisrud. Kontosikkerhet (2FA/passkey), private kontaktkanaler og eventuell senere flytting til organisasjon krever separat avklaring. Det er ikke endret andre repoer eller organisasjonsregler.

## Prosjekt og planlegging

21 egendefinerte labels, 7 milepæler uten oppdiktede datoer og 30 startissues, hvor beslutningsoppgaver lukkes etter vedtak. Live status ligger i GitHub. Ingen automatisk stale-lukking. Prosjektfelt og visninger beskrives i PROJECT_MANAGEMENT.md; aktive elementer og API-bevis føres i GITHUB_REGISTER.md og SETUP_STATUS.md.

## Vedlikehold av oppsettet

Kvartalsvis og ved nye maintainere: les tilbake settings/rulesets, tilgang, Actions-policy, Security, milepæler og prosjekt. Endringer går gjennom PR og følges av API/UI-verifikasjon; JSON på disk er ikke bevis på aktiv håndheving. Ingen endring av default branch uten å kontrollere ~DEFAULT_BRANCH-regelen.

## Offisielle kilder kontrollert ved oppsett

- [Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository)
- [Tilgjengelige regler og bypass](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets)
- [GitHub Projects-visninger](https://docs.github.com/en/issues/planning-and-tracking-with-projects/customizing-views-in-your-project/managing-your-views)
- [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)

Offentlige repoer støtter rulesets på GitHub Free. Privat repo ville krevd vurdering av abonnement. Funksjonsnavn og faktisk støtte kontrolleres mot GitHub-responsen for dette repoet.
