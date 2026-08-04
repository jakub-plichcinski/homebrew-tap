class Qdrant < Formula
  desc "Vector similarity search engine and vector database"
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
    bin.install "qdrant"
  end

  service do
    run [opt_bin/"qdrant"]
    keep_alive true
    working_dir var/"qdrant"
    log_path var/"log/qdrant/qdrant.log"
    error_log_path var/"log/qdrant/qdrant.err.log"
  end

  def caveats
    <<~EOS
      Qdrant data is stored in:
        #{var}/qdrant

      Logs are in:
        #{var}/log/qdrant

      Default ports:
        6333 - HTTP REST API
        6334 - gRPC API

      To start qdrant as a service:
        brew services start jakub-plichcinski/tap/qdrant

      To stop:
        brew services stop jakub-plichcinski/tap/qdrant

      Or run manually:
        qdrant
    EOS
  end

  test do
    system "#{bin}/qdrant", "--version"
  end
end
