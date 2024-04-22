class Icu4cAT701 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-70-1/icu4c-70_1-src.tgz"
  version "70.1"
  sha256 "8d205428c17bf13bb535300669ed28b338a157b1c01ae66d31d0d3e2d47c3fd5"
  license "ICU"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@70.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "7fc43ab38e6d8198e0a1dece4f1aa18eb6d9e0492030f8a259f28347a8c03a8f"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "4f62d15e486ec54333c160be51e9a763c87e0d4db18eee6f3ed8a0dfe63bf43f"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "af1eeca1825a04bedac30f02533c449845d8fb0439ed865a46ae9faa94f55e94"
    sha256 cellar: :any_skip_relocation, sonoma:         "4c6e7e273edecc09bcf252a8d01053a3a66cd0368af5a2325d3fca501ca5b9f8"
    sha256 cellar: :any_skip_relocation, monterey:       "dc91c2f53f77eb1b20459e2b3822f6515c3a2a8c25795c7b5dc9fbd20c0e1394"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "abe5c215adb2088475ae0f5c9ad23779b3d78680f4cbba74c92286d2df2e9c35"
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
