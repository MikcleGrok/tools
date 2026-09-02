class UniChat < Formula
  desc "Personal chat notifier, TUI and poster"
  homepage "https://github.com/MikcleGrok/uni-chat"
  version "1.4.66"
  release_asset = "uni-chat-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/tools/releases/download/uni-chat-v1.4.66/uni-chat-1.4.66-darwin-arm64.tar.gz"
    sha256 "a2012d4a02f9fe903d2e177b583196baa3c0fc2fb3988e9cacba5f6ebe150d00"
  end
  depends_on :macos
  depends_on "terminal-notifier"

  def install
    bin.install "uni-chat", "uni-chatd", "uni-chat-tui", "uni-chat-auth"
    bin.install_symlink "uni-chat" => "uchat"
  end

  service do
    run [opt_bin/"uni-chatd", "serve"]
    keep_alive true
    log_path "#{Dir.home}/.uni-chat/uni-chatd.log"
    error_log_path "#{Dir.home}/.uni-chat/uni-chatd.log"
  end

  test do
    assert_equal "uni-chat #{version}\n", shell_output("#{bin}/uni-chat --version")
    assert_predicate bin/"uchat", :symlink?
    assert_equal "uni-chat", (bin/"uchat").readlink.to_s
    assert_match "usage: uni-chat", shell_output("#{bin}/uni-chat --help")
    assert_match "usage: uni-chatd", shell_output("#{bin}/uni-chatd --help")
    %w[uni-chat uni-chatd uni-chat-tui uni-chat-auth].each do |binary|
      assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/#{binary} 2>&1")
      system "codesign", "--verify", "--strict", bin/binary
    end
  end
end
