# Local Homebrew tap

This repository is the source for the canonical `MikcleGrok/tools` tap. Each formula has one lifecycle:
the default source is an immutable GitHub Release asset and local/offline tests
may override only the artifact path and its SHA-256 with the formula-specific
`HOMEBREW_*_ARTIFACT` variables. Both paths run the same formula `install`,
`test`, and service lifecycle; neither path builds from source.

`uni-chat` and `secretd` declare Homebrew services. The service commands use
`opt_bin`, so `brew services restart` follows the current keg after upgrades.
`secretd` keeps registry and audit data outside the Homebrew prefix; migration
from the legacy `/usr/local` layout is explicit and must not read credentials or
rewrite registry/audit data automatically.

The tap does not uninstall, unlink, relink, clean up, or manually mutate links.
Homebrew owns transactions and service plists. A real formula smoke requires a
pre-created isolated Homebrew installation; never use `/opt/homebrew` for a
destructive smoke test and never mix it with `/usr/local`.

Run `./scripts/validate-local-delivery.sh` for the non-destructive handoff
check. It validates staged archives, signatures, formula references and prints
the exact release-asset and tap-publication placeholders. It never uploads,
publishes, installs, deletes or cleans up.
