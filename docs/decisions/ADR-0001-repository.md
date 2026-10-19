# ADR-0001: Repository og planleggingsfase

Dato: 2026-10-19. Status: Godkjent for repooppsett.

## Kontekst

Brukeren ønsker komplett GitHub-oppsett for PDF-spesifikasjonen, uten kode, og har valgt offentlig repo under BK-Teisrud med navnet SwiftNetworkKit.

## Beslutning

Ett repo, main som default, kortlivede branches og squash-merge. Issues og milepæler er autoritativ backlog, supplert med GitHub Projects når autorisasjonen er på plass. Dokumentasjon er på norsk; symboler og etablerte tekniske navn beholdes. Ingen produktkode eller workflows aktiveres nå. Lisens og plattformversjoner er åpne.

Solo-profil krever PR og løste review-tråder, men null obligatoriske approvals. Admin-bypass begrenses til PR. Tag-regler beskytter v*-navnerommet; admin får opprette releasetagger. Reviewkrav skjerpes når en reell medreviewer finnes.

## Konsekvenser

Oppsettet kan brukes av én maintainer uten review-deadlock. Fremtidig CI må etableres og ha kjørt før status checks blir obligatoriske. Offentlig repo uten valgt lisens er synlig, men ikke presentert som fritt lisensiert. Produkt- og lisensbeslutninger krever egne ADR-er.

## Senere herding

ADR-0010 erstatter den opprinnelige admin-bypass- og tagmodellen. Gjeldende main har ingen bypass; tag-oppretting og uforanderlighet håndheves separat.
