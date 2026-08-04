# frozen_string_literal: true

class KairosQdrant < Formula
  desc "Qdrant configured for KAIROS MCP vector storage"
  homepage "https://qdrant.tech"
  version "1.18.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/qdrant/qdrant/releases/download/v#{version}/qdrant-aarch64-apple-darwin.tar.gz"
      sha256 "0cb040a261035c316779bd7b4cca2e6ab39faf62640d6918bbbe320e2a9a6547"
    else
      url "https://github.com/qdrant/qdrant/releases/download/v#{version}/qdrant-x86_64-apple-darwin.tar.gz"
      sha256 "45bdd4642e7f25611e9cd74f9f91482b27c5376840cd8dc476da67b87abe25a6"
    end
  end

  def install
    libexec.install "qdrant"
    # Wrapper script with isolated configuration
    (bin/"kairos-qdrant").write <<~EOS
      #!/bin/bash
      export QDRANT__SERVICE__HTTP_PORT=6335
      export QDRANT__SERVICE__GRPC_PORT=6336
      export QDRANT__STORAGE__STORAGE_PATH=#{var/"kairos-qdrant/storage"}
      export QDRANT__STORAGE__SNAPSHOTS_PATH=#{var/"kairos-qdrant/snapshots"}
      exec "#{libexec}/qdrant" "$@"
    EOS
    chmod 0755, bin/"kairos-qdrant"
  end

  service do
    run [opt_bin/"kairos-qdrant"]
    keep_alive true
    working_dir var/"kairos-qdrant"
    environment_variables \
      QDRANT__SERVICE__HTTP_PORT:      "6335",
      QDRANT__SERVICE__GRPC_PORT:      "6336",
      QDRANT__STORAGE__STORAGE_PATH:   (var/"kairos-qdrant/storage").to_s,
      QDRANT__STORAGE__SNAPSHOTS_PATH: (var/"kairos-qdrant/snapshots").to_s
    log_path var/"log/kairos-qdrant/kairos-qdrant.log"
    error_log_path var/"log/kairos-qdrant/kairos-qdrant.err.log"
  end

  post_install_steps do
    mkdir_p "kairos-qdrant/storage"
    mkdir_p "kairos-qdrant/snapshots"
    mkdir_p "log/kairos-qdrant"
  end

  def caveats
    <<~EOS
      KAIROS Qdrant runs on non-default ports to avoid conflicts:
        6335 - HTTP REST API (default: 6333)
        6336 - gRPC API (default: 6334)

      Data is stored in:
        #{var}/kairos-qdrant

      Logs are in:
        #{var}/log/kairos-qdrant

      To start as a service:
        brew services start jakub-plichcinski/tap/kairos-qdrant

      To stop:
        brew services stop jakub-plichcinski/tap/kairos-qdrant

      Or run manually:
        kairos-qdrant
    EOS
  end

  test do
    system "#{bin}/kairos-qdrant", "--version"
  end
end
