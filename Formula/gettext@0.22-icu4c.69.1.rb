class GettextAT022Icu4c691 < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.22.5.tar.gz"
  mirror "http://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  sha256 "ec1705b1e969b83a9f073144ec806151db88127f5e40fe5a94cb6c8fa48996a0"
  license "GPL-3.0-or-later"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/gettext@0.22-icu4c.69.1"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "5951cd7cb4670223e536f94c2e9dd492a7eb9f2c4a98d6a25d73eeaf06b2f4eb"
    sha256 cellar: :any_skip_relocation, ventura:       "5af18a19993fbc3bc9d63378c7d2c2360632b9cff42698d0c85aade5dc5422ce"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "81d5c557a7fccd7b2923dcb1b9450350bf1e48f0bd9a21bb374975382500030c"
  end

  #uses_from_macos "libxml2"
  uses_from_macos "ncurses"

  depends_on "digitalspacestdio/common/libxml2@2.9-icu4c.69.1" if OS.linux?
  
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
      "--with-libxml2-prefix=#{Formula["digitalspacestdio/common/libxml2@2.9-icu4c.69.1"].opt_prefix}"
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