class Icu4cAT721 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-72-1/icu4c-72_1-src.tgz"
  version "72.1"
  sha256 "a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68"
  license "ICU"

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/icu4c@72.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "d824c9ce034003051e801fe95913e34fb38bb92b77ae01af5d01e2c2d13a6653"
    sha256 cellar: :any_skip_relocation, ventura:       "6a5a4386e99edfd75b7def86ab07c80db130c3e2af1d10c21eea41f6dc84a8b1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a8dffd53a10a73cb16fab1ecbd2a70a08532d621b90efa7315123419134aba18"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "6c8b75bf613a63a62dfc27e1b7ea8a1f45528af32b973158edf6feff312ccc50"
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
