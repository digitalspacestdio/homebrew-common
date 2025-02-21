class Autoconf269 < Formula
    desc "Automatic configure script builder"
    homepage "https://www.gnu.org/software/autoconf/"
    url "https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz"
    mirror "https://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz"
    sha256 "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969"
    license all_of: [
      "GPL-3.0-or-later",
      "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
    ]
    revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/autoconf269"
    sha256 cellar: :any_skip_relocation, ventura:      "5fd4e4bf0941d0883e12ea81b449f5a933d58cee0246da69c9797e31bdf60706"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f9c9ef32dda0a64d3bc864182df24dca5e5589f0f766ae463755b358e47cbf42"
  end
  
    keg_only :versioned_formula
  
    depends_on "m4"
    uses_from_macos "perl"
  
    def install
      if OS.mac?
        ENV["PERL"] = "/usr/bin/perl"
  
        # force autoreconf to look for and use our glibtoolize
        inreplace "bin/autoreconf.in", "libtoolize", "glibtoolize"
        # also touch the man page so that it isn't rebuilt
        inreplace "man/autoreconf.1", "libtoolize", "glibtoolize"
      end
  
      system "./configure", "--prefix=#{prefix}", "--with-lispdir=#{elisp}"
      system "make", "install"
  
      rm(info/"standards.info")
    end
  
    test do
      cp prefix/"share/autoconf/autotest/autotest.m4", "autotest.m4"
      system bin/"autoconf", "autotest.m4"
  
      (testpath/"configure.ac").write <<~EOS
        AC_INIT([hello], [1.0])
        AC_CONFIG_SRCDIR([hello.c])
        AC_PROG_CC
        AC_OUTPUT
      EOS
      (testpath/"hello.c").write "int foo(void) { return 42; }"
  
      system bin/"autoconf"
      system "./configure"
      assert_predicate testpath/"config.status", :exist?
      assert_match(/\nCC=.*#{ENV.cc}/, (testpath/"config.log").read)
    end
  end