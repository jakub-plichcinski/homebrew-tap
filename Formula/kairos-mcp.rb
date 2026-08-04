class KairosMcp < Formula
  desc "MCP server for agent automation and persistent memory"
  homepage "https://github.com/jakub-plichcinski/kairos-mcp"
  url "https://registry.npmjs.org/@jakub-plichcinski/kairos-mcp/-/kairos-mcp-4.8.3.tgz"
  version "4.8.3"
  sha256 "c8d3eae160a892e32837db3dcae515e843e5383fef52b8141940c8bcf8b6d59f"
  license "MIT"

  depends_on "jakub-plichcinski/tap/kairos-qdrant"
  depends_on "jakub-plichcinski/tap/kairos-ollama"
  depends_on "node" => ">=24"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir[libexec/"bin/{kairos,kairos-mcp}"]
  end

  service do
    run [opt_bin/"kairos", "serve", "--transport", "http", "--env-file", etc/"kairos-mcp/.env"]
    keep_alive true
    working_dir var/"kairos-mcp"
    log_path var/"log/kairos-mcp/kairos-mcp.log"
    error_log_path var/"log/kairos-mcp/kairos-mcp.err.log"
    environment_variables \
      QDRANT_URL:  "http://127.0.0.1:6335",
      OLLAMA_URL:  "http://127.0.0.1:11435",
      SERVER_PORT: "3000"
  end

  def post_install
    (var/"kairos-mcp").mkpath
    (var/"log/kairos-mcp").mkpath

    # Create default config if not present
    unless (etc/"kairos-mcp/.env").exist?
      (etc/"kairos-mcp/.env").write <<~EOS
        # KAIROS MCP Configuration
        # See: https://github.com/jakub-plichcinski/kairos-mcp

        # Server
        SERVER_PORT=3000
        TRANSPORT_TYPE=http

        # Qdrant (vector database)
        QDRANT_URL=http://127.0.0.1:6335
        QDRANT_COLLECTION=kairos

        # Ollama (local embeddings - no OpenAI needed)
        EMBEDDING_PROVIDER=ollama
        OLLAMA_URL=http://127.0.0.1:11435
        OLLAMA_EMBEDDING_MODEL=nomic-embed-text
        EMBEDDING_DIMENSION=768

        # OpenAI (optional, if not using local embeddings)
        # EMBEDDING_PROVIDER=openai
        # OPENAI_API_KEY=your-key-here
        # OPENAI_EMBEDDING_MODEL=text-embedding-3-small
        # EMBEDDING_DIMENSION=1536

        # Auth (optional, disabled by default)
        AUTH_ENABLED=false
      EOS
    end
  end

  def caveats
    <<~EOS
      KAIROS MCP requires configuration before first use.

      Edit the config file:
        #{etc}/kairos-mcp/.env

      Required settings:
        - QDRANT_URL (default: http://127.0.0.1:6335)
        - OLLAMA_URL (default: http://127.0.0.1:11435)

      Start dependencies:
        brew services start jakub-plichcinski/tap/kairos-qdrant
        brew services start jakub-plichcinski/tap/kairos-ollama

      Start KAIROS MCP:
        brew services start jakub-plichcinski/tap/kairos-mcp

      Or run manually:
        kairos serve --transport http --env-file #{etc}/kairos-mcp/.env

      Default ports:
        3000 - HTTP API / MCP endpoint
        3302 - Metrics (Prometheus)
    EOS
  end

  test do
    system "#{bin}/kairos", "--version"
  end
end
