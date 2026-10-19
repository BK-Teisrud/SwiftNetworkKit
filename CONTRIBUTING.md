# Bidrag og arbeidsflyt

Prosjektet er i planleggingsfasen. Ikke start implementasjon før fase 0 er godkjent og implementasjonsarbeid er uttrykkelig besluttet. Teisrud Development AS er valgt rettighetshaver. Prosjektet er proprietært; se [LICENSE](LICENSE).

Feilrapporter og forslag er velkomne. Eksterne bidrag som endrer repoets innhold, aksepteres først etter at en skriftlig bidragsavtale med Teisrud Development AS er avklart. En PR eller sign-off behandles ikke som en automatisk overføring av rettigheter. Ikke send eksterne kodebidrag før dette er avklart. GitHubs gjeldende vilkår gjelder fortsatt for offentlig aktivitet på tjenesten.

1. Finn eller opprett et issue med kravreferanse, avgrensning og akseptansekriterier.
2. Flytt et klart arbeid til Ready; legg inn eier, milepæl, prioritet og avhengigheter.
3. Bruk kortlivet branch fra main: docs/<issue>-<kortnavn>, chore/<issue>-<kortnavn>, senere feat/, fix/, test/ eller refactor/.
4. Åpne draft PR tidlig. Én hensikt per PR. Lenke til issue med Closes #nummer bare når hele oppgaven lukkes.
5. Oppdater relevante dokumenter, ADR, kravsporbarhet og changelog. Dokumenter konkret verifikasjon og risiko.
6. Løs alle review-tråder. Squash-merge med beskrivende tittel, eksempel docs: dokumenter plattformvalg. Branch slettes etter merge.

Ingen direkte push til main etter bootstrap. Ingen develop-branch; release-branch opprettes bare ved dokumentert vedlikeholdsbehov. Ingen krav om daglig aktivitet eller automatisk lukking av gamle issues.

## Klar til arbeid

Problem, omfang/utenfor omfang, krav-ID, testbare kriterier, avhengigheter og estimat er kjent. Ingen blokkerende arkitekturbeslutning er åpen. Sikkerhet og plattformkonsekvenser er vurdert.

## Ferdig

Akseptansekriteriene er oppfylt, relevante kontroller dokumentert, PR merget, docs/risiko/ADR oppdatert og issue lukket. Produktarbeid må i tillegg oppfylle QUALITY.md. Planlagte tester teller aldri som beståtte tester.

Ikke legg tokens, cookies, reelle kundedata, private URL-er, rå request/response-dumper eller personopplysninger i offentlige issues eller fixtures. Bruk syntetiske eksempler.
