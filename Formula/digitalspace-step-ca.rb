class DigitalspaceStepCa < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.0"

  depends_on "traefik"
  depends_on "step"

  def script_step_ca_init
    <<~EOS
      #!/bin/bash
      set -e
      set -x
      step ca init --deployment-type=standalone --address=127.0.0.1:9443 --dns=localhost --name=localhost-smallstep --acme --provisioner=$USER@localhost --password-file="#{etc}/step-ca-password"
      EOS
  rescue StandardError
      nil
  end

  step_path = `#{Formula["step"].opt_bin}/step path`

  def install
    (buildpath / "bin" / "digitalspace-traefik-step-ca-init").write(script_step_ca_init)
    (buildpath / "bin" / "digitalspace-traefik-step-ca-init").chmod(0755)
    bin.install "bin/digitalspace-traefik-step-ca-init"
  end

  def post_install
    (etc/"step-ca-password").write((0...8).map { (65 + rand(26)).chr }.join) if !(etc/"step-ca-password").exist?
  end

  service do
    run ["#{Formula["step"].opt_bin}/step-ca", "#{step_path.strip}/config/ca.json", "--password-file", etc/"step-ca-password"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    require_root false
    log_path var/"log/digitalspace-service-step-ca.log"
    error_log_path var/"log/digitalspace-service-step-ca-error.log"
  end
end