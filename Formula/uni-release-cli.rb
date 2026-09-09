class UniReleaseCli < Formula
  APP_VERSION = "1.7.2"
  desc "CLI to manage the Release Manager (release.ecomz.net environment pool)"
  homepage "https://gitlab.ecomz.net/sboborykin/uni-release-cli"
  url "ssh://git@gitlab.ecomz.net/sboborykin/uni-release-cli.git", using: :git, tag: "v1.7.2", revision: "07c66e966c8f094551ded0ca2de111e541ed8f50"
  version APP_VERSION

  depends_on "go" => :build
  # Hard dependencies of the packaged self-check (the `selfcheck` subcommand),
  # which runs scripts/release-manager/release/release-full-cycle.sh:
  #   coreutils — macOS ships no `timeout` at all, and the script requires it
  #               (release-full-cycle.sh:1292), exiting 3 without it. The
  #               coreutils formula installs it unprefixed as `timeout`.
  #   jq        — required at release-full-cycle.sh:1294. Present in the system
  #               on macOS 15, absent on older releases; the same reason it was
  #               added to the test image's Dockerfile.
  # python3 is deliberately NOT declared: Homebrew already requires the Xcode
  # Command Line Tools, which provide /usr/bin/python3, and the script says so
  # plainly (:1293) if it is ever missing anyway.
  depends_on "coreutils"
  depends_on "jq"
  depends_on :macos

  def install
    # A HEAD build must remain distinguishable from the stable release, even
    # when Homebrew's formula version is the stable version.
    dirty = begin
      status = Utils.safe_popen_read("git", "-C", Dir.pwd, "status", "--porcelain",
                                     "--untracked-files=all", err: :close)
      !status.strip.empty?
    rescue ErrorDuringExecution
      false
    end
    build_version = if build.head?
      head_sha = begin
        Utils.safe_popen_read("git", "-C", Dir.pwd, "rev-parse", "--short", "HEAD", err: :close).strip
      rescue ErrorDuringExecution
        ""
      end
      if head_sha.empty?
        "dev"
      else
        head_version = "HEAD-#{head_sha}"
        head_version += "-dirty" if dirty
        head_version
      end
    else
      stable_tag = begin
        Utils.safe_popen_read("git", "-C", Dir.pwd, "describe", "--exact-match", "--tags", "HEAD", err: :close).strip
      rescue ErrorDuringExecution
        ""
      end
      odie "stable release checkout is not at an exact tag" if stable_tag.empty?
      stable_tag.sub(/^v/, "")
    end

    cfg = File.exist?("uni-release-cli.config") ? File.read("uni-release-cli.config") : ""
    release_base = cfg[/^RELEASE_BASE=(.+)$/, 1]&.strip || "https://release.ecomz.net"
    gitlab_base  = cfg[/^GITLAB_BASE=(.+)$/, 1]&.strip || "https://gitlab.ecomz.net"
    version_ldflag = "-X gitlab.ecomz.net/uni/uni-release-cli/internal/version.Version=#{build_version}"
    cli_ldflags = "#{version_ldflag} -X main.releaseBase=#{release_base}"
    session_ldflags = "#{version_ldflag} -X main.releaseBase=#{release_base} -X main.gitlabBase=#{gitlab_base}"

    system "go", "build", "-ldflags", cli_ldflags, "-o", bin/"uni-release-cli", "./cmd/uni-release-cli"
    system "go", "build", "-ldflags", session_ldflags, "-o", bin/"uni-release-gitlab-session", "./cmd/uni-release-gitlab-session"

    if which("swiftc")
      system "swiftc", "-O", "uni-touchid-auth.swift", "-o", bin/"uni-touchid-auth"
    else
      opoo "swiftc not found — uni-touchid-auth not built; production/selzy mutations will be blocked"
    end

    # Deliberately NOT signed here: brew's build sandbox swaps $HOME, so
    # security find-identity can never see the login Keychain no matter what —
    # signing at build time would either silently no-op or (worse) silently
    # "succeed" without actually running. The real signing happens post-install,
    # outside the sandbox, in uni-release-setup (see scripts/sign-binaries.sh's
    # require_signed_binaries).
    bin.install "uni-release-setup.sh" => "uni-release-setup"
    libexec.install "setup-signing.sh", "scripts/sign-binaries.sh", "daemon.entitlements"
    # Vendored Release Manager operator tooling, used by the `selfcheck` subcommand.
    # The three subdirectories must stay siblings: every script resolves its
    # neighbours relatively ($self_dir/../lib, $self_dir/../uni-release), see
    # scripts/release-manager/README.md. The parser test and its fixtures are
    # deliberately NOT packaged — they are only reachable through the script's
    # RELEASE_FULL_CYCLE_*_TEST hooks and have no runtime role.
    (libexec/"release-manager").install "scripts/release-manager/README.md"
    (libexec/"release-manager/lib").install Dir["scripts/release-manager/lib/*.sh"]
    (libexec/"release-manager/uni-release").install Dir["scripts/release-manager/uni-release/*.sh"]
    (libexec/"release-manager/release").install(
      Dir["scripts/release-manager/release/*.sh"].reject { |f| f.end_with?("_parser_test.sh") },
    )
    man1.install "man/uni-release-cli.1"
    bash_completion.install "completions/uni-release-cli.bash" => "uni-release-cli"
    zsh_completion.install "completions/_uni-release-cli"
    fish_completion.install "completions/uni-release-cli.fish"
    doc.install "README.md", "ARCHITECTURE.md"
    doc.install Dir["docs/*.md"], Dir["docs/*.png"]
    pkgshare.install "AGENTS.md" => "ai-instructions.md"
  end

  def caveats
    <<~EOS
      Next step — run the guided setup (idempotent, safe to re-run):

          uni-release-setup

      First create the local code-signing identity, then run the post-install setup:

          #{opt_libexec}/setup-signing.sh
          uni-release-setup

      The setup signs the installed binaries and stores your GitLab login and
      password through the signed helper. Then check it works:

          uni-release-cli list

      Docs:  uni-release-cli help  ·  man uni-release-cli  ·  #{opt_share}/doc/#{name}/guide.md
      For AI agents:  #{opt_pkgshare}/ai-instructions.md

      The helper modules must be registered in secretd by an administrator; this
      formula does not imitate or perform that external registration.
    EOS
  end

  test do
    help_output = shell_output("#{bin}/uni-release-cli help")
    assert_match "usage: uni-release-cli", help_output
    version_output = shell_output("#{bin}/uni-release-cli version")
    if build.head?
      assert_match(/^uni-release-cli HEAD-[0-9a-f]+(?:-dirty)?\n$/, version_output)
    else
      assert_equal "uni-release-cli #{stable.version}\n", version_output
    end
    assert_predicate bin/"uni-release-gitlab-session", :executable?
    assert_predicate bin/"uni-touchid-auth", :executable?
    assert_predicate bin/"uni-release-setup", :executable?
    assert_predicate libexec/"setup-signing.sh", :executable?
    assert_predicate libexec/"sign-binaries.sh", :executable?
    assert_predicate libexec/"daemon.entitlements", :file?
    assert_match "com.apple.security.cs.disable-library-validation", (libexec/"daemon.entitlements").read
    assert_match "rollout-confirm", (man1/"uni-release-cli.1").read
    assert_match "always_confirm_qa_envs", (man1/"uni-release-cli.1").read
    assert_match "--help", (bash_completion/"uni-release-cli").read
    assert_match "rollout-confirm", (bash_completion/"uni-release-cli").read
    # Packaging checks only: `selfcheck` itself is NEVER run here — it mutates a
    # live QA stand. Its ALLOW_LIVE_QA_ROLLOUT guard would refuse anyway, but the
    # rule is written down rather than left to the guard.
    assert_predicate libexec/"release-manager/release/release-full-cycle.sh", :executable?
    assert_predicate libexec/"release-manager/release/qa-stand-env-id.sh", :executable?
    assert_predicate libexec/"release-manager/uni-release/uni-release-wait-argocd.sh", :executable?
    assert_predicate libexec/"release-manager/lib/_deploy-doc-walk.sh", :file?
    system "bash", "-n", libexec/"release-manager/release/release-full-cycle.sh"
    assert_match "selfcheck", help_output
    refute_predicate libexec/"release-manager/release/release-full-cycle_parser_test.sh", :exist?
  end
end
