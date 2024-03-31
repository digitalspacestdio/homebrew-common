class LibiconvAT115 < Formula
  desc "Conversion library"
  homepage "https://www.gnu.org/software/libiconv/"
  url "https://ftp.gnu.org/gnu/libiconv/libiconv-1.15.tar.gz"
  mirror "https://ftpmirror.gnu.org/libiconv/libiconv-1.15.tar.gz"
  sha256 "ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/libiconv@1.15"
    sha256 cellar: :any_skip_relocation, sonoma: "c045fa46a4b4944da89253e068f4cbf2bb4165e24073703347bc88b6e12a12e1"
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