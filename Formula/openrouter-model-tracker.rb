class OpenrouterModelTracker < Formula
  desc "Regenerate the OpenRouter model comparison document from live data"
  homepage "https://openrouter.ai/"
  license "MIT"
  version "1.21.1"

  on_macos do
    on_arm do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.21.1/openrouter-1.21.1-darwin-arm64.tar.gz"
      sha256 "22034a0f67f897b56968f65e4d0854e66d234f1bee37b9c1796e5cd932f932d7"
    end
    on_intel do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.21.1/openrouter-1.21.1-darwin-amd64.tar.gz"
      sha256 "89e044f937e2f52c62bf4fd33e5338e249671cda6c276cad1c588a35b01d6a51"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.21.1/openrouter-1.21.1-linux-arm64.tar.gz"
      sha256 "1cf0948bef15f578a53fb5f0844eb2603a030844042745ee8973b2011f1a6f13"
    end
    on_intel do
      url "https://github.com/MikcleGrok/openrouter-model-tracker/releases/download/v1.21.1/openrouter-1.21.1-linux-amd64.tar.gz"
      sha256 "7a82f9f521df4e43443a6a33a087b1b28bdfa34586169c9d8fa9570a401a0be6"
    end
  end

  def install
    bin.install Dir["openrouter-*"].first => "openrouter-model-tracker"
    bin.install_symlink "openrouter-model-tracker" => "omt"

    generate_completions_from_executable(bin/"openrouter-model-tracker", shell_parameter_format: :cobra,
                                                                         shells:                 [:bash])

    # Cobra derives the `complete -F <func> <name>` registration in the
    # generated script from the root command's `Use:` ("openrouter"), not
    # from the name(s) this formula actually installs the binary under, so
    # neither real invocation name works out of the box. Append explicit
    # registrations for both `openrouter-model-tracker` and `omt` onto the
    # same completion function the generated script defines.
    completion_script = bash_completion/"openrouter-model-tracker"
    completion_script.write(<<~BASH, mode: "a")

      if [[ $(type -t compopt) = "builtin" ]]; then
          complete -o default -F __start_openrouter openrouter-model-tracker
          complete -o default -F __start_openrouter omt
      else
          complete -o default -o nospace -F __start_openrouter openrouter-model-tracker
          complete -o default -o nospace -F __start_openrouter omt
      fi
    BASH

    # bash-completion's dynamic loader finds a script by the exact command
    # name being completed, so `omt` needs its own filename too.
    bash_completion.install_symlink "openrouter-model-tracker" => "omt"
  end

  test do
    assert_equal "openrouter #{version}\n", shell_output("#{bin}/openrouter-model-tracker version")
    assert_equal "openrouter version #{version}\n", shell_output("#{bin}/openrouter-model-tracker --version")
    system bin/"openrouter-model-tracker", "--help"
    assert_predicate bin/"omt", :symlink?
    assert_equal "openrouter version #{version}\n", shell_output("#{bin}/omt --version")
  end
end
