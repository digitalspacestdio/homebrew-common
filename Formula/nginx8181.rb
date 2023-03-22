class Nginx8181 < Formula
  desc "Secondary Nginx Configuration"
  version "0.1"
  revision 4

  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  depends_on "nginx"

  keg_only "this is virtual package"

  def install
    system "echo $(date) > installed.txt"
    prefix.install "installed.txt"
  end

  service do
    run ["#{Formula["nginx"].opt_bin}/nginx", "-c", "#{etc}/nginx8181/nginx.conf", "-g", "daemon off;"]
    keep_alive true
    working_dir "#{HOMEBREW_PREFIX}"
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
