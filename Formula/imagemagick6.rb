class Imagemagick6 < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://www.imagemagick.org/download/ImageMagick-6.9.12-13.tar.xz"
  sha256 "a72cb13e79a0878a6fd07f877a61e683c29b646d4fd3ca9ff1ddc042cae846c6"
  head "https://github.com/imagemagick/imagemagick6.git"
  version "6.9.12"
  revision 13

#   bottle do
#     sha256 "ef26aa5e74724de5ad4eced9fec645c118c4f1eb212dbda0f241e9189cc089db" => :mojave
#     sha256 "34542d49f95afd743a5520e0a3e73526242b7d2aa2792ddaf1964ebb281e7ca9" => :high_sierra
#     sha256 "4b266f15f9a57fd542dd3ee6ffdad845a9f61cd757b7c7c08f5b9d9c99a8fa35" => :sierra
#   end

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
      --with-gcc-arch=opteron
      --with-xml=#{Formula["libxml2"].opt_prefix}
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
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
