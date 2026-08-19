class UniChatEngineMattermost < Formula
  desc "Mattermost engine adapter for uni-chat"
  homepage "https://github.com/MikcleGrok/uni-chat-mattermost"
  version "0.1.24"
  release_asset = "uni-chat-engine-mattermost-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_MATTERMOST_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_MATTERMOST_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/uni-chat-mattermost/releases/download/v#{version}/#{release_asset}"
    sha256 "8805c0dcfcefdbed865b926beacc927ea787c3cc5b741dcc1de6f1a2f42a790e"
  end
  depends_on :macos

  def install
    bin.install "uni-chat-engine-mattermost"
  end

  test do
    assert_equal "uni-chat-engine-mattermost #{version}\n", shell_output("#{bin}/uni-chat-engine-mattermost --version")
    assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/uni-chat-engine-mattermost 2>&1")
    system "codesign", "--verify", "--strict", bin/"uni-chat-engine-mattermost"
  end
end
