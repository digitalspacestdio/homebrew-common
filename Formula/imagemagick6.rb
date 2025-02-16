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
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/imagemagick6"
    sha256 cellar: :any_skip_relocation, ventura:      "2afe0fd477e0063a88dfca1dc285d57aa677f5b2c87c512261804ca8cf61d932"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d8eb85caf6f3f8eb5dd9f6b5fc39b719c84af4dda4c09e2fd6d01ae050d0d69b"
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
  depends_on "libxml2@2.12-icu4c.74.2"

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
