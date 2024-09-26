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
    root_url "https://f003.backblazeb2.com/file/homebrew-bottles/imagemagick6"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "8459c57cbb95a7f17534747a09e386be0670b0e36ce8d7973beabaa89b8bb25c"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "37ff6fe03ac810624bd8084373ee3634940ce6a2b12a52d96978f97323d498e2"
    sha256 cellar: :any_skip_relocation, sonoma:        "f3fcf2eb2ab85f6b0f346a58c54c2983021607115c9c5f1a2502793ed8e5c2b0"
    sha256 cellar: :any_skip_relocation, monterey:      "0212124b51cc67ed7ac638c0d7f6d18b74616871f8327735e798c5da57422f56"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7ad8ab4275b82502d88227e7d10cac438efe7df6e9d76b18d703fe65fa76a4ba"
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
