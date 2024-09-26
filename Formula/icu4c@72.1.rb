class Icu4cAT721 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-72-1/icu4c-72_1-src.tgz"
  version "72.1"
  sha256 "a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68"
  license "ICU"

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/0/icu4c@72.1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3e7c16c66363d856f6f4fb555735c917ef7f97daed2a189f3b6300e9afe6b1f2"
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
