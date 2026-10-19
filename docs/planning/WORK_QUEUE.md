# Arbeidsrekkefølge før og etter kodestart

**Nå: vent på uttrykkelig kodegodkjenning i [START-00 / #41](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/41).** Alle I-oppgaver er Blocked. Ingen skal starte bare fordi planen er godkjent.

Etter et senere klarsignal velges laveste Order med avsluttede blokkere og oppfylte Ready-kriterier. Anbefalt rekkefølge er seriell for én utvikler; den er ingen tidsplan. Endringer i rekkefølge krever kontroll av avhengigheter, ikke nytt produktscope. Se [prosjektets Arbeidskø](https://github.com/users/BK-Teisrud/projects/6/views/7).

| Order | Oppgave | Foreldreepic | Avhengigheter i tillegg til #41 |
| --- | --- | --- | --- |
| 1 | [[I01] Opprett Swift-pakke og testtarget etter startgodkjenning](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/42) | #27 | Ingen |
| 2 | [[I02] Definer immutable HTTP-verdier, respons og feiltaksonomi](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/43) | #11 | #42 |
| 3 | [[I03] Implementer konfigurasjonssnapshots og interne testgrenser](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/44) | #22 | #43 |
| 4 | [[I04] Implementer sikker endpoint- og URL-bygging](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/45) | #9 | #44 |
| 5 | [[I05] Implementer headers og request-koding](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/46) | #8 | #45 |
| 6 | [[I06] Aktiver reell PR-CI for alle fire plattformfamilier](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/47) | #23 | #46 |
| 7 | [[I07] Implementer responsstrategier og HTTP-statuskontroll](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/48) | #10 | #47 |
| 8 | [[I08] Implementer URLSession-eierskap og transportadapter](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/49) | #21 | #48 |
| 9 | [[I09] Implementer HTTPS-, loopback- og redirect-policy](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/50) | #25 | #49 |
| 10 | [[I10] Koble typesikre og rå kall til én sikker HTTP-pipeline](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/51) | #8 | #50 |
| 11 | [[I11] Verifiser første HTTP-kjerne og F1-port](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/52) | #23 | #51 |
| 12 | [[I12] Implementer kansellering og samlet tidsbudsjett](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/53) | #21 | #52 |
| 13 | [[I13] Implementer shutdown og samtidighetsisolasjon](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/54) | #21 | #53 |
| 14 | [[I14] Implementer avgrenset auth-header-provider](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/55) | #25 | #54 |
| 15 | [[I15] Implementer sanitert og valgfri diagnostikk](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/56) | #20 | #55 |
| 16 | [[I16] Verifiser sikker lagring og injisert session-profil](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/57) | #25 | #56 |
| 17 | [[I17] Fullfør testmatrise og regresjonssuite](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/58) | #23 | #57 |
| 18 | [[I18] Fullfør API-review, DocC og integrasjonsveiledning](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/59) | #27 | #58 |
| 19 | [[I19] Utfør sikkerhets- og personvernreview før v1](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/60) | #25 | #59 |
| 20 | [[I20] Mål grunnleggende ressursbruk og pakkekvalitet](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/61) | #27 | #60 |
| 21 | [[I21] Skaff og dokumenter minimums-OS-runtimebevis](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/62) | #23 | #61 |
| 22 | [[I22] Utfør representative tester på fysiske Apple-enheter](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/63) | #23 | #62 |
| 23 | [[I23] Gjennomfør v1-releaseprøve uten publisering](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/64) | #27 | #63 |
| 24 | [REL-01: Faktisk v1-releaseport](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/29) | Styring | #64 og valgte kjerneepics |

## Hvorfor denne rekkefølgen

Verdier og konfigurasjon kommer før URL/request-koding. Reell CI kommer tidlig når det finnes meningsfulle tester, og før transportkjernen bygges videre. Respons/transport/nettverkspolicy bindes sammen til ett vertikalt HTTP-snitt før F1-kontroll. Deretter verifiseres tidsbudsjett, livssyklus, auth og personvern samlet. API/DocC og sikkerhetsreview følges av ressursmålinger og faktiske runtime-/enhetsbevis. Releaseprøven publiserer ingenting.

Hver issue inneholder akseptansekriterier og testkrav. Tester og nødvendig dokumentasjon følger samme implementasjons-PR; de utsettes ikke til I17/I18. De siste oppgavene er helhetskontroller. Native blocked-by og sub-issues er opprettet; de håndhever ikke alene en merge-sperre.

I21 kan undersøke tilgjengelighet av eldre testmiljøer som forberedelse uten kode, men faktiske produkttester krever implementasjon. Tilgangsgapet blokkerer release. Dersom testtilgang ikke kan skaffes, må støttevedtaket revurderes uttrykkelig; ingen automatisk nedgradering eller kjøp.

F3–F6 er utsatt. Slike epics har ingen Order og kan ikke trekkes inn uten nytt scopevedtak. Foreldreepics kan omfatte flere faser; konkrete underoppgavers milepæler angir leveransekravene.
