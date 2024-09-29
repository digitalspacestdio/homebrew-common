class MsmtpAT18 < Formula
    desc "SMTP client that can be used as an SMTP plugin for Mutt"
    homepage "https://marlam.de/msmtp/"
    url "https://marlam.de/msmtp/releases/msmtp-1.8.26.tar.xz"
    sha256 "6cfc488344cef189267e60aea481f00d4c7e2a59b53c6c659c520a4d121f66d8"
    license "GPL-3.0-or-later"
  
    livecheck do
      url "https://marlam.de/msmtp/download/"
      regex(/href=.*?msmtp[._-]v?(\d+(?:\.\d+)+)\.t/i)
    end
  
    depends_on "pkg-config" => :build
    depends_on "gettext@0.22-icu4c.74.2"
    depends_on "gnutls"
    depends_on "libidn2"
  
    def install
      system "./configure", *std_configure_args, "--disable-silent-rules", "--with-macosx-keyring"
      system "make", "install"
      (pkgshare/"scripts").install "scripts/msmtpq"
    end
  
    test do
      system bin/"msmtp", "--help"
    end
  end