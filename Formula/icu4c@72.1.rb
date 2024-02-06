class Icu4cAT721 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-72-1/icu4c-72_1-src.tgz"
  version "72.1"
  sha256 "a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68"
  license "ICU"

  livecheck do
    url :stable
    regex(/^release[._-]v?(\d+(?:[.-]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.map { |tag| tag[regex, 1]&.gsub("-", ".") }.compact
    end
  end

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@72.1"
    sha256 cellar: :any_skip_relocation, sonoma:       "b54bbc0b653eea860989cc76d4a691e45ea3333d2480c8c65b7798c18e1a2635"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dbc3967df92e873a196284e55a8fcc29ca9f7804d9b71bdf8da486bd355b1bf5"
  end

  keg_only :versioned_formula

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-samples
      --disable-tests
      --enable-static
      --with-library-bits=64
    ]

    cd "source" do
      system "./configure", *args
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
