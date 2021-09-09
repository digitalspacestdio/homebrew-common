class ElasticsearchAT76 < Formula
  desc "Distributed search & analytics engine"
  homepage "https://www.elastic.co/products/elasticsearch"
  url "https://github.com/elastic/elasticsearch/archive/v7.6.2.tar.gz"
  sha256 "6ff4871dcae6954e13680aefc196da574a59a36418d06a7e095550ce81a370f8"
  revision 1

  depends_on "openjdk@13"

  def cluster_name
    "elasticsearch_#{ENV["USER"]}"
  end

  patch do
    url "https://gist.githubusercontent.com/sergeycherepanov/d072acc44453b31b7892f8c838a9d91f/raw/a8c22280ff04849a86ec16590df9272f987fd331/es.patch"
    sha256 "01f3f26b1d42b7f5a7b970e05280768d797c8a1ec1d231be9da5db384850ab94"
  end

  def install
    ENV.cxx11
    # Doesn't support brewed gradle
    system "./gradlew", ":distribution:archives:no-jdk-darwin-tar:assemble"

    mkdir "tar" do
      # Extract the package to the tar directory
      system "tar", "--strip-components=1", "-xf",
        Dir["../distribution/archives/no-jdk-darwin-tar/build/distributions/elasticsearch-*.tar.gz"].first

      # Install into package directory
      libexec.install "bin", "lib", "modules"

      # Set up Elasticsearch for local development:
      inreplace "config/elasticsearch.yml" do |s|
        # 1. Give the cluster a unique name
        s.gsub!(/#\s*cluster\.name: .*/, "cluster.name: #{cluster_name}")

        # 2. Configure paths
        s.sub!(%r{#\s*path\.data: /path/to.+$}, "path.data: #{var}/lib/elasticsearch/")
        s.sub!(%r{#\s*path\.logs: /path/to.+$}, "path.logs: #{var}/log/elasticsearch/")
      end

      inreplace "config/jvm.options", %r{logs/gc.log}, "#{var}/log/elasticsearch/gc.log"

      # Move config files into etc
      (etc/"elasticsearch").install Dir["config/*"]
    end

    inreplace libexec/"bin/elasticsearch-env",
              "if [ -z \"$ES_PATH_CONF\" ]; then ES_PATH_CONF=\"$ES_HOME\"/config; fi",
              "if [ -z \"$ES_PATH_CONF\" ]; then ES_PATH_CONF=\"#{etc}/elasticsearch\"; fi"

    bin.install libexec/"bin/elasticsearch",
                libexec/"bin/elasticsearch-keystore",
                libexec/"bin/elasticsearch-plugin",
                libexec/"bin/elasticsearch-shard"
    bin.env_script_all_files(libexec/"bin", :JAVA_HOME => Formula["openjdk@13"].opt_prefix)
  end

  def post_install
    # Make sure runtime directories exist
    (var/"lib/elasticsearch").mkpath
    (var/"log/elasticsearch").mkpath
    ln_s etc/"elasticsearch", libexec/"config" unless (libexec/"config").exist?
    (var/"elasticsearch/plugins").mkpath
    ln_s var/"elasticsearch/plugins", libexec/"plugins" unless (libexec/"plugins").exist?
    # fix test not being able to create keystore because of sandbox permissions
    system bin/"elasticsearch-keystore", "create" unless (etc/"elasticsearch/elasticsearch.keystore").exist?
    system bin/"elasticsearch-plugin", "install", "analysis-icu"
    system bin/"elasticsearch-plugin", "install", "analysis-phonetic"
  end

  def caveats
    s = <<~EOS
      Data:    #{var}/lib/elasticsearch/
      Logs:    #{var}/log/elasticsearch/#{cluster_name}.log
      Plugins: #{var}/elasticsearch/plugins/
      Config:  #{etc}/elasticsearch/
    EOS

    s
  end

  plist_options :manual => "elasticsearch"
  service do
    run [opt_sbin/"elasticsearch"]
    run_type :immediate
    keep_alive true
    error_log_path var/"log/elasticsearch.log"
    working_dir var
  end

  test do
    port = free_port
    pid = testpath/"pid"
    system bin/"elasticsearch", "-d", "-p", pid,
                                "-Ehttp.port=#{port}",
                                "-Epath.data=#{testpath}/data",
                                "-Epath.logs=#{testpath}/logs"
    sleep 10
    output = shell_output("curl -s -XGET localhost:#{port}/")
    #assert_equal "oss", JSON.parse(output)["version"]["build_flavor"]

    system "#{bin}/elasticsearch-plugin", "list"
  end
end
