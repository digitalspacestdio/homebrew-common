class Icu4cAT732 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://icu.unicode.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-73-2/icu4c-73_2-src.tgz"
  version "73.2"
  sha256 "818a80712ed3caacd9b652305e01afc7fa167e6f2e94996da44b90c2ab604ce1"
  license "ICU"

  livecheck do
    url :stable
    regex(/^release[._-]v?(\d+(?:[.-]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.map { |tag| tag[regex, 1]&.tr("-", ".") }.compact
    end
  end

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@73.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "022c0aca4ee0b6afb04261f7d79c781a6daee6b5ae855fbccc273f2c126c6c88"
    sha256 cellar: :any_skip_relocation, sonoma:       "ffb99550464e6ffb3f8330fe8aa38ea200a44b7259b640f9e0b46bf34115ac4d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "eb74f741bbeb48d69a99310804947311c2d348a6985814819292b6c6d0fd8890"
  end

  keg_only :versioned_formula

  def install
    args = %w[
      --disable-samples
      --disable-tests
      --enable-static
      --with-library-bits=64
    ]

    cd "source" do
      system "./configure", *std_configure_args, *args
      system "make"
      system "make", "install"
    end
  end

  test do
    if File.exist? "/usr/share/dict/words"
      system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
    else
      (testpath/"hello").write "hello\nworld\n"
      system "#{bin}/gendict", "--uchars", "hello", "dict"
    end
  end
end