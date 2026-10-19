# ADR-0006: Session-eierskap, concurrency og tidsgrenser

Dato: 2026-10-19. Status: Hovedvalg godkjent av prosjekteier; livssyklus- og concurrencydetaljer dokumentert som konkretisering.
Oppgave: [DEC-05 / #5](https://github.com/BK-Teisrud/SwiftNetworkKit/issues/5).

## Prosjekteierens valg

- Egen, gjenbrukt URLSession som standard, med støtte for injisert session. En app-eid injisert session ugyldiggjøres aldri av klienten.
- Standard timeout etter 30 sekunder uten nye data og et samlet tidsbudsjett på 60 sekunder. Begge kan endres per klient eller kall.

[CONCURRENCY_AND_LIFECYCLE.md](../planning/CONCURRENCY_AND_LIFECYCLE.md) konkretiserer disse valgene og kravene fra ADR-0003/0005 om trygg samtidig bruk og separat CancellationError. Ingen implementasjon eller eksakte Swift-signaturer opprettes nå.

## Beslutning

Klienten kan brukes av flere samtidige tasks. Konfigurasjon/requestinput er snapshots; delt muterbar tilstand isoleres. Ingen klientglobal actor får utilsiktet serialisere hele HTTP-/decodeoperasjonen. Typede verdier og klientgrenser skal tilfredsstille Swift 6-kontraktene uten generelle unchecked Sendable-unntak.

Klienten eier enten sin egen session eller låner en app-eid session; eierskap er eksplisitt og endres ikke under bruk. Shutdown stenger for nye kall og kansellerer klientens aktive operasjoner, med opprydding. Bare egen session kan ugyldiggjøres. Det inngår ingen separat graceful-drain-modus i v1; en app kan selv vente på sine kall før shutdown.

Produksjonsklokken er monoton, med ContinuousClock som planlagt systemgrunnlag og en injiserbar intern clock/sleeper-grense for deterministiske tester. Et separat eksternt clock-bibliotek er ikke tillatt. Timeout, brukeravbrudd, shutdown og normal fullføring har eksplisitte terminalårsaker, slik at intern timeoutkansellering ikke feilaktig vises som brukerens CancellationError.

## Begrunnelse og alternativer

Kun egen session ville gitt mindre integrasjonsfleksibilitet. Prosjekteier valgte injeksjon i tillegg, og dermed også en tydelig grense for hva klienten kan styre på en lånt session.

Lengre standardgrenser (60/300 sekunder) eller ingen samlet biblioteksfrist ble presentert som alternativer. Prosjekteier valgte 30/60 sekunder. Dette er HTTP-kjernens standardpolicy, ikke et signal om støtte for langvarige overføringer.

En global singleton, session per request, global requestlås eller bruk av veggklokke til deadlines ville svekket eierskap, ressursbruk, parallellitet eller testbarhet. De inngår ikke i kontrakten. Actor-isolering brukes på tilstanden som trenger det, ikke som et løfte om én bestemt offentlig implementasjonstype.

## Viktige begrensninger

Request-timeout er URLSessions inaktivitets-/vent-på-data-semantikk, ikke total operasjonstid. Klientens samlede budsjett inkluderer også forberedelse, eventuelle hooks og responsbehandling. OS-planlegging og kooperativ cancellation betyr at det ikke er en hard sanntidsgaranti for retur nøyaktig etter 60 sekunder. Et sent resultat skal ikke leveres som suksess når den valgte fristen allerede er registrert utløpt.

Appens injiserte session kan ha strengere resource-timeout eller eksterne invalidations som klienten ikke kan overstyre. Et kall kan ikke love å forlenge slike begrensninger. Raw URLRequest har samme eksplisitte tidsgrenser som typed endpoint. Sikkerhets-/auth-/redirect-/cachepolicy for eide og injiserte sessions fastsettes i DEC-06; inkonsekvent injeksjon skal avvises fremfor å gi et falskt sikkerhetsløfte.

## Kontroll og videre arbeid

Apples beskrivelser og lokal SDK er kontrollert for request-timeout, session-invalidation og ContinuousClock/CancellationError. Grunnsymbolenes deklarerte availability ligger innenfor vedtatte OS-minimum. Dette er kilde-/deklarasjonskontroll, ikke produktbygg eller runtime-test.

Testkrav for cancellation, eierskap, tidsfrister, races, shutdown og samtidige kall finnes i kontraktsdokumentet. Ingen slike tester er kjørt. DEC-06, DEC-07 og F0-porten gjenstår.

## Kilder

- [Apple: timeoutIntervalForRequest](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/timeoutintervalforrequest)
- [Apple: invalidateAndCancel](https://developer.apple.com/documentation/foundation/urlsession/invalidateandcancel%28%29)
- [Apple: Task.cancel](https://developer.apple.com/documentation/swift/task/cancel%28%29)
- [Apple: TaskGroup](https://developer.apple.com/documentation/swift/taskgroup)
- [Apple: ContinuousClock](https://developer.apple.com/documentation/swift/continuousclock)
- Lokal SDK 26.2: Foundation/Headers/NSURLSession.h og usr/lib/swift/_Concurrency.swiftmodule/x86_64-apple-macos.swiftinterface.
