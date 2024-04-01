class GettextAT022Icu4c721 < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.22.5.tar.gz"
  mirror "http://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  sha256 "ec1705b1e969b83a9f073144ec806151db88127f5e40fe5a94cb6c8fa48996a0"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/gettext@0.22-icu4c.72.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "7d6af196af65bd7470fa19f151dc86dc4efa0f361409fe7c77e17f27e93e80af"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "a6f0f955926f701cd106d05ea36693a90c221a57dd54af5fe9a21ca49abd3eb7"
    sha256 cellar: :any_skip_relocation, sonoma:        "04ca59ff815174c4efd18b06eb04fca59b3224435cad3d6f01ebd7e105dee771"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3c1777cf8f24af50aa2a897a56627274f62fd1e3fcfc9e6f45cfad5cff8c7e92"
  end

  #uses_from_macos "libxml2"
  uses_from_macos "ncurses"

  depends_on "digitalspacestdio/common/libxml2@2.12-icu4c.72.1" if OS.linux?

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
      "--with-libxml2-prefix=#{Formula["digitalspacestdio/common/libxml2@2.12-icu4c.72.1"].opt_prefix}"
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