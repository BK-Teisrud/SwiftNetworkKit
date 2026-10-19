# Roadmap

Ingen tidsfrister er satt. Faser er porter, ikke kalenderløfter. F0 → F1 → F2 er foreslått vei til første stabile kjerne. F3–F6 er valgfrie senere leveranser og er ikke del av et løfte om v1.0.

## F0 – Arkitektur og beslutninger

Godkjent lisens, v1-scope, plattform-/verktøymatrise, API- og concurrencybeslutninger. Ingen kode før egen implementasjonsbeslutning.

## F1 – HTTP-kjerne

Valgte endpoint-, request-, response-, feil- og konfigurasjonskontrakter oppfylt; deterministiske tester og reell plattform-CI.

## F2 – Produksjonsherding og v1-port

Privacy/logging, cancellation, auth hooks, sikkerhetsreview, DocC og dokumentert releaseport. v1 først etter alle godkjente kjernekriterier.

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
