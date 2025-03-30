require "formula"

class Libpam < Formula
  desc "Pluggable Authentication Modules for Linux"
  homepage "https://github.com/linux-pam/linux-pam"
  url "https://github.com/linux-pam/linux-pam/releases/download/v1.6.1/Linux-PAM-1.6.1.tar.xz"
  sha256 "f8923c740159052d719dbfc2a2f81942d68dd34fcaf61c706a02c9b80feeef8e"
  license any_of: ["BSD-3-Clause", "GPL-1.0-only"]
  head "https://github.com/linux-pam/linux-pam.git", branch: "master"
  revision 100

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/libpam"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "c62d0e9b4a91261da7339ed0db02cdfdcf1854b683f37861021ac49fee89f482"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "10221038271a116950754d1c6f902351412afa90abf90b3fa53682c9673eca4c"
  end

  depends_on "pkg-config" => :build
  depends_on "libnsl"
  depends_on "libprelude"
  depends_on "libtirpc"
  depends_on "libxcrypt"
  depends_on :linux

  keg_only :versioned_formula

  skip_clean :la

  def install
    args = %W[
      --disable-db
      --disable-silent-rules
      --disable-selinux
      --includedir=#{include}/security
      --oldincludedir=#{include}
      --enable-securedir=#{lib}/security
      --sysconfdir=#{etc}
      --with-xml-catalog=#{etc}/xml/catalog
      --with-libprelude-prefix=#{Formula["libprelude"].opt_prefix}
    ]

    system "./configure", *std_configure_args, *args
    system "make"
    system "make", "install"
  end

  test do
    assert_match "Usage: #{sbin}/mkhomedir_helper <username>",
                 shell_output("#{sbin}/mkhomedir_helper 2>&1", 14)
  end
end