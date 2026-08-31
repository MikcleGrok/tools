class Secretd < Formula
  desc "macOS secret broker daemon and control CLI"
  homepage "https://github.com/MikcleGrok/secretd"
  url "https://github.com/MikcleGrok/secretd/releases/download/v1.0.28/secretd-1.0.28-darwin-arm64.tar.gz"
  sha256 "6dd1b1c4db79c7c58c6bf1983e122b5b4faac8bd3b98805f30d6f47e238b0dc1"
  license "MIT"

  depends_on :macos

  def install
    bin.install "secretd", "secretctl"
    libexec.install "secretd-writer"
  end

  # No SECRETD_CONFIG_ROOT here on purpose. The registry root is a fixed,
  # root-owned, $HOME-independent path compiled into the binaries
  # (paths.SystemRoot). Injecting it through the service block would put the
  # root in a second place that can disagree with the binaries — and, because
  # the plist is regenerated from this formula on every `brew services`
  # command, a stale value here would silently point the daemon at a
  # user-owned registry, which is exactly the privilege bypass the root-owned
  # root exists to prevent. The daemon still runs as the user, never as root;
  # only writes go through the sudo-gated libexec/secretd-writer.
  service do
    run [opt_bin/"secretd", "serve"]
    keep_alive true
    log_path "#{Dir.home}/Library/Logs/secretd.log"
    error_log_path "#{Dir.home}/Library/Logs/secretd.log"
  end

  test do
    %w[secretd secretctl].each do |binary|
      assert_predicate bin/binary, :executable?
      assert_match version.to_s, shell_output("#{bin}/#{binary} version") if binary == "secretd"
      assert_match "Usage: secretctl", shell_output("#{bin}/#{binary} --help 2>&1") if binary == "secretctl"
    end
    assert_match "secretd:", shell_output("#{bin}/secretd --help 2>&1")
    assert_predicate libexec/"secretd-writer", :executable?
    assert_match "secretd-writer", shell_output("#{libexec}/secretd-writer --help 2>&1", 2)
    # The Homebrew install path is a distribution surface the Makefile's own
    # codesign gates (verify-signatures, package, install) never cover —
    # verify it here instead, matching the identity/anti-adhoc check those
    # gates use (Makefile:136).
    %w[secretd secretctl].each do |binary|
      assert_match(/^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/#{binary} 2>&1"))
      system "codesign", "--verify", "--strict", bin/binary
    end
    assert_match(/^Authority=uni-release-selfsign$/,
                 shell_output("codesign -dv --verbose=4 #{libexec}/secretd-writer 2>&1"))
    system "codesign", "--verify", "--strict", libexec/"secretd-writer"
  end
end
