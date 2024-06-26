class GettextAT022Icu4c742 < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.22.5.tar.gz"
  mirror "http://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  sha256 "ec1705b1e969b83a9f073144ec806151db88127f5e40fe5a94cb6c8fa48996a0"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/gettext@0.22-icu4c.74.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "83794e40c96c957a6e281ac2b7b00422d5407dd9e8f4ff42598994c0375b6a9c"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "0855bbbf0a3fa04a283b347ea005e002adf508ffd65287d34ffa79743099e1a9"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "15a8d33c4237e2a61fd5a068d0b55a014b6fe16580d4148279913da472315333"
    sha256 cellar: :any_skip_relocation, sonoma:         "8d8a0511ce821f9d0bbb7424cdfe8f26bad11f4f8daf4683083477623eefbc3d"
    sha256 cellar: :any_skip_relocation, monterey:       "37511042e6442ef884efe62ccc4a8501488b99dfd3fd647ace2defae558344f6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "30e1f6204649a31160094ac702edde166f559c32aeb25097631201c6ae78e07e"
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