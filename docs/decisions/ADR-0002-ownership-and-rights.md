# ADR-0002: Rettighetshaver og proprietær rettighetspolicy

Dato: 2026-10-19. Status: Godkjent av prosjekteier i chatten.
Beslutningsoppgave: [DEC-03 / #3](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/3).

## Kontekst

Prosjekteier har valgt Teisrud Development AS som rettighetshaver og svart «Bruk krever tillatelse fra Teisrud Development AS». Repoet skal fortsatt være offentlig under BK-Teisrud, som tidligere besluttet. Repoets kontoeier og innholdets valgte rettighetshaver er separate roller.

## Alternativer

- En permissiv åpen kildekode-lisens kunne tillatt tredjepartsbruk, også kommersiell bruk, uten særskilt tillatelse. Ikke valgt.
- En delingspliktig lisens kunne gitt generell brukstillatelse med vilkår om deling av visse endringer. Ikke valgt.
- Proprietær policy med særskilt tillatelse gir selskapet kontroll over tredjepartsbruk. Valgt uttrykkelig av prosjekteier.

## Beslutning

Teisrud Development AS angis som rettighetshaver. Ingen åpen kildekode-lisens eller generell tredjepartsbrukstillatelse gis. Bruk utover lovbestemte rettigheter og GitHubs gjeldende vilkår krever særskilt skriftlig tillatelse fra selskapet. Rettighetsnotisen ligger i LICENSE og gjelder repoets eget innhold; den er ikke en ferdig kommersiell lisensavtale.

Offentlig synlighet beholdes. Rettighetsnotisen forsøker ikke å oppheve rettigheter GitHub gir til visning og forking gjennom tjenesten. Prosjektet skal ikke presenteres som open source. Ved behov for fortrolig kildekode må synligheten vurderes separat; denne beslutningen endrer ikke synlighet.

## Bidrag og distribusjon

Feilrapporter og forslag er velkomne. Eksterne bidrag som endrer innhold, aksepteres først etter en avklart skriftlig bidragsavtale med selskapet. Ingen rettighetsoverføring fra tredjepart antas ut fra en PR, CODEOWNERS eller GitHub sign-off. Ingen CLA eller kommersiell standardavtale er opprettet nå.

Før ekstern distribusjon skal aktuell tillatelse/avtale, omfang, mottaker og eventuelle vilkår være avklart. Ingen priser, supportløfter eller nye kontraktsvilkår er bestemt. Ved innføring av tredjepartsmateriale må eventuelle egne rettigheter og vilkår håndteres separat.

## Konsekvenser og verifikasjon

README, bidragspolicy, styring, risiko og aktive beslutningsoversikter oppdateres. DEC-03 kan lukkes etter merge. F0 og implementasjon er fortsatt blokkert av øvrige beslutninger og krever eget klarsignal.

Beslutningen dokumenterer prosjekteierens valg av rettighetshaver; den er ikke en gjennomført kontroll av historiske ansettelses-, oppdrags- eller overdragelsesavtaler.

## Kilder

- [GitHub: Licensing a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- [GitHub Terms of Service, User-Generated Content](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#d-user-generated-content)

ADR-0001 beholdes som historisk oppsettsbeslutning. Denne ADR-en avgjør lisens-/rettighetsspørsmålet som da var åpent.
