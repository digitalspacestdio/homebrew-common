class Icu4cAT671 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-67-1/icu4c-67_1-src.tgz"
  version "67.1"
  sha256 "94a80cd6f251a53bd2a997f6f1b5ac6653fe791dfab66e1eb0227740fb86d5dc"
  license "ICU"
  revision 2

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/release[._-]v?(\d+(?:[.-]\d+)+)["' >]}i)
  end

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/icu4c@67.1"
    sha256 cellar: :any_skip_relocation, sonoma:       "8e6acb5fb109a7cffd73e1cf5e119e451edeb324f0e9558234c183537c6b2ff1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1ea035c0d89deecc1e52c3e447319de462e69511ea3835c94c9eb1ed35b767e6"
  end

  keg_only :versioned_formula

  #depends_on "gcc" => :build if OS.mac?

  # fix C++14 compatibility of U_ASSERT macro.
  # Remove with next release (ICU 68).
  patch :p2 do
    url "https://github.com/unicode-org/icu/commit/715d254a02b0b22681cb6f861b0921ae668fa7d6.patch?full_index=1"
    sha256 "a87e1b9626ec5803b1220489c0d6cc544a5f293f1c5280e3b27871780c4ecde8"
  end

  def install
    #ENV["CC"] = "#{Formula["gcc"].opt_prefix}/bin/gcc-11" if OS.mac?
    #ENV["CXX"] = "#{Formula["gcc"].opt_prefix}/bin/g++-11" if OS.mac?
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
