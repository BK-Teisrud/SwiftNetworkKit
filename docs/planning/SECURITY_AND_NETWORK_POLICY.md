# Sikkerhet, autentisering og nettverkspolicy for v1

Status: Planlagt kontrakt 2026-10-19. Hovedvalg er godkjent av prosjekteier i [ADR-0007](../decisions/ADR-0007-security-and-network-policy.md); detaljene konkretiserer secure defaults. Ingen implementasjon eller beståtte sikkerhetstester finnes.

## URL, tillatte origins og lokal utvikling

Produksjonsstandard er HTTPS med OS-ets system trust. En klient har en eksplisitt base-origin (scheme, normalisert host, effektiv port). Typed endpoints kan ikke endre den gjennom path/query. Rå requests til andre origins krever at den destinasjonen er eksplisitt tillatt i klientkonfigurasjonen før utførelse. En tillatt destinasjon betyr ikke at credentials kan deles mellom origins; auth-kontekst er bundet til konkret origin og appens konto-/miljøgrense.

Et eget, eksplisitt utviklingsvalg kan tillate HTTP bare til den normaliserte verten localhost eller en gyldig loopback-IP (127.0.0.0/8 eller ::1). Bruk faktisk URL-/IP-parsing; ikke suffix-/substringregler, skjulte tallrepresentasjoner eller DNS-oppslag som generell tillatelse. localhost.example.com, .local, RFC1918/LAN-adresser og andre domener omfattes ikke. IP-baserte IPv6-/IPv4-varianter må behandles konservativt; en form som ikke entydig valideres som loopback, avvises.

Utviklingsvalget er av som standard og skal ikke aktiveres automatisk bare fordi URL-en inneholder et kjent navn. Ikke legg til eller svekk ATS-innstillinger i vertappen; nødvendige, snevre OS-/appunntak må appen selv vurdere og verifisere per plattform. Bibliotekets URL-tillatelse er ikke en garanti for at OS tillater forbindelsen.

Ingen auth-provider eller sensitive credential-headers brukes over HTTP, heller ikke i loopback-unntaket. En lokal tjeneste som trenger auth, bruker HTTPS etter standard trustregler. Ingen aksept av ugyldige sertifikater, TLS-bypass, egendefinert kryptografi eller automatisk installasjon av trust-røtter.

## Cookies, credentials og cache

Egen standardsession bygges fra ephemeral konfigurasjon, men lagring deaktiveres i tillegg eksplisitt:

- Ingen httpCookieStorage og ingen automatisk mottak/sending av cookies i konfigurasjon/request.
- Ingen URLCredentialStorage og ingen automatisk Basic/Digest-/klientidentitetsinnlogging fra lagre.
- Ingen URLCache; requestpolicy som ikke bruker lokal cache. Ingen skjult egen minne-/diskcache.
- Ikke skriv payloads, tokens, cookies eller diagnostikk til filer som en bibliotekssideeffekt.

Ephemeral alene tillater systemdata i RAM og er derfor ikke tilstrekkelig for den valgte standarden. Aktive requests og auth-headers finnes nødvendigvis midlertidig i minnet; dette er ingen garanti om null kopier, sikker minnesletting eller fravær av OS-/appstyrt diagnostikk.

En eksplisitt appstyrt lagringsprofil kan tilpasse URLSessions standardlagre/cache eller låne en app-eid session med slike lagre. Profilen skal beskrive den faktiske lagringen og appens ansvar for kontoisolasjon, kapasitet og sletting. Dette gir ingen ny egen cache-/offline-/TTL-strategi. Automatisk lagring forblir av uten dette uttrykkelige valget. En appstyrt profil må ikke svekke HTTPS-, origin-, redaction- eller redirectreglene.

## Auth-provider og headerpresedens

Appen kan injisere en asynkron provider for auth-headers. Providerens input begrenses til nødvendig origin, request-ID/metode og eksplisitt konto-/miljøkontekst; ingen automatisk tilgang til body, alle headers eller rå URL-parametere. Provider implementeres sikkert for samtidige kall eller isoleres av appen, og omfattes av operasjonens cancellation og totale tidsbudsjett.

Appen eier login, token-/Keychainlagring, fornyelse, utlogging og kontovalg. Ingen automatisk refresh på 401, skjult replay eller auth-provider-loop. Provider brukes én gang per opprinnelig operasjon; verdien skal ikke kopieres til en ny origin ved redirect. Caller kan eksplisitt velge et public/no-provider-kall. Dette slår ikke av sikkerhetsregler; appen må også unngå å legge egne sensitive headers på et public-kall.

Normale defaults viker for eksplisitte request-headers som beskrevet i HTTP-kontrakten. Providerens headers valideres med samme navn-/CRLF-regler. Hvis provider og en eksplisitt auth-header angir forskjellige verdier for samme navn, avvises konflikten som invalidRequest fremfor en skjult credential-overstyring. Like verdier er ikke to ulike credentials. Globale sensitive headers må være origin-/kontoavgrenset; et rått kall til en annen tillatt origin arver dem ikke.

URL-userinfo og query-baserte hemmeligheter er ikke støttede auth-mekanismer. Providerfeil før nettverk normaliseres til en trygg invalidRequest med providerfeilårsak; egen timeout/cancellation beholder kategoriene fra livssykluskontrakten. Rå providerfeiltekst dumpes ikke til logs.

## Redirects og system trust

Automatisk redirect gjelder som standard bare GET/HEAD innen samme normaliserte origin og med samme metode. Hver destinasjon valideres på nytt mot URL-/scheme-/utviklingsreglene. Maks fem fulgte hopp per operasjon; løkker/overskridelse avvises med en trygg invalidResponse-årsak. Samme-origin betyr også samme effektive port, ikke bare samme hostnavn.

Cross-origin redirects, HTTPS → HTTP og redirects som innebærer replay av en muterende forespørsel følges ikke automatisk i v1. Delegate avviser redirect uten å sende request til målet. Den returnerte 3xx-responsen behandles etter vanlig statuskontrakt; et eksplisitt godkjent 3xx-svar kan leses av appen, men gir ikke tillatelse til automatisk videreføring. En app kan gjøre et nytt, separat validert kall etter eget bevisst valg.

Credentials, cookies og app-spesifikke sensitive headers sendes aldri automatisk til en annen origin. Tidsbudsjett fra opprinnelig inngang gjelder gjennom eventuelle tillatte redirects; det nullstilles ikke ved hvert hopp. Begrensningen gjelder både typed og raw requests.

Trust-challenges bruker systemverifisering. Auth-provider er ikke en challenge-/trust-provider. Ikke lever credentials for HTTP Basic/Digest/mTLS fra systemlagre som en skjult fallback; slike auth-funksjoner er ikke del av denne v1-grensen.

## Injisert session

Injeksjon er et uttrykkelig tillitsforhold til appen. Klienten endrer ikke sessionens globale konfigurasjon, delegate eller lagre, og ugyldiggjør den aldri. Ved oppretting kontrolleres tilgjengelig konfigurasjon og kompatibilitet med valgt lagrings-/sikkerhetsprofil. Bakgrunnssessions avvises; de kan følge redirects uten den kontrollen denne kontrakten krever.

Streng standardprofil krever at injisert session også har deaktiverte lagre og automatisk cookiehåndtering. Vanlig URLSession.shared eller default-session med aktive standardlagre må derfor ikke godtas som streng standard uten eksplisitt appstyrt lagringsprofil.

Requests skal bruke klientens per-task delegate-/policygrense for redirect- og task-level challengekontroll der valgt URLSession-API gir dette. En eksisterende session-delegate kan ikke byttes og kan håndtere session-level trust-challenges. Derfor godtas i v1 ingen vilkårlig ekstern session-delegate som kan overstyre trust/auth/redirectpolicy; slike kombinasjoner avvises fremfor å hevdes kompatible. En minimal session uten en slik ekstern delegate er den planlagte injeksjonsbaselinen.

Testtransport med URLProtocol kan brukes eksplisitt i tester. Det gir ikke produksjonsbevis for TLS, cookie-/cachepolicy eller faktisk nettverk. Appens egen kode/custom transports, proxies, OS-policy og eksterne endringer er utenfor en biblioteksikkerhetssandbox. Dersom nødvendig kontroll ikke kan dokumenteres eller håndheves i implementasjonen, skal kombinasjonen avvises og avviket tas opp før release; ikke endre systemsemantikk skjult.

## Retry, offline og nettverkskostnad

NetworkKit utfører ingen egen automatisk retry, 401-refresh, statusbasert replay, connectivity-probe eller offline-cachefallback i v1. Ett bibliotekskall starter én logisk HTTP-operasjon, men URLSession/OS kan ha intern tilkoblingshåndtering. Tillatte redirects er ikke en generell retrypolicy. Ikke lov nøyaktig én wire-request eller rollback av en allerede sendt mutasjon.

Standard waitsForConnectivity er av for egen session; appen kan velge systemets venting eksplisitt innen samme samlede tidsbudsjett. Bruk faktisk requestresultat, ikke path-monitor som forhåndsgaranti. Cellular/expensive/constrained følger URLSessions systemstandard med eksplisitte klientvalg ved behov, uten oppdiktede energigarantier eller global mutable policy. Ikke innfør nyere plattformspesifikke egenskaper uten availabilitykontroll.

## Logger, feil og error-body

Ingen ekstern telemetri, analytics, tracking eller SaaS-sink følger biblioteket. Lokale diagnostikkhendelser bruker som standard kun en liten allowlist: tilfeldig request-ID, kjent standardmetode (eller klassifikasjonen «custom», uten rå egendefinert metodestreng), status, målt varighet og trygg feil-/terminalkategori. Ingen rå URL, hostname/path/query/fragment, body, headers, credentials, modellbeskrivelser eller underliggende localizedDescription logges automatisk. Logging kan slås av.

Appstyrte sinks får den samme sanerte hendelsesmodellen; ingen automatisk rå request/response-hook for å omgå redaction. Hvis vertappen selv logger sensitive verdier utenfor biblioteket, ligger dette utenfor bibliotekets beskyttelse.

En HTTP-statusfeil inneholder ikke rå error-body som standard, og v1 tilbyr ikke en egen valgfri error-body-capture-mekanisme. Det opprettes ingen ekstra beholdt kopi eller payload i feiltekst. URLSession-dataAPI-et kan allerede ha lest responsen i minnet; dette er ikke en garanti om null nettverks-/minnebruk for feilsvar. En app som trenger en bestemt API-feilpayload, kan uttrykkelig godkjenne statusen og velge JSON/Data-respons under samme øvrige kontrakt.

Status/headers returneres til appen etter HTTP-kontrakten, men automatisk feilbeskrivelse og logging eksponerer ikke sensitive headerverdier. Bevar nødvendige systemfeilkoder/årsaker uten å presentere et underliggende errorobjekt som «trygt å logge».

## Senere akseptansebevis

- Ingen automatisk cookie-/credential-/cachelagring i streng profil; explicit opt-in skiller faktisk appstyrt lagring fra standarden.
- Auth-provider, eksplisitte headers, konflikter, opt-out, origin-/kontoavgrensning og cancellation/deadline gjennom provider.
- HTTPS/system trust; utviklingsunntak av som standard; localhost/gyldig loopback versus lookalikes, IP-varianter, private LAN og redirects ut av loopback.
- Ingen credentials over HTTP; ingen trust-bypass eller automatisk Basic/Digest/mTLS-fallback.
- Samme-origin GET/HEAD-redirect innen fem hopp; cross-origin/portbytte/downgrade/mutasjon/løkker følger ikke automatisk.
- Injisert session: profiler, delegatekompatibilitet, avvisning av bakgrunn/ustøttede kombinasjoner og ingen invalidation av andres session/tasks.
- Redaction av tokens/cookies/URL/body/error descriptions i alle feil- og diagnosestier; ingen skjult telemetri, error-body-capture eller replay på 401/503.
- Systempolicy for connectivity/kostnad og samme 30/60-budsjett gjennom tillatte hooks/redirects.

Kravene brytes ned til sporbare deloppgaver før Ready, og utføres etter implementasjonsklarsignal. DEC-07 avgjør faktiske tester/runtimes. Ingen av disse sikkerhetsegenskapene er implementert eller funksjonstestet nå.
