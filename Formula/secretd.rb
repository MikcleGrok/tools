class Secretd < Formula
  desc "macOS secret broker daemon and control CLI"
  homepage "https://github.com/MikcleGrok/secretd"
  version "1.0.19"
  release_asset = "secretd-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_SECRETD_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_SECRETD_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/secretd/releases/download/v#{version}/#{release_asset}"
    sha256 "5e84b6ebc2304082762930b1e6a47d21c818c94be1eb4f45545d9f440a4083cf"
  end
  license "MIT"
  depends_on :macos

  def install
    bin.install "secretd", "secretctl"
    libexec.install "secretd-writer"
  end

  service do
    run [opt_bin/"secretd", "serve"]
    keep_alive true
    log_path "#{Dir.home}/Library/Logs/secretd.log"
    error_log_path "#{Dir.home}/Library/Logs/secretd.log"
  end

  test do
    assert_equal "#{version}\n", shell_output("#{bin}/secretd version")
    %w[secretd secretctl].each do |binary|
      assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/#{binary} 2>&1")
      system "codesign", "--verify", "--strict", bin/binary
    end
    assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{libexec}/secretd-writer 2>&1")
    system "codesign", "--verify", "--strict", libexec/"secretd-writer"
    assert_match /^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/secretd 2>&1")
  end
end
