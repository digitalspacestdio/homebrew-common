class Imagemagick6 < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://github.com/ImageMagick/ImageMagick6/archive/refs/tags/6.9.13-16.tar.gz"
  sha256 "ab04edc1b0b6ee39fd7f568125c1b1ec12bbdb41f97a6888f5cde8622610ae30"
  head "https://github.com/imagemagick/imagemagick6.git"
  version "6.9.13"
  revision 2

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/imagemagick6"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "28415d96c8539e39dd54475af1f41e517b1510a6db439288a00df7e27cfb059e"
    sha256 cellar: :any_skip_relocation, ventura:       "ec9d24036547bea258839480f17bc17cfd94bf63b34a3d1429bc258e5851748c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "24af6bca90e09af132299042cfb7088893a48c639b7f76540dcb418e6888ecc8"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "287207f9d97e8fcef356c00dc0f0fb9a4a28098fa5bdae58ee82f295b12a321b"
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libtool"
  depends_on "little-cms2"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "xz"
  depends_on "libxml2"

  skip_clean :la

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --disable-openmp
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-webp=yes
      --with-openjp2
      --without-gslib
      --with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts
      --without-fftw
      --without-pango
      --without-x
      --without-wmf
      --with-xml=#{Formula["libxml2"].opt_prefix}
    ]

    # versioned stuff in main tree is pointless for us
    # inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
