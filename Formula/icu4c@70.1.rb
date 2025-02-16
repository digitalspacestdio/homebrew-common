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
    sha256 cellar: :any_skip_relocation, arm64_ventura: "20a8a1dee26d6ea2c5e65165cfe453edb9140d6659e47e162cf4a8a6ec14e658"
    sha256 cellar: :any_skip_relocation, ventura:       "7ba290fcde2656e6a103abc9d46a59a2ed77af6892f2dfa088d9438813035616"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "603ed8c0357d3f576efddca6f18ff0abb74619fc113b755b795b57aa13424e12"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "01aa5b938be48e7b3513f5d94f40cf36e33da2307f3befc89f3d5cbb5226ddcb"
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
