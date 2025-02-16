class Icu4cAT721 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-72-1/icu4c-72_1-src.tgz"
  version "72.1"
  sha256 "a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68"
  license "ICU"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/icu4c@72.1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6b97727ed632438fcc83a8bbca1f515722aca14b5e637156d0c0ba84aa5c7e53"
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
