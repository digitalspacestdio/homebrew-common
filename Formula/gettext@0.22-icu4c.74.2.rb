class GettextAT022Icu4c742 < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.22.5.tar.gz"
  mirror "http://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  sha256 "ec1705b1e969b83a9f073144ec806151db88127f5e40fe5a94cb6c8fa48996a0"
  license "GPL-3.0-or-later"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/gettext@0.22-icu4c.74.2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "4415345aa83d04a61f56381385e7b9517a2fc39a3e6ee14073aad3b00b78f0c3"
    sha256 cellar: :any_skip_relocation, ventura:       "16394a4453a35d0906cdbbd93537997c79cc212c113ac468762fb3124bb0dabd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "33fd11757966af161aaebeca00690cbd39e1d389eb62ce9871810e9c037715e3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "d239340eb6344fe085f73bc129ca33437fe004c30c7c24d3709145058fdc0549"
  end

  #uses_from_macos "libxml2"
  uses_from_macos "ncurses"

  depends_on "digitalspacestdio/common/libxml2@2.12-icu4c.74.2" if OS.linux?

  keg_only :versioned_formula

  def install
    args = [
      "--disable-silent-rules",
      "--with-included-glib",
      "--with-included-libcroco",
      "--with-included-libunistring",
      "--with-included-libxml",
      "--with-emacs",
      "--with-lispdir=#{elisp}",
      "--disable-java",
      "--disable-csharp",
      # Don't use VCS systems to create these archives
      "--without-git",
      "--without-cvs",
      "--without-xz",
      "--with-libxml2-prefix=#{Formula["digitalspacestdio/common/libxml2@2.12-icu4c.74.2"].opt_prefix}"
    ]
  #   args << if OS.mac?
  #     # Ship libintl.h. Disabled on linux as libintl.h is provided by glibc
  #     # https://gcc-help.gcc.gnu.narkive.com/CYebbZqg/cc1-undefined-reference-to-libintl-textdomain
  #     # There should never be a need to install gettext's libintl.h on
  #     # GNU/Linux systems using glibc. If you have it installed you've borked
  #     # your system somehow.
  #     "--with-included-gettext"
  #   else
  #     "--with-libxml2-prefix=#{Formula["digitalspacestdio/common/libxml2"].opt_prefix}"
  #   end

    system "./configure", *std_configure_args, *args
    system "make"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make", "install"
  end

  test do
    system bin/"gettext", "test"
  end
end