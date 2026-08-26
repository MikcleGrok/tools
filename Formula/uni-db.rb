# MikcleGrok/uni-db is a private repository, and Homebrew's built-in
# CurlDownloadStrategy has no support for private GitHub Release assets
# (GitHubPrivateRepositoryReleaseDownloadStrategy was removed from Homebrew
# core) -- a plain `url` line 404s even with HOMEBREW_GITHUB_API_TOKEN set,
# since that env var alone doesn't change which strategy Homebrew picks.
# This strategy resolves the asset through the GitHub REST API (which
# redirects to a short-lived signed URL) using a token, falling back to
# `gh auth token` when HOMEBREW_GITHUB_API_TOKEN isn't exported -- `gh` is
# already a hard requirement of this tap's own publish script.
class GitHubPrivateReleaseDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    match = url.match(%r{\Ahttps://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(.+)\z})
    raise "unsupported private-release url: #{url}" unless match

    _, @owner, @repo, @release_tag, @asset_name = *match
  end

  def token
    return @token if defined?(@token)

    @token = ENV["HOMEBREW_GITHUB_API_TOKEN"].presence
    @token ||= Utils.safe_popen_read("gh", "auth", "token").strip.presence
    @token || raise("Set HOMEBREW_GITHUB_API_TOKEN, or `gh auth login`, to install this private-repo formula")
  end

  def _fetch(url:, resolved_url:, timeout:)
    api_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@release_tag}"
    release_json = curl_output("--fail", "--header", "Authorization: Bearer #{token}", "--header",
                                "Accept: application/vnd.github+json", api_url).stdout
    asset = JSON.parse(release_json)["assets"].find { |a| a["name"] == @asset_name }
    raise "asset #{@asset_name} not found in release #{@release_tag}" unless asset

    curl_download asset["url"], "--header", "Authorization: Bearer #{token}", "--header",
                   "Accept: application/octet-stream", to: temporary_path
  end
end

class UniDb < Formula
  desc "Read-only SQL CLI for production databases with macOS Keychain credentials"
  homepage "https://github.com/MikcleGrok/uni-db"
  version "1.5.5"
  release_asset = "uni-db-#{version}-darwin-arm64.tar.gz"
  artifact = ENV["HOMEBREW_UNI_DB_ARTIFACT"]
  if artifact
    url "file://#{artifact}"
    sha256 ENV.fetch("HOMEBREW_UNI_DB_ARTIFACT_SHA256")
  else
    url "https://github.com/MikcleGrok/uni-db/releases/download/v#{version}/#{release_asset}",
        using: GitHubPrivateReleaseDownloadStrategy
    sha256 "6712693976b68864fb1279d38a46d32cc85b13c4f1b407c023591b618f6172cf"
  end
  license "MIT"
  depends_on :macos

  def install
    bin.install "uni-db", "uni-db-setup", "uni-db-touchid-auth"
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
    # Not invoked here (it would trigger an interactive Touch ID/password
    # prompt) -- uni-db's own touchid package fails closed on a missing
    # helper, so presence + executability next to uni-db is what matters.
    assert_predicate bin/"uni-db-touchid-auth", :executable?
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
