# frozen_string_literal: true

class KairosOllama < Formula
  desc "Ollama configured for KAIROS MCP local embeddings"
  homepage "https://ollama.com"
  url "https://ollama.com"
  version "0.32.5"
  sha256 "1ee0a5d256d46de662cb77949d2acd25609b0140dbbf757bb914807d1f710cc8" # Checksum of ollama.com homepage
  license "MIT"

  depends_on "ollama"

  def install
    # Wrapper script with isolated configuration
    bin.write_exec_script <<~EOS
      #!/bin/bash
      export OLLAMA_HOST=127.0.0.1:11435
      export OLLAMA_MODELS=#{var/"kairos-ollama/models"}
      exec ollama "$@"
    EOS
  end

  service do
    run [opt_bin/"kairos-ollama", "serve"]
    keep_alive true
    environment_variables \
      OLLAMA_HOST:   "127.0.0.1:11435",
      OLLAMA_MODELS: (var/"kairos-ollama/models").to_s
    log_path var/"log/kairos-ollama/kairos-ollama.log"
    error_log_path var/"log/kairos-ollama/kairos-ollama.err.log"
  end

  def post_install
    (var/"kairos-ollama/models").mkpath
    (var/"log/kairos-ollama").mkpath

    # Pull nomic-embed-text model for local embeddings
    system "#{bin}/kairos-ollama", "pull", "nomic-embed-text"
  end

  def caveats
    <<~EOS
      KAIROS Ollama runs on port 11435 (non-default) to avoid conflicts.

      This provides local embeddings for KAIROS MCP, removing OpenAI dependency.

      Usage:
        kairos-ollama pull <model>    # Pull a model
        kairos-ollama list            # List models
        kairos-ollama run <model>     # Run a model

      Service runs on: http://127.0.0.1:11435

      For KAIROS MCP, configure:
        EMBEDDING_PROVIDER=ollama
        OLLAMA_URL=http://127.0.0.1:11435
        OLLAMA_EMBEDDING_MODEL=nomic-embed-text
    EOS
  end

  test do
    system "#{bin}/kairos-ollama", "--version"
  end
end
