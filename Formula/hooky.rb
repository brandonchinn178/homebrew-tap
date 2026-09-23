class Hooky < Formula
  desc "Minimal git hooks manager"
  homepage "https://github.com/brandonchinn178/hooky"
  url "https://github.com/brandonchinn178/hooky/archive/refs/tags/v1.0.6.tar.gz"
  sha256 "944a2a2a6e096059590c8933a610d01b52f2daeeb7c3d1539fc2e00c49a40c03"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/brandonchinn178/homebrew-tap/releases/download/hooky-1.0.5"
    sha256 cellar: :any, arm64_tahoe:  "f8bb08b31aab418becfbf96e5ebf0c58154c1e9352fe1be83b8246898234c29c"
    sha256 cellar: :any, x86_64_linux: "14742b719fef2231c116034618a92a41984a2277f175a65782f1fe65bf6e34e9"
  end

  depends_on "ghc@9.12" => :build
  depends_on "haskell-stack" => :build
  depends_on "gmp"
  uses_from_macos "libffi"

  def install
    system "stack", "install", ":hooky",
      "--system-ghc", "--no-install-ghc", "--skip-ghc-check",
      "--local-bin-path=#{bin}"

    [:bash, :fish, :zsh].each do |shell|
      generate_completions_from_executable(
        bin/"hooky", "--#{shell}-completion-script", bin/"hooky",
        shells: [shell], shell_parameter_format: :none
      )
    end
  end

  test do
    (testpath/".hooky.kdl").write <<~EOF
      hook hooky {
        command hooky lint {
          fix_args --fix
        }
        files *
      }
      lint_rules {
        - trailing_whitespace
      }
    EOF
    shell_output("echo 'Hello world with spaces:         ' > #{testpath}/test.txt")
    shell_output("git init")
    shell_output("#{bin}/hooky run test.txt", 1)
    shell_output("#{bin}/hooky fix test.txt", 1)
    shell_output("#{bin}/hooky run test.txt")
  end
end
