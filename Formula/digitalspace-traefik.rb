class DigitalspaceTraefik < Formula
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "0.1.0"

  depends_on "traefik"
  depends_on "digitalspace-step-ca"

  def traefik_main_config
    <<~EOS
      [global]
        checkNewVersion = false
        sendAnonymousUsage = false
      
      [entryPoints]
        [entryPoints.web]
          address = ":80"
        [entryPoints.web.http.redirections.entryPoint]
          to = "default"
          scheme = "https"
          permanent = true
      
      [entryPoints.default]
        address = ":443/tcp"

      [certificatesResolvers.default.acme]
        email = "#{ENV['USER']}@localhost"
        tlsChallenge = true
        storage = "#{etc}/digitalspace-traefik/acme_default.json"
        caserver = "https://localhost:9443/acme/acme/directory"

      [certificatesResolvers.default.acme.httpChallenge]
        entryPoint = "web"

      [log]
        level = "WARN"
        filePath = "#{var}/log/digitalspace-traefik_traefik.log"
      
      [accessLog]
        filePath = "#{var}/log/digitalspace-traefik_access.log"
      
      [api]
        dashboard = true
      
      [serversTransport]
        insecureSkipVerify = true
      
      [providers.file]
        directory = "#{etc}/digitalspace-traefik/conf.d/"
        watch = true
      
      [providers.docker]
        exposedByDefault = false
      EOS
  rescue StandardError
      nil
  end

  def traefik_dashboard_config
    <<~EOS
    [http.routers]
      [http.routers.api]
        rule = "Host(`traefik.localhost`) && PathPrefix(`/api/`)"
        service = "api@internal"
        entryPoints = ["default"]
        [http.routers.api.tls]
          certResolver = "default"

      [http.routers.traefik]
        rule = "Host(`traefik.localhost`) && PathPrefix(`/`)"
        service = "dashboard@internal"
        entryPoints = ["default"]
        [http.routers.traefik.tls]
          certResolver = "default"
    EOS
  rescue StandardError
      nil
  end

  def traefik_localhost_config
    <<~EOS
    [http.routers]
      [http.routers.dev_com]
        rule = "HostRegexp(`{subdomain:[a-z0-9-]+}.dev.com`)"
        priority = 100
        service = "digitalspace-nginx"
        entryPoints = ["default"]

      [http.routers.dev_com.tls]
        certResolver = "default"
        [[http.routers.dev_com.tls.domains]]
        main = "*.dev.com"

      [http.routers.loc_com]
        rule = "HostRegexp(`{subdomain:[a-z0-9-]+}.loc.com`)"
        priority = 110
        service = "digitalspace-nginx"
        entryPoints = ["default"]

      [http.routers.loc_com.tls]
        certResolver = "default"
        [[http.routers.loc_com.tls.domains]]
        main = "*.loc.com"


      [http.routers.localhost]
        rule = "HostRegexp(`{subdomain:[a-z0-9-]+}.localhost`)"
        priority = 120
        service = "digitalspace-nginx"
        entryPoints = ["default"]

      [http.routers.localhost.tls]
        certResolver = "default"
        [[http.routers.localhost.tls.domains]]
        main = "*.localhost"

    [http.services]
      [http.services.digitalspace-nginx]
        [http.services.digitalspace-nginx.loadBalancer]
          [[http.services.digitalspace-nginx.loadBalancer.servers]]
            url = "http://127.0.0.1:1984"
    EOS
  rescue StandardError
      nil
  end

  def binary_dir
    buildpath / "bin"
  end

  def binary_path
    binary_dir / "bin" / "digitalspace-traefik"
  end

  def binary_wrapper
    <<~EOS
      #!/usr/bin/env bash
      set -e
      
      exec #{Formula["traefik"].opt_bin}/traefik "$@"
    EOS
  rescue StandardError
      nil
  end

  def install
    binary_dir.mkpath
    binary_path.write(binary_wrapper)
    binary_path.chmod(0755)
    bin.install binary_path
  end

  def post_install
    (etc/"digitalspace-traefik").mkpath
    (etc/"digitalspace-traefik"/"conf.d").mkpath
    (etc/"digitalspace-traefik"/"traefik.toml").delete if (etc/"digitalspace-traefik"/"traefik.toml").exist?
    (etc/"digitalspace-traefik"/"traefik.toml").write(traefik_main_config)

    (etc/"digitalspace-traefik"/"conf.d"/"dashboard.toml").delete if (etc/"digitalspace-traefik"/"conf.d"/"dashboard.toml").exist?
    (etc/"digitalspace-traefik"/"conf.d"/"dashboard.toml").write(traefik_dashboard_config)

    (etc/"digitalspace-traefik"/"conf.d"/"localhost.toml").delete if (etc/"digitalspace-traefik"/"conf.d"/"localhost.toml").exist?
    (etc/"digitalspace-traefik"/"conf.d"/"localhost.toml").write(traefik_localhost_config)
  end

  step_path = `#{Formula["step"].opt_bin}/step path`

  service do
    run ["#{opt_bin}/digitalspace-traefik", "--configfile=#{etc}/digitalspace-traefik/traefik.toml"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    require_root true
    log_path var/"log/digitalspace-service-traefik.log"
    error_log_path var/"log/digitalspace-service-traefik-error.log"
    environment_variables LEGO_CA_CERTIFICATES: "#{step_path.strip}/certs/root_ca.crt"
  end
end