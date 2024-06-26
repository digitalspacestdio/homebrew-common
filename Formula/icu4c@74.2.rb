class Icu4cAT742 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://icu.unicode.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-74-2/icu4c-74_2-src.tgz"
  version "74.2"
  sha256 "68db082212a96d6f53e35d60f47d38b962e9f9d207a74cfac78029ae8ff5e08c"
  license "ICU"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@74.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "6d3d6c76f67ae2cd5b514be167dd5db9b7b2546ecfac5b2ffd292b2713d918e7"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "e38ce4b03c40ee527050a5c03013c8f45fd61346d5610db9c80979af01ca77fe"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "db517f87e02c7eb8f95c87e4683d4f1b095351b4d35d1be54c663f43383e0204"
    sha256 cellar: :any_skip_relocation, sonoma:         "08c9dc9f85276360a4350949c4da8c2a81098f66e2d3c97cef549a53789086cf"
    sha256 cellar: :any_skip_relocation, monterey:       "09b137f8a09b78634d40da2f425e4d5b6bf2a357b9cb0faa0ac5590a1fa5b2bc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1d9da3a5f40a1b8223d65019b43a4bd341177c86183154754e039da05f4ec7b8"
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
      system "./configure", *args, *std_configure_args
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