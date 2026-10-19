# Sikkerhet

## Rapporter privat

Bruk GitHubs **Report a vulnerability** under Security på dette repoet når privat rapportering er aktivert. Hvis knappen mangler, opprett et offentlig issue med bare teksten «Ønsker privat kontakt for sikkerhetsrapport», uten detaljer, og vent på en privat kanal. Ikke publiser sårbarhetsdetaljer, credentials eller persondata i offentlige issues.

Maintainer: @BK-Teisrud. Mål: første svar innen tre arbeidsdager, innledende vurdering innen sju. Dette er mål, ikke en døgnbemannet tjeneste eller garantert SLA.

Ingen produktversjoner er lansert. Når 1.0 finnes, vedlikeholdes siste stabile minor på gjeldende major; unntak dokumenteres i release-policy. Pre-release-versjoner har ingen produksjonsgaranti.

## Krav til senere implementasjon

System trust og HTTPS som standard; ingen TLS-bypass. Ingen sensitive logger som standard, ingen ekstern telemetri som standard. Credentials isoleres per konto/host/miljø. Redirect, idempotens, cancellation, cache og samtidighet inngår i sikkerhetsgjennomgang. Pinning, mTLS og OIDC krever separat beslutning og review.

## Hendelser

Bekreft og begrens påvirkning, roter eksponerte secrets hos utsteder, fjern dem fra aktive flater og vurder historikk separat. Ikke anta at sletting av en fil gjør en offentlig hemmelighet trygg. Registrer privat tidslinje, berørte versjoner, retting og koordinert publisering. Publiser advisory og korrigert release når relevant.
