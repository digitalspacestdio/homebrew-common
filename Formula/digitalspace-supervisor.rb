class Digitalvisor < Formula
  include Language::Python::Virtualenv

  desc "Super Process Control System for DigitalSpace Services"
  homepage "http://supervisord.org/"
  url "https://files.pythonhosted.org/packages/b3/41/2806c3c66b3e4a847843821bc0db447a58b7a9b0c39a49b354f287569130/supervisor-4.2.4.tar.gz"
  sha256 "40dc582ce1eec631c3df79420b187a6da276bbd68a4ec0a8f1f123ea616b97a2"
  license "BSD-3-Clause-Modification"
  head "https://github.com/Supervisor/supervisor.git", branch: "master"
  depends_on "python@3.10"
  revision 3

  keg_only "support formula"

  def log_dir
      var / "log"
  end

  def install
    inreplace buildpath/"supervisor/skel/sample.conf" do |s|
      s.gsub! %r{/tmp/supervisor\.sock}, var/"run/digitalvisor.sock"
      s.gsub! %r{/tmp/supervisord\.log}, var/"log/digitalvisor.log"
      s.gsub! %r{/tmp/supervisord\.pid}, var/"run/digitalvisor.pid"
      s.gsub!(/^;\[include\]$/, "[include]")
      s.gsub! %r{^;files = relative/directory/\*\.ini$}, "files = #{etc}/digitalvisor.d/*.ini"
    end

    virtualenv_install_with_resources

    etc.install buildpath/"supervisor/skel/sample.conf" => "digitalvisor.conf"
    log_dir.mkpath
  end

  def post_install
    (var/"run").mkpath
    (var/"log").mkpath
    conf_warn = <<~EOS
      The default location for supervisor's config file is now:
        #{etc}/supervisord.conf
      Please move your config file to this location and restart supervisor.
    EOS
    old_conf = etc/"digitalvisor.ini"
    opoo conf_warn if old_conf.exist?
  end

  service do
    run [opt_bin/"supervisord", "-c", etc/"digitalvisor.conf", "--nodaemon"]
    keep_alive true
  end

  test do
    (testpath/"sd.ini").write <<~EOS
      [unix_http_server]
      file=digitalvisor.sock

      [supervisord]
      loglevel=debug

      [rpcinterface:supervisor]
      supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

      [supervisorctl]
      serverurl=unix://digitalvisor.sock
    EOS

    begin
      pid = fork { exec bin/"supervisord", "--nodaemon", "-c", "sd.ini" }
      sleep 1
      output = shell_output("#{bin}/supervisorctl -c sd.ini version")
      assert_match version.to_s, output
    ensure
      Process.kill "TERM", pid
    end
  end
end
