class KairosMcp < Formula
  desc "MCP server for agent automation and persistent memory"
  homepage "https://github.com/debian777/kairos-mcp"
  url "https://registry.npmjs.org/@debian777/kairos-mcp/-/kairos-mcp-4.8.1.tgz"
  version "4.8.1"
  sha256 "0c847822b742843e5c4636dd518f9f4d5b1e5ee404e194cd9da8e0018c6968a9"
  license "MIT"

  depends_on "jakub-plichcinski/tap/qdrant"
  depends_on "node" => ">=24"
  depends_on "redis"

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
      QDRANT_URL:  "http://127.0.0.1:6333",
      REDIS_URL:   "redis://localhost:6379",
      SERVER_PORT: "3300"
  end

  def post_install
    (var/"kairos-mcp").mkpath
    (var/"log/kairos-mcp").mkpath

    # Create default config if not present
    unless (etc/"kairos-mcp/.env").exist?
      (etc/"kairos-mcp/.env").write <<~EOS
        # KAIROS MCP Configuration
        # See: https://github.com/debian777/kairos-mcp

        # Server
        SERVER_PORT=3300
        TRANSPORT_TYPE=http

        # Qdrant (vector database)
        QDRANT_URL=http://127.0.0.1:6333
        QDRANT_COLLECTION=kairos

        # Redis
        REDIS_URL=redis://localhost:6379

        # Embedding (choose one: openai, local)
        EMBEDDING_PROVIDER=openai
        # OPENAI_API_KEY=your-key-here
        OPENAI_EMBEDDING_MODEL=text-embedding-3-small
        EMBEDDING_DIMENSION=1536

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
        - OPENAI_API_KEY (if using OpenAI embeddings)
        - QDRANT_URL (default: http://127.0.0.1:6333)
        - REDIS_URL (default: redis://localhost:6379)

      Start dependencies:
        brew services start jakub-plichcinski/tap/qdrant
        brew services start redis

      Start KAIROS MCP:
        brew services start jakub-plichcinski/tap/kairos-mcp

      Or run manually:
        kairos serve --transport http --env-file #{etc}/kairos-mcp/.env

      Default ports:
        3300 - HTTP API / MCP endpoint
        3302 - Metrics (Prometheus)
    EOS
  end

  test do
    system "#{bin}/kairos", "--version"
  end
end
