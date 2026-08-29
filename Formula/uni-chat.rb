class UniChat < Formula
  desc "Personal chat notifier, TUI and poster"
  homepage "https://github.com/MikcleGrok/uni-chat"
  version "1.4.53"
  release_asset = "uni-chat-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/tools/releases/download/uni-chat-v1.4.53/uni-chat-1.4.53-darwin-arm64.tar.gz"
    sha256 "9c906e27d354c6fec3cec9829777d99e1daf747c73e1537fc75b26dc17048b67"
  end
  depends_on :macos
  depends_on "terminal-notifier"

  def install
    bin.install "uni-chat", "uni-chatd", "uni-chat-tui", "uni-chat-auth"
  end

  service do
    run [opt_bin/"uni-chatd", "serve"]
    keep_alive true
    log_path "#{Dir.home}/.uni-chat/uni-chatd.log"
    error_log_path "#{Dir.home}/.uni-chat/uni-chatd.log"
  end

  test do
    assert_equal "uni-chat #{version}\n", shell_output("#{bin}/uni-chat --version")
    assert_match "usage: uni-chat", shell_output("#{bin}/uni-chat --help")
    assert_match "usage: uni-chatd", shell_output("#{bin}/uni-chatd --help")
    %w[uni-chat uni-chatd uni-chat-tui uni-chat-auth].each do |binary|
      assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/#{binary} 2>&1")
      system "codesign", "--verify", "--strict", bin/binary
    end
  end
end
