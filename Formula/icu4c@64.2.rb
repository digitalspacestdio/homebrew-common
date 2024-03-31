class Icu4cAT642 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "https://ssl.icu-project.org/"
  url "https://ssl.icu-project.org/files/icu4c/64.2/icu4c-64_2-src.tgz"
  mirror "https://github.com/unicode-org/icu/releases/download/release-64-2/icu4c-64_2-src.tgz"
  version "64.2"
  sha256 "627d5d8478e6d96fc8c90fed4851239079a561a6a8b9e48b0892f24e82d31d6c"
  revision 1

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@64.2"
    sha256 cellar: :any_skip_relocation, sonoma:       "8099815664d2b3dd330b253b3aa0b99c819f61258821acce5f3433517c3eb07b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "67bf572a9885bfdb5359a314128bcd16172b9058299cb43721b9714c0ff12ca9"
  end

  keg_only :versioned_formula

  #depends_on "gcc@11" => :build if OS.linux?

  def install
    #ENV["CC"] = "#{Formula["gcc@11"].opt_prefix}/bin/gcc-11" if OS.linux?
    #ENV["CXX"] = "#{Formula["gcc@11"].opt_prefix}/bin/g++-11" if OS.linux?
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
    system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
  end
end
