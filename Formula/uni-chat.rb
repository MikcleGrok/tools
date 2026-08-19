class UniChat < Formula
  desc "Personal chat notifier, TUI and poster"
  homepage "https://github.com/MikcleGrok/uni-chat"
  version "1.4.15"
  release_asset = "uni-chat-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/uni-chat/releases/download/v#{version}/#{release_asset}"
    sha256 "a8d8e5807afcbd9037c8c0a3c011ef96996caa2517b321996e5f804710f854e8"
  end
  depends_on :macos
  depends_on "terminal-notifier"

  def install
    bin.install "uni-chat", "uni-chatd", "uni-chat-tui", "uni-chat-auth"
  end

  test do
    assert_equal "uni-chat #{version}\n", shell_output("#{bin}/uni-chat --version")
    %w[uni-chat uni-chatd uni-chat-tui uni-chat-auth].each do |binary|
      assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/#{binary} 2>&1")
      system "codesign", "--verify", "--strict", bin/binary
    end
  end
end
