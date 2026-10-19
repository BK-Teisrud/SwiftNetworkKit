# Roadmap

Ingen tidsfrister er satt. Faser er porter, ikke kalenderløfter. Prosjekteier har vedtatt HTTP-kjerne først: F0 → F1 → F2 er veien til første stabile versjon. F3–F6 er valgfrie senere leveranser og er ikke del av v1.0. Repo/pakke heter SwiftNetworkKit; bibliotekprodukt/modul heter NetworkKit, med én bibliotekmodul. Se [v1-scope](V1_SCOPE.md) og [ADR-0003](../decisions/ADR-0003-v1-scope-and-naming.md).

## F0 – Arkitektur og beslutninger

Lisens/rettigheter, v1-scope, plattform-/verktøymatrise, API-, concurrency-, sikkerhets- og CI-beslutninger er godkjent samlet 2026-10-19 i [ADR-0009](../decisions/ADR-0009-f0-approval-no-implementation.md). **Implementasjon er ikke autorisert; fortsatt ingen kode.** De åtte beslutningsoppgavene er avsluttet etter registrering av vedtaket. Forberedende repoarbeid i OPS-01 / #30 er fullført gjennom ADR-0010 og SETUP_STATUS.md; F0 avsluttes etter denne dokumentasjonsleveransen. START-00 / #41 i F1 bevarer sperren. Ingen kode før et eget uttrykkelig klarsignal.

## F1 – HTTP-kjerne

Valgte endpoint-, request-, response-, feil- og konfigurasjonskontrakter oppfylt; deterministiske tester og reell plattform-CI.

## F2 – Produksjonsherding og v1-port

Privacy/logging, cancellation, nødvendig auth-integrasjonsgrense etter DEC-04/06, sikkerhetsreview, DocC og dokumentert releaseport. v1 først etter alle godkjente kjernekriterier.

## F3 – Resiliens og tillegg

Eksplisitt valgte retry/cache/auth/monitoring/ytelse-moduler med policy- og samtidighetstester.

## F4 – Filoverføringer

Upload/download/progress/cleanup og dokumenterte background-begrensninger per plattform.

## F5 – Sanntid

WebSocket-state, backpressure, reconnect, autentisering og shutdown verifisert.

## F6 – Spesialisert og forskning

Kun ved godkjent produktbehov, teknisk validering, entitlements og separat sikkerhetsgjennomgang.

## Avhengigheter og godkjenning

Endpoint-kontrakt før interceptors/auth/retry. Feiltaksonomi og response-wrapper før API-stabilisering. Cancellation og clock før retry/refresh. Redaction før detaljert diagnostikk. OS-matrise/entitlements før background/Bonjour/multicast. Security review før pinning/mTLS/OIDC.

Et domeneissue kan ikke brukes som én enorm sprintoppgave: bryt ned underpunktene til separate testbare issues før Ready. F0 skal godkjenne inkluderte og utsatte delkrav for alle KJERNE-domener. Utvidelser kan ikke trekkes inn i v1 uten oppdatert scope og konsekvensvurdering. Faseporter lukkes først med lenker til faktiske bevis.
