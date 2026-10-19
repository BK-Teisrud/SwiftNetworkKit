# Klarhetskontroll før kodestart

Dato: 2026-10-19. **Forberedelser er godkjent utført; implementasjon er fortsatt ikke autorisert.** F0-godkjenningen i ADR-0009 gjelder planlegging. Startporten [#41](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/41) forblir åpen til eier gir et eget uttrykkelig klarsignal.

## Hva er klart

- Rettighetshaver Teisrud Development AS, proprietær policy, HTTP-kjerne og navn/modul er avklart.
- OS 17/14/10/17, Xcode 26.3+, tools 6.2 og Swift 6 er vedtatt.
- HTTP-, livssyklus-, sikkerhets- og CI-kontrakter er versjonert; utsatt scope er tydelig.
- Arbeidet er brutt ned i I01–I23 med akseptansekriterier, testkrav, foreldreepics og native blocked-by-lenker. [Arbeidskøen](WORK_QUEUE.md) fastsetter anbefalt seriell rekkefølge.
- Main krever PR uten bypass. Nye v*-tagger kan bare opprettes av admin gjennom avgrenset opprettingsunntak; endring/sletting har ingen bypass. Immutable releases er på. Web sign-off er av etter konkret eiergodkjenning, fordi prosjektet ikke bruker DCO.
- Prosjektet har én statusmodell, sortert arbeidskø, ferdigvisning og kontrollert import/statusflyt.
- Ingen produktkode, manifest, testkode, prototypes, workflows, releasetagger eller releases er opprettet.

## Avklaringer som ikke skal skjules

| Punkt | Faktisk status | Når må det løses? |
| --- | --- | --- |
| Kodestart | Ikke godkjent; #41 åpen | Før I01 eller annet kode-/workflowarbeid |
| Minimums-OS-testmiljø | Ikke tilgjengelighetsbekreftet; nyere runtimes er inventarført | Før release; I21 krever reelle bevis eller eksplisitt endring av støttevedtak |
| Fysiske enheter | Eier oppgir alle typer med nyeste oppdateringer; eksakte versjoner ikke kontrollert | I22 før test/release |
| Kontaktadresse | Eier: «ingen adresse ennå»; ingen adresse publiseres | Før private lisenshenvendelser/eksterne bidragsavtaler tilbys |
| Kontosikkerhet | Eier bekrefter 2FA aktivert; ingen koder/nøkler innhentet | Vedlikehold; uavhengig kontoaudit er ikke utført |
| Ekte CI | Planlagt; ingen workflows/checks finnes | I06 etter kodegodkjenning; krev checks først etter ekte verifisert kjøring |
| API-symboler | Avgrenset SDK-kontroll i PLATFORM_MATRIX; faktiske nye overloads kontrolleres per oppgave | Før relevant oppgave blir Ready |

Manglende kontaktadresse og eldre OS-enheter er ikke en skjult påstand om full releaseberedskap. Intern implementasjon kan godkjennes separat uten kjøp eller oppgraderinger. Release forblir blokkert til faktisk testbevis foreligger. Hvis minimumsmiljø ikke kan skaffes, må eier endre støttekravet uttrykkelig; en nyere simulator erstatter ikke kravet.

## Etter et senere klarsignal

Registrer eierens konkrete utsagn/dato/scope på #41, lukk porten og triager I01 til Ready. Velg deretter laveste Order med lukkede avhengigheter og oppfylte Ready-kriterier. Gjennomfør én oppgave om gangen med PR, tester og dokumentasjon. En ferdig plan eller høy prioritet lukker aldri startporten automatisk. Nytt releaseklarsignal kreves før tag/publisering.

F0-milepælen kan avsluttes når OPS-01 og oppsettsverifikasjonen er fullført; #41 ligger i F1 og bevarer skillet mellom fullført forberedelse og autorisert utvikling.
