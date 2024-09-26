require "formula"

class Libpam < Formula
  desc "Pluggable Authentication Modules for Linux"
  homepage "https://github.com/linux-pam/linux-pam"
  url "https://github.com/linux-pam/linux-pam/releases/download/v1.6.1/Linux-PAM-1.6.1.tar.xz"
  sha256 "f8923c740159052d719dbfc2a2f81942d68dd34fcaf61c706a02c9b80feeef8e"
  license any_of: ["BSD-3-Clause", "GPL-1.0-only"]
  head "https://github.com/linux-pam/linux-pam.git", branch: "master"

  bottle do
    root_url "https://pub-7d898cd296ae4a92a616d2e2c17cdb9e.r2.dev/common/0/libpam"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e075ed9cbf64d7ea94d49ea606b431b369cf91b56af4f04a236b75332f2ee6f9"
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