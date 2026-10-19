# ADR-0010 – Forberedelser og GitHub-herding før kodestart

Status: Vedtatt innenfor eierens oppdrag om å fullføre forberedelsene. Dato: 2026-10-19.

## Beslutning

Én prosjektstatus erstatter status-labels; nummererte underoppgaver har kriterier og native avhengigheter. Egen START-00 bevarer kravet om uttrykkelig kodegodkjenning. Done lukker ikke issue automatisk. Fullført-visning bruker completed; avviste oppgaver er Not Planned.

Main har ingen bypass. v*-tag-oppretting begrenses til admin gjennom separat creation-unntak, mens update/deletion har egen regel uten unntak. Publiserte releases er immutable. Obligatorisk web sign-off slås av fordi ingen DCO-avtale er valgt. Eier svarte konkret «Ja, gjennomfør begge endringene» på spørsmålet om sign-off og avgrenset tag-unntak. Dette er ikke tillatelse til å opprette en tag eller publisere release.

## Begrunnelse og begrensninger

Dobbeltført status ga risiko for motstridende køer. Deloppgaver med kontrakt/testbevis gir faktisk arbeidsrekkefølge. Ingen required CI-checks ennå, fordi intet produkt finnes; I06 skal innføre reelle checks etter negativ og positiv verifikasjon. Ingen reviewkrav fra en ikke-eksisterende annen maintainer. Ingen signerte commits før signeringsoppsett er avklart.

Eier bekrefter 2FA og nyere enheter av alle typer, men ingen kontaktadresse. Ingen adresse eller minimums-OS-testbevis er oppfunnet. Minimumsbevis er releasekrav; kontakt må avklares før ekstern lisens-/bidragsprosess tilbys. Ingen kjøp, oppgraderinger, tilganger eller betalte tjenester legges til. Admin kan fortsatt endre regler; vern mot kontoeier kan ikke garanteres.

## Verifikasjon

Se SETUP_STATUS.md, PROJECT_MANAGEMENT.md, WORK_QUEUE.md, TEST_ENVIRONMENTS.md og PRE_CODE_READINESS.md. Ingen kode eller workflows innføres av dette vedtaket. ADR-0009 om separat kodegodkjenning gjelder fortsatt.
