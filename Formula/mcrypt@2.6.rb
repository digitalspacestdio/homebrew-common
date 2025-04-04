class McryptAT26 < Formula
  desc "Replacement for the old crypt package and crypt(1) command"
  homepage "https://mcrypt.sourceforge.io"
  url "https://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz"
  sha256 "5145aa844e54cca89ddab6fb7dd9e5952811d8d787c4f4bf27eb261e6c182098"
  license "GPL-3.0-or-later"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/mcrypt@2.6"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "166629796913513c1da98753cd10619cd16ac30e2ed69aa65b93658cf22bedad"
    sha256 cellar: :any_skip_relocation, ventura:       "961f00eccaf871d49c90e0703044d947b87020eb5055899e8f178a733622607d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "345b014c4d82aa1128ef11147216a8240a760ba0a43a6fa3cb19a9b8a042255e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a32f22d05998b067d3d7dbc4ee685d5ed2b8afbf62baa1953cadaf31ed5304d7"
  end

  keg_only :versioned_formula

  # Added automake as a build dependency to update config files in libmcrypt.
  # Please remove in future if there is a patch upstream which recognises aarch64 macos.
  depends_on "automake" => :build
  depends_on "mhash"

  uses_from_macos "zlib"

  resource "libmcrypt" do
    url "https://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz"
    sha256 "e4eb6c074bbab168ac47b947c195ff8cef9d51a211cdd18ca9c9ef34d27a373e"
  end

  # Patch to correct inclusion of malloc function on OSX.
  # Upstream: https://sourceforge.net/p/mcrypt/patches/14/
  patch :DATA

  def install
    # Work around configure issues with Xcode 12
    ENV.append "CFLAGS", "-Wno-implicit-function-declaration"
    ENV.append "CFLAGS", "-Wno-implicit-int"

    resource("libmcrypt").stage do
      # Workaround for ancient config files not recognising aarch64 macos.
      %w[config.guess config.sub].each do |fn|
        cp "#{Formula["automake"].opt_prefix}/share/automake-#{Formula["automake"].version.major_minor}/#{fn}", fn
      end

      args = []
      args << "--prefix=#{prefix}"
      args << "--mandir=#{man}"

      system "./configure", *args
      system "make", "install"
    end

    # Workaround for ancient config files not recognising aarch64 macos.
    %w[config.guess config.sub].each do |fn|
      cp "#{Formula["automake"].opt_prefix}/share/automake-#{Formula["automake"].version.major_minor}/#{fn}", fn
    end
    args = []
    args << "--prefix=#{prefix}"
    args << "--with-libmcrypt-prefix=#{prefix}"
    args << "-mandir=#{man}"

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.txt").write <<~EOS
      Hello, world!
    EOS
    system bin/"mcrypt", "--key", "TestPassword", "--force", "test.txt"
    rm "test.txt"
    system bin/"mcrypt", "--key", "TestPassword", "--decrypt", "test.txt.nc"
  end
end
  
__END__
diff --git a/src/rfc2440.c b/src/rfc2440.c
index 5a1f296..aeb501c 100644
--- a/src/rfc2440.c
+++ b/src/rfc2440.c
@@ -23,7 +23,12 @@
 #include <zlib.h>
 #endif
 #include <stdio.h>
+
+#ifdef __APPLE__
+#include <malloc/malloc.h>
+#else
 #include <malloc.h>
+#endif

 #include "xmalloc.h"
 #include "keys.h"
