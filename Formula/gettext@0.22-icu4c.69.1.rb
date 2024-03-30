class GettextAT022Icu4c691 < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.22.5.tar.gz"
  mirror "http://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  sha256 "ec1705b1e969b83a9f073144ec806151db88127f5e40fe5a94cb6c8fa48996a0"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/gettext@0.22-icu4c.69.1"
<<<<<<< HEAD
=======
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "9aaa6f4045f1115a4a3a8dee117c9f703f0fbac5f3b536d943398a15ce90e8ed"
>>>>>>> e18045f (bottles update)
    sha256 cellar: :any_skip_relocation, sonoma:       "2a21d44015b2c00c8af149889953496705bc945d389ceba7d1b77b090012a1b9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "513bda2ea3f1994ba28bf0f925dd483815b0ea365ea5fd2dfe6fc0dc76ecaa77"
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