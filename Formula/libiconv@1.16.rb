class LibiconvAT116 < Formula
  desc "Conversion library"
  homepage "https://www.gnu.org/software/libiconv/"
  url "https://ftp.gnu.org/gnu/libiconv/libiconv-1.16.tar.gz"
  mirror "https://ftpmirror.gnu.org/libiconv/libiconv-1.16.tar.gz"
  sha256 "e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04"
  license all_of: ["GPL-3.0-or-later", "LGPL-2.0-or-later"]

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libiconv@1.16"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "3b1179c25a7c231b060d2fc18e2b4b51ee47166ffc478e8980a3f3e9d0ae94d8"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "7349103117fc26ef75540ba22b97e02b5514e550414d44cad4184bfba2dd52d3"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a43f34edf30c5fd02d64b6ed4e6dc012d67537dcbb09df3cb165fefcfc9eaa74"
    sha256 cellar: :any_skip_relocation, sonoma:         "7811fc54bf52ba0c7640796507cf1e3da1d09c24453ee641598c4831e1171577"
    sha256 cellar: :any_skip_relocation, monterey:       "41619d1bc5984409b741a1df5d952e78ee6f59bb86a3be27cb642420bdad5df8"
  end

  keg_only :versioned_formula

  depends_on :macos

  patch do
    url "https://raw.githubusercontent.com/Homebrew/patches/9be2793af/libiconv/patch-utf8mac.diff"
    sha256 "e8128732f22f63b5c656659786d2cf76f1450008f36bcf541285268c66cabeab"
  end

  depends_on "gcc@11"

  patch :DATA

  def install
    ENV["CC"] = "#{Formula["gcc@11"].opt_prefix}/bin/gcc-11"
    ENV["CXX"] = "#{Formula["gcc@11"].opt_prefix}/bin/g++-11"
    ENV.deparallelize
    ENV.append "CFLAGS", "-Wno-incompatible-pointer-types"
    ENV.append "CFLAGS", "-Wno-implicit-int"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-extra-encodings",
                          "--enable-static",
                          "--docdir=#{doc}"
    system "make", "-f", "Makefile.devel", "CFLAGS=#{ENV.cflags}", "CC=#{ENV.cc}"
    system "make", "install"
  end

  test do
    system bin/"iconv", "--help"
  end
end


__END__
diff --git a/lib/flags.h b/lib/flags.h
index d7cda21..4cabcac 100644
--- a/lib/flags.h
+++ b/lib/flags.h
@@ -14,6 +14,7 @@

 #define ei_ascii_oflags (0)
 #define ei_utf8_oflags (HAVE_ACCENTS | HAVE_QUOTATION_MARKS | HAVE_HANGUL_JAMO)
+#define ei_utf8mac_oflags (HAVE_ACCENTS | HAVE_QUOTATION_MARKS | HAVE_HANGUL_JAMO)
 #define ei_ucs2_oflags (HAVE_ACCENTS | HAVE_QUOTATION_MARKS | HAVE_HANGUL_JAMO)
 #define ei_ucs2be_oflags (HAVE_ACCENTS | HAVE_QUOTATION_MARKS | HAVE_HANGUL_JAMO)
 #define ei_ucs2le_oflags (HAVE_ACCENTS | HAVE_QUOTATION_MARKS | HAVE_HANGUL_JAMO)