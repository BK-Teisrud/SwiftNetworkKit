# Concurrency, session-eierskap og livssyklus i v1

Status: Planlagt kontrakt 2026-10-19, se [ADR-0006](../decisions/ADR-0006-concurrency-and-lifecycle.md). Ingen produktkode eller tester finnes.

## Samtidig bruk og isolering

Samme klient skal kunne brukes trygt fra flere tasks uten global singleton eller session per request. Offentlige klientgrenser, requestkonfigurasjon og verdier som deles mellom tasks skal oppfylle valgt Swift 6-/Sendable-kontrakt. Appens modeller må være egnet for kontrakten; biblioteket skal ikke skjule usikker delt tilstand med et generelt unchecked Sendable-stempel.

Klientkonfigurasjon er uforanderlig etter oppretting. Per-kall-overrides tas som eget snapshot. Endringer hos kalleren mens et request kjører, skal ikke endre dette requestet. Body/headers/baseURL og valgt decoderpolicy tilhører snapshotet.

Delte registreringer av aktive requests, livssyklus og terminalårsaker actor-/synkroniseringsisoleres. Ikke hold en lås over await. Nettverksventing og response-dekoding skal ikke gjøres til én global seriekø. Klienten er ikke MainActor-isolert; adaptere/closures får dokumenterte Sendable-/isolasjonskrav i senere API-review. Ingen automatisk overføring av hele operasjonen til en ustrukturert detached task for å skjule slike krav.

Encoder/decoder opprettes eller eies per operasjon ut fra fastlagt strategi. Delt mutasjon av JSONEncoder/JSONDecoder under samtidige kall er ikke støttet. Appdefinerte encoding-/decodinghooks må følge dokumenterte samtidighetskrav og får ikke mutere delt usikret tilstand.

Batch-API, generell deduplisering, rate limiter, ressurskø og offentlig schedulingrammeverk inngår ikke i v1. Samtidig bruk gir ingen garanti for transportrekkefølge eller et ubegrenset antall samtidige forbindelser; URLSession/OS styrer transportressursene.

## Egen versus injisert session

| Eierskap | Oppretting og gjenbruk | Hva shutdown kan gjøre |
| --- | --- | --- |
| Egen session | Klienten oppretter én session fra et konfigurasjonssnapshot og gjenbruker den | Stenge klienten, kansellere dens operasjoner og ugyldiggjøre denne sessionen |
| Injisert session | Appen oppretter/eier sessionen; klienten låner den | Stenge klienten og kansellere bare operasjonene klienten selv har opprettet; aldri ugyldiggjøre/reset/flush hele sessionen |

En injisert session som også brukes utenfor klienten, skal ikke få andre tasks avbrutt av klientens timeout eller shutdown. Ikke bruk sessionens getAllTasks + cancel som erstatning for et register over egne operasjoner. Klienten muterer ikke den injiserte sessionens globale konfigurasjon, cookie-/credential-/cachelagre som en skjult sideeffekt.

Bare foreground datarequests innenfor HTTP-kjernen støttes. Bakgrunnssessions og body-stream-varianter faller utenfor v1 og skal avvises eksplisitt. Appens eksterne invalidation av en lånt session kan fortsatt stoppe klientens requests; dette kan ikke repareres ved å opprette en ny session skjult.

[Sikkerhetspolicyen](SECURITY_AND_NETWORK_POLICY.md) / ADR-0007 fastsetter lagringsprofil, provider- og delegategrenser ved injeksjon. En session som ikke lar klienten oppfylle den avtalte kontrakten, må få dokumentert avvisning fremfor en skjult svekkelse.

## Standardgrenser og presedens

| Felt | Standard | Betydning |
| --- | --- | --- |
| Inaktivitet / request-timeout | 30 sekunder | URLSessions ventetid på nye data; nye data nullstiller timeren. Dette er ikke en generell totalfrist eller garanti for måling i alle OS-faser |
| Samlet tidsbudsjett | 60 sekunder | Monotont budsjett fra operasjonens inngang til sluttkontroll før responslevering |

Eksplisitt per-kall-valg har forrang foran klientvalg, som har forrang foran bibliotekets 30/60-standard. Varigheter må være endelige og positive; NaN, negativ, null og uendelig avvises før nettverk. Klienten kan ha et kortere samlet budsjett enn inaktivitetsgrensen; da vinner den først utløpte grensen.

Raw URLRequest bruker også denne policyen. Fordi URLRequest allerede har en standard timeoutverdi, regnes ikke den egenskapen alene som et uttrykkelig per-kall-overstyringsvalg. Konsumenten angir et slikt valg gjennom klientens kallpolicy, og den effektive request-timeouten settes på den utførte request-kopien. Dette skal stå i den senere API-dokumentasjonen.

Appens injiserte session kan ha en kortere resource-timeout eller andre systembegrensninger. Et lengre budsjett i biblioteket kan ikke forlenge dem. Den eide sessionens resource-timeout må heller ikke feilaktig låses til 60 sekunder slik at lengre, eksplisitte kallvalg blir lovet uten å fungere. Skill systemets resource-grense fra bibliotekets budsjett og dokumenter den effektive begrensningen.

Vent på connectivity kan ha andre systemregler enn request-timeout. Bibliotekets samlede budsjett gjelder fortsatt ved eventuell slik venting; ADR-0007 setter waitsForConnectivity av som standard, med eksplisitt appvalg for systemventing innen samlet budsjett.

## Klokke, frist og opprydding

Bruk en monoton klokke, planlagt ContinuousClock i produksjon. Ikke bruk Date/veggklokke til elapsed/deadlineberegning. Budsjettet starter før requestforberedelse og inkluderer encoding, tillatte hooks, transport og responsbehandling. ContinuousClock øker også mens systemet sover, men garanterer ikke at prosessen vekkes akkurat ved fristen.

En intern injiserbar clock/sleeper-grense lar tester flytte tid uten faktisk venting. Ingen ekstern clock-dependency eller offentlig generell scheduler opprettes. Timeoutwatchdog og operation må ha tydelig eierskap, være kansellerbare og ryddes opp ved alle terminalutfall. En task group venter på sine child tasks; å velge den første ferdige tasken er ikke alene en korrekt timeoutimplementasjon.

Ved fristutløp registreres timeoutårsak og den relevante requesten avbrytes. Cancellation/deadline kontrolleres før nettverksstart, etter ventepunkter og før responsreturnering. Synkron encoding/decoding eller apphooks kan ikke tvangsavbrytes av Swift cancellation. Et slikt arbeid kan forsinke retur; kontrakten gir ingen hard sanntidsgaranti. Når kontrollen kommer tilbake etter utløpt budsjett, leveres timeout fremfor et sent suksessresultat.

## Cancellation og entydige terminalutfall

| Hendelse | Synlig resultat |
| --- | --- |
| Kalleren er kansellert ved inngang eller kansellerer aktiv operasjon | CancellationError; underliggende arbeid og venting avbrytes så langt systemet støtter |
| Klientens samlede budsjett utløper | NetworkError.timeout, selv om nettverkstasken avslutter med et cancel-signal |
| Systemet melder faktisk timeout | NetworkError.timeout med årsaks-/systemkode bevart uten sensitive beskrivelser |
| Shutdown av klienten avbryter en aktiv operasjon | CancellationError med shutdownårsak i personverntrygg intern diagnostikk |
| Ekstern session-invalidation eller uforklart URLError.cancelled | Transportfeil med bevart årsak, med mindre klienten kan knytte signalet til sin egen registrerte cancellation/timeout/shutdown |
| Gyldig suksess eller annen feil fullføres før avbrudd er registrert | Det allerede valgte terminalutfallet beholdes |

Hver operasjon får nøyaktig ett terminalutfall og én cleanup. Første registrerte terminalhendelse i den isolerte tilstanden vinner ved reelle races; en observert allerede-kansellert task eller utløpt deadline må kontrolleres før suksess kan registreres. Ikke gi vilkårlig forskjellig feilkategori ut fra hvilket URLSession-callback som tilfeldigvis leses sist. Callback etter fullføring skal ikke returnere et nytt resultat eller gjenopplive operasjonen.

Å kansellere ett kall skal ikke kansellere andre. Ingen automatisk retry, refresh, detached restarbeid eller beholdt watchdog etter fullføring. En sendt muterende HTTP-request kan allerede ha hatt en servereffekt selv om klienten kanselleres; cancellation er ikke transaksjonsrollback.

## Shutdown

Planlagt eksplisitt shutdown er idempotent og går fra åpen via stenging til stengt. Nye kall etter at stenging er registrert, avvises som invalidRequest med klient-stengt-årsak før nettverk. Pågående egne operasjoner kanselleres og deres registreringer/watchdogs ryddes opp. Bare egen session ugyldiggjøres.

Shutdown må ikke vente på et aktorlåsende kall som forhindrer operasjoner fra å rydde opp. Flere samtidige shutdownkall deler samme ferdigstilling. Hvis ventende shutdown selv kanselleres, skal den allerede initierte stengingen ikke reverseres eller miste oppryddingseierskapet. Ingen permanent gjenåpning av en stengt klient; opprett ny klient ved behov.

V1 har ikke en separat «la alle requests kjøre ferdig»-modus. Appen kan vente på egne kall før shutdown. Deinit er ikke en asynkron fullføringsgaranti; eksplisitt shutdown dokumenteres ved klienter som skal stenges kontrollert. Ingen app-eid session eller appens andre oppgaver berøres av slik opprydding.

## Påkrevde tester etter implementasjonsklarsignal

1. Samtidige kall på samme klient, isolerte snapshots og ingen global serialisering av nettverksarbeid.
2. Gjenbruk av egen session; injisert session forblir brukbar for andre etter klientens shutdown.
3. Avbrudd før requeststart, under nettverksventing og ved response-dekodingens kontrollpunkter; ett kall påvirker ikke andre.
4. Med kontrollert klokke: 30/60-standard, per-kall-overrides, totalfrist også ved connectivityventing, ingen sen suksess og ryddet watchdog.
5. Timeout versus brukeravbrudd versus ekstern invalidation, samtidige completion/cancel/shutdown og nøyaktig én terminalhendelse/cleanup.
6. Idempotent shutdown, avvisning av nye kall, kansellert shutdownventer og ingen venting som låser egen opprydding.
7. Ugyldige varigheter, raw-request-presedens, session med strengere resource-grense og ingen feilaktig garanti for harde frister i synkron kode.

Disse er planlagte akseptansebevis, ikke beståtte tester. [CI_AND_TEST_PLAN.md](CI_AND_TEST_PLAN.md) / ADR-0008 fastsetter testinfrastruktur og planlagt matrise; faktisk CI-/runtime-verifikasjon gjenstår. F0 og uttrykkelig klarsignal kreves fortsatt før kode.
