class Icu4cAT701 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-70-1/icu4c-70_1-src.tgz"
  version "70.1"
  sha256 "8d205428c17bf13bb535300669ed28b338a157b1c01ae66d31d0d3e2d47c3fd5"
  license "ICU"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/icu4c@70.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "5c1d5496991b507cd4acfe29eba212d50ac5fddafb905b720d44f7174a478038"
    sha256 cellar: :any_skip_relocation, ventura:       "46b8a35b4039376a438aec38384f1cb170ed8e130275e5fa7e06d3245ca433cb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7975a404540c2b4f58cea41d5434942f7d6ffb9ad5dc0aa13cdabad7a5656e54"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "62fffd6ae5d25e74304a214c51e9651385e48f5afc884b3ee1a70b71d9e97fb2"
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
