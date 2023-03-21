class Nginx8181 < Formula
  desc "Secondary Nginx Configuration"
  version "0.1"
  revision 3

  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  depends_on "nginx"

  keg_only "this is virtual package"

  def install
    system "echo $(date) > installed.txt"
    prefix.install "installed.txt"
  end

  plist_options manual: "nginx"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <false/>
          <key>ProgramArguments</key>
          <array>
              <string>#{Formula["nginx"].opt_bin}/nginx</string>
              <string>-c</string>
              <string>#{etc}/nginx/nginx8181.conf</string>
              <string>-g</string>
              <string>daemon off;</string>

          </array>
          <key>WorkingDirectory</key>
          <string>#{HOMEBREW_PREFIX}</string>
        </dict>
      </plist>
    EOS
  end

  test do
    (testpath/"nginx8181.conf").write <<~EOS
      worker_processes 4;
      error_log #{testpath}/error8181.log;
      pid #{testpath}/nginx8181.pid;
      events {
        worker_connections 1024;
      }
      http {
        client_body_temp_path #{testpath}/client_body_temp;
        fastcgi_temp_path #{testpath}/fastcgi_temp;
        proxy_temp_path #{testpath}/proxy_temp;
        scgi_temp_path #{testpath}/scgi_temp;
        uwsgi_temp_path #{testpath}/uwsgi_temp;
        server {
          listen 8181;
          root #{testpath};
          access_log #{testpath}/access8181.log;
          error_log #{testpath}/error8181.log;
        }
      }
    EOS
    system bin/"nginx", "-t", "-c", testpath/"nginx8181.conf"
  end
end
