class UniDb < Formula
  desc "Read-only SQL CLI for production databases with macOS Keychain credentials"
  homepage "https://github.com/MikcleGrok/uni-db"
  version "1.5.3"
  release_asset = "uni-db-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_DB_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_DB_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/uni-db/releases/download/v#{version}/#{release_asset}"
    sha256 "873c06f268796a0cd210d05c761556eca93d1d95a0d3c435fd147f92d49da204"
  end
  license "MIT"
  depends_on :macos

  def install
    bin.install "uni-db", "uni-db-setup"
    man1.install "man/uni-db.1", "man/uni-db-setup.1"
    bash_completion.install "completions/uni-db.bash" => "uni-db"
    bash_completion.install "completions/uni-db-setup.bash" => "uni-db-setup"
    zsh_completion.install "completions/_uni-db"
    zsh_completion.install "completions/_uni-db-setup"
  end

  test do
    assert_equal "uni-db #{version}\n", shell_output("#{bin}/uni-db --version")
    assert_equal "uni-db-setup #{version}\n", shell_output("#{bin}/uni-db-setup --version")
    assert_path_exists man1/"uni-db.1"
    assert_path_exists man1/"uni-db-setup.1"
    assert_path_exists bash_completion/"uni-db"
    assert_path_exists bash_completion/"uni-db-setup"
    assert_path_exists zsh_completion/"_uni-db"
    assert_path_exists zsh_completion/"_uni-db-setup"
    # The Homebrew install path is a distribution surface the Makefile's own
    # codesign gates (sign-local, verify-artifact) never cover — verify it
    # here instead, matching the identity/anti-adhoc check those gates use
    # (Makefile:130-139).
    %w[uni-db uni-db-setup].each do |binary|
      assert_match(/^Authority=uni-release-selfsign$/, shell_output("codesign -dv --verbose=4 #{bin}/#{binary} 2>&1"))
      system "codesign", "--verify", "--strict", bin/binary
    end
  end
end
