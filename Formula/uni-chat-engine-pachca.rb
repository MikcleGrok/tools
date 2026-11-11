class UniChatEnginePachca < Formula
  desc "Pachca engine adapter for uni-chat"
  homepage "https://github.com/MikcleGrok/uni-chat-pachca"
  version "1.1.36"
  release_asset = "uni-chat-engine-pachca-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_CHAT_PACHCA_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_CHAT_PACHCA_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/tools/releases/download/v1.1.36/uni-chat-engine-pachca-1.1.36-darwin-arm64.tar.gz"
    sha256 "a65a079e7a3a650d934e74b83215e9d56299352cac774bf34a4c9bf4b9e6da37"
  end
  depends_on :macos

  def install
    bin.install "uni-chat-engine-pachca"
  end

  test do
    assert_equal "uni-chat-engine-pachca #{version}\n", shell_output("#{bin}/uni-chat-engine-pachca --version")
    assert_match "usage: uni-chat-engine-pachca", shell_output("#{bin}/uni-chat-engine-pachca --help")
    assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/uni-chat-engine-pachca 2>&1")
    assert_match(/certificate leaf = H"a0271bd7a6960838e3e290a983bc3de425275fe1"/, shell_output("codesign -d -r- #{bin}/uni-chat-engine-pachca 2>&1"))
    system "codesign", "--verify", "--strict", bin/"uni-chat-engine-pachca"
  end
end
