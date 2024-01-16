job "spring" {
    region = "us"
    datacenters = ["us-east-1"]
    type = "service"
    group "spring" {
        constraint {
            operator = "distinct_hosts"
            value = "true"
        }
        count = 3
        task "spring" {
            driver = "docker"
            config {
                image = "lanceplarsen/spring-vault-demo"
                volumes = ["local/bootstrap.yaml:/bootstrap.yaml"]
		network_mode = "host"
                port_map {
                    app = 8080
                }
            }

            template {
              data = <<EOH
              spring.application.name: spring-vault-demo
              spring.cloud.vault:
                  authentication: TOKEN
                  token: ${VAULT_TOKEN}
                  host: active.vault.service.consul
                  port: 8200
                  scheme: http
                  fail-fast: true
                  config.lifecycle.enabled: true
                  database:
                      enabled: true
                      role: order
                      backend: database
              spring.datasource:
                url: {{ key "postgres/jdbc" }}
              EOH

              destination = "local/bootstrap.yaml"
            }

            resources {
                cpu = 500# 500 MHz
                memory = 2048# 256 MB
                network {
                    mbits = 10
                    port "app" {
                        static = "8080"
                    }
                }
            }
            service {
                name = "spring"
                tags = ["spring", "urlprefix-/spring strip=/spring"]
                port = "app"
                check {
                    name = "alive"
                    type = "tcp"
                    interval = "10s"
                    timeout = "2s"
                }
            }

vault {
  policies = ["order"]
}


        }
    }
}