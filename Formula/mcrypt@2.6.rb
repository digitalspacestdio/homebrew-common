class McryptAT26 < Formula
  desc "Replacement for the old crypt package and crypt(1) command"
  homepage "https://mcrypt.sourceforge.io"
  url "https://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz"
  sha256 "5145aa844e54cca89ddab6fb7dd9e5952811d8d787c4f4bf27eb261e6c182098"
  license "GPL-3.0-or-later"
  revision 10

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/mcrypt@2.6"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "71b8895a5c00432fd90a4433e0b776d1d29f3f46a8652e5592fb05aa8599fd39"
    sha256 cellar: :any_skip_relocation, ventura:       "367122a5f919a4007e0b4c5b89ed8bd0c7c9953319b32e8e08b06fc35b380110"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4140ef49d153e483ce0d6d70a7ba41e2e8bf8c0b0820d6753e050b044ef5dbcc"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "64770427fbe74ca232403fdec67eed4edd36826c8f7a7f5cfc7cb19f6397f01f"
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
