# AGENTS.md

Guidance for AI agents working on this repository.

## Repository purpose

Homebrew tap for distributing formulae. Currently provides:

- **qdrant** — Vector similarity search engine and vector database

## Formula conventions

- Formulae live in `Formula/` directory
- Each formula downloads pre-built binaries from upstream GitHub releases
- No compilation from source — binaries are built by upstream projects
- SHA256 checksums are required for all downloads

## Updating a formula

To update a formula to a new upstream version:

1. Update the `version` field
2. Update the `sha256` values for each architecture
3. Run `brew style Formula/<name>.rb` to validate
4. Run `brew install --build-from-source Formula/<name>.rb` to test locally

## CI pipeline

GitHub Actions validates:
- `brew style` — Ruby style linting
- `brew audit` — Formula correctness checks
- `brew install` + `brew test` — Installation and smoke test

## License compliance

All formulae in this tap distribute binaries under their upstream licenses.
Check each formula's `license` field and verify compliance with upstream terms.

## Testing locally

```bash
# Style check
brew style Formula/

# Install from local formula
brew install --build-from-source Formula/qdrant.rb

# Run tests
brew test jakub-plichcinski/tap/qdrant
```
