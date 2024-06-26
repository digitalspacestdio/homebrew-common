class GettextAT022Icu4c732 < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  mirror "https://ftpmirror.gnu.org/gettext/gettext-0.22.5.tar.gz"
  mirror "http://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
  sha256 "ec1705b1e969b83a9f073144ec806151db88127f5e40fe5a94cb6c8fa48996a0"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/gettext@0.22-icu4c.73.2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "abb50631d429e988f08410354226992a291ac5b9a23cff979b6675fe7e6db70f"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "9f4120571cb55a9ec081451b5016790b875342ca5328e33b97d17696cd80cbec"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "efd4e6168667f3790ca65a91e024ee94f88196f6a383a29769d40f672886e34f"
    sha256 cellar: :any_skip_relocation, sonoma:         "1f4c6b7e64f5b21c61903f3ba678ee99ea151805de86a41cbc61ecb76a958cfe"
    sha256 cellar: :any_skip_relocation, monterey:       "f418f08330b7568d80e062f9ed0e37342c09439121485dd1453de0d811a10416"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "176401c74ec6f6f2e740bc8b38595f42dbb307038b8643f6f5bc983fe1bf7966"
  end

  #uses_from_macos "libxml2"
  uses_from_macos "ncurses"

  depends_on "digitalspacestdio/common/libxml2@2.12-icu4c.73.2" if OS.linux?

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
      "--with-libxml2-prefix=#{Formula["digitalspacestdio/common/libxml2@2.12-icu4c.73.2"].opt_prefix}"
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