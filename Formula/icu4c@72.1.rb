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
    sha256 cellar: :any_skip_relocation, arm64_ventura: "a4fec0453b5642616e6b7788dc757860b5d46756e8296226ac53c233e5f87747"
    sha256 cellar: :any_skip_relocation, ventura:       "5c75e35ab38adaba21298b8867e0dbbd60c0d14adae6314ded80945656d18245"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6b97727ed632438fcc83a8bbca1f515722aca14b5e637156d0c0ba84aa5c7e53"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "1260a928d897d6b302142503f23433a5dfd2a079837fd3090bcab3e8ca864957"
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
