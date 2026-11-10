class UniChatEngineMattermost < Formula
  desc "Mattermost engine adapter for uni-chat"
  homepage "https://github.com/MikcleGrok/uni-chat-mattermost"
  version "0.1.37"
  release_asset = "uni-chat-engine-mattermost-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_MATTERMOST_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_MATTERMOST_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/tools/releases/download/uni-chat-engine-mattermost-v0.1.37/uni-chat-engine-mattermost-0.1.37-darwin-arm64.tar.gz"
    sha256 "c29d89b6cadcb8d88bacc0bf1c95b1dc13795a258bb0ad303da4c3e878e408d4"
  end
  depends_on :macos

  def install
    bin.install "uni-chat-engine-mattermost"
  end

  test do
    assert_equal "uni-chat-engine-mattermost #{version}\n", shell_output("#{bin}/uni-chat-engine-mattermost --version")
    assert_match "usage: uni-chat-engine-mattermost", shell_output("#{bin}/uni-chat-engine-mattermost --help")
    assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/uni-chat-engine-mattermost 2>&1")
    system "codesign", "--verify", "--strict", bin/"uni-chat-engine-mattermost"
    leaf = "a0271bd7a6960838e3e290a983bc3de425275fe1"
    system "codesign", "--verify", "--strict", "-R", "=identifier \"uni-chat-engine-mattermost\" and certificate leaf = H\"#{leaf}\"", bin/"uni-chat-engine-mattermost"
  end
end
