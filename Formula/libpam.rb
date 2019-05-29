require "formula"

class Libpam < Formula
  desc "libpam"
  homepage "https://github.com/linux-pam/linux-pam"
  url "https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1.tar.xz"
  sha256 "eff47a4ecd833fbf18de9686632a70ee8d0794b79aecb217ebd0ce11db4cd0db"
  revision 1

  def install
    system "./configure", "--prefix=#{prefix}", "--includedir=#{prefix}/include/security" "--enable-static-modules", "--disable-pie"
    system "make", "install"
  end
end