class Hooky < Formula
  desc "Minimal git hooks manager"
  homepage "https://github.com/brandonchinn178/hooky"
  url "https://github.com/brandonchinn178/hooky/archive/refs/tags/v1.0.6.tar.gz"
  sha256 "944a2a2a6e096059590c8933a610d01b52f2daeeb7c3d1539fc2e00c49a40c03"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/brandonchinn178/homebrew-tap/releases/download/hooky-1.0.6"
    sha256 cellar: :any, arm64_tahoe:  "43a3dc35d0bdfbf0b79d6b63de4727827ad4dd4d0ee4507be4428a7f5fcc54fd"
    sha256 cellar: :any, x86_64_linux: "41c46e0513d3e47ff00fa779743132341bd9baf3865fcf0e79bece7857087965"
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
