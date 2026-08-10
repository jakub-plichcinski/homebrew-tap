# AGENTS.md

Guidance for AI agents working on this repository.

## Repository purpose

Homebrew tap for distributing formulae. Currently provides:

- **kairos-qdrant** — Qdrant vector database configured for KAIROS (port 6335)
- **kairos-ollama** — Ollama configured for KAIROS local embeddings (port 11435)
- **kairos-mcp** — MCP server for agent automation and persistent memory

## Formula conventions

- Formulae live in `Formula/` directory
- Each formula downloads pre-built binaries or npm packages from upstream
- No compilation from source — binaries are built by upstream projects
- SHA256 checksums are required for all downloads

## Updating a formula

To update a formula to a new upstream version:

1. Update the `version` field
2. Update the `url` and `sha256` values
3. Run `brew style Formula/<name>.rb` to validate
4. Run `brew install --build-from-source Formula/<name>.rb` to test locally

### For kairos-mcp (npm package)

```bash
# Compute new SHA256
curl -sL https://registry.npmjs.org/@debian777/kairos-mcp/-/kairos-mcp-<VERSION>.tgz | shasum -a 256
```

## CI pipeline

GitHub Actions validates:
- `brew style` — Ruby style linting
- `brew audit` — Formula correctness checks
- `brew install` + `brew test` — Installation and smoke test

## License compliance

All formulae in this tap distribute binaries/packages under their upstream licenses:
- kairos-qdrant: Apache-2.0
- kairos-ollama: MIT
- kairos-mcp: MIT

Check each formula's `license` field and verify compliance with upstream terms.

## Testing locally

```bash
# Style check
brew style Formula/

# Install from local formula
brew install --build-from-source Formula/kairos-qdrant.rb
brew install --build-from-source Formula/kairos-ollama.rb
brew install --build-from-source Formula/kairos-mcp.rb

# Run tests
brew test jakub-plichcinski/tap/kairos-qdrant
brew test jakub-plichcinski/tap/kairos-ollama
brew test jakub-plichcinski/tap/kairos-mcp

# Start services
brew services start jakub-plichcinski/tap/kairos-qdrant
brew services start jakub-plichcinski/tap/kairos-ollama
brew services start jakub-plichcinski/tap/kairos-mcp
```

## Service dependencies

kairos-mcp depends on:
- kairos-qdrant (vector database) — port 6335
- kairos-ollama (local embeddings) — port 11435

Start dependencies before kairos-mcp service.
