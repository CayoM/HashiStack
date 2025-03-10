terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.15"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "hashi_network" {
  name = "hashi"
  driver = "bridge"
  ipam_config {
    subnet = "172.18.0.0/16" # Define the subnet for the network
  }
}

resource "docker_image" "backend" {
  name         = "backend:latest"
  build {
    context    = "../backend/"      # Directory with the Dockerfile
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "backend_container" {
  count = 3

  name  = "backend-${count.index}"  # This will create unique container names like "backend-0", "backend-1", etc.
  image = docker_image.backend.name
  ports {
    internal = 5000
  }
  ports {
    internal = 8300
  }
  ports {
    internal = 8301
  }
  ports {
    internal = 8600
  }
  networks_advanced {
    name = docker_network.hashi_network.name
  }
  dns = ["172.18.0.10", "8.8.8.8"]
  env = [
    "CONSUL_NODE_NAME=backend-${count.index}",  # Unique node name for each instance
    "SECRETS_FILE=/shared-credentials/.env",
    "CONSUL_HTTP_ADDR=http://consul:8500"
  ]

  volumes {
    volume_name      = "shared-credentials"
    container_path   = "/shared-credentials"
  }
}


resource "docker_image" "frontend" {
  name         = "frontend:latest"
  build {
    context    = "../frontend/"      # Directory with the Dockerfile
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "frontend_container" {
  name  = "frontend"
  image = docker_image.frontend.name
  ports {
    internal = 80
    external = 80
  }
  networks_advanced {
    name = docker_network.hashi_network.name
  }

  dns = ["172.18.0.10", "8.8.8.8"]
  env = [
    "BACKEND_URL=http://backend.service.consul:5000/status"
  ]
}

resource "docker_container" "database_container" {
  name  = "database"
  image = "postgres:latest"
  ports {
    internal = 5432
  }
  networks_advanced {
    name = docker_network.hashi_network.name
  }
  #dns = ["127.0.0.1"]

  env = [
    "POSTGRES_DB=mydb",
    "POSTGRES_USER=backend_user",
    "POSTGRES_PASSWORD=securepassword"
  ]

  volumes {
    host_path      = "/workspaces/HashiStack/database/setup.sql"
    container_path = "/docker-entrypoint-initdb.d/init.sql"
    read_only      = true
  }
}

# Vault container definition
resource "docker_container" "vault_server" {
  name  = "vault"
  image = "vault:1.13.3"
  restart = "always"
  entrypoint = ["/bin/sh", "/init-vault.sh"]

  capabilities {
    add = ["IPC_LOCK"]
  }

  ports {
    internal = 8200
    external = 8200
  }
  ports {
    internal = 8201
    external = 8201
  }

  networks_advanced {
    name = docker_network.hashi_network.name
  }
  #dns = ["127.0.0.1"]

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=hashistack-token",
    "VAULT_ADDR=http://localhost:8200"
  ]

  volumes {
    host_path      = "/workspaces/HashiStack/with-hashistack/vault-server.sh"
    container_path = "/init-vault.sh"
  }

  volumes {
    volume_name      = "vault-data"
    container_path = "/vault/file"
  }
}


resource "docker_container" "vault_client" {
  name  = "vault_client"
  image = "vault:1.13.3"
  depends_on = [docker_container.vault_server]
  entrypoint = ["/bin/sh", "/vault-client.sh"]
  restart = "always"

  networks_advanced {
    name = docker_network.hashi_network.name
  }
  #dns = ["127.0.0.1"]

  env = [
    "VAULT_TOKEN=hashistack-token",
    "VAULT_ADDR=http://vault:8200"
  ]

  # Volume mounten
  volumes {
    host_path      = "/workspaces/HashiStack/with-hashistack/vault-client.sh"
    container_path = "/vault-client.sh"
  }

  volumes {
    volume_name      = "shared-credentials"
    container_path = "/shared-credentials"
  }
}

# Consul container definition
resource "docker_container" "consul_server" {
  name  = "consul"
  image = "consul:1.15"
  restart = "always"
 # entrypoint = ["/custom-entrypoint.sh", "agent"]

  capabilities {
    add = ["IPC_LOCK", "NET_ADMIN"]
  }

  ports {
    internal = 8300
    external = 8300
  }
  ports {
    internal = 8301
    external = 8301
  }
  ports {
    internal = 8302
    external = 8302
  }
  ports {
    internal = 8500
    external = 8500
  }
  ports {
    internal = 8600
    external = 8600
  }
  ports {
    internal = 53
  }
  networks_advanced {
    name = docker_network.hashi_network.name
    ipv4_address = "172.18.0.10"  # Assign the fixed IP here

  }
  #dns = ["127.0.0.1"]

  env = [
    "CONSUL_BIND_INTERFACE=eth0",
    "CONSUL_ALLOW_PRIVILEGED_PORTS=yes"
  ]

  volumes {
    host_path      = "/workspaces/HashiStack/with-hashistack/consul-server.json"
    container_path = "/consul/config/server.json"
  }
#  volumes {
 #   host_path      = "/workspaces/HashiStack/with-hashistack/consul-entrypoint.sh"
  #  container_path = "/consul/config/server.json"
  #}
}

# Volumes to share credentials between containers
resource "docker_volume" "vault_data" {
  name = "vault-data"
}

resource "docker_volume" "shared_credentials" {
  name = "shared-credentials"
}
