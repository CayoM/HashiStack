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
}

resource "docker_image" "backend" {
  name         = "backend:latest"
  build {
    context    = "../backend/"      # Directory with the Dockerfile
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "backend_container" {
  name  = "backend"
  image = docker_image.backend.name
  ports {
    internal = 5000
    external = 5000
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

  env = [
    "SECRETS_FILE=/shared-credentials/.env",
    "CONSUL_HTTP_ADDR=http://consul:8500"
  ]

  volumes {
    volume_name      = "shared-credentials"
    container_path = "/shared-credentials"
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
}

resource "docker_container" "database_container" {
  name  = "database"
  image = "postgres:latest"
  ports {
    internal = 5432
    external = 5432
  }
  networks_advanced {
    name = docker_network.hashi_network.name
  }
  # Umgebungsvariablen für PostgreSQL
  env = [
    "POSTGRES_DB=mydb",
    "POSTGRES_USER=backend_user",
    "POSTGRES_PASSWORD=securepassword"
  ]
  # Volume mounten
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

  capabilities {
    add = ["IPC_LOCK"]
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

  networks_advanced {
    name = docker_network.hashi_network.name
  }

  env = [
    "CONSUL_BIND_INTERFACE=eth0"
  ]
}

# Volumes to share credentials between containers
resource "docker_volume" "vault_data" {
  name = "vault-data"
}

resource "docker_volume" "shared_credentials" {
  name = "shared-credentials"
}
