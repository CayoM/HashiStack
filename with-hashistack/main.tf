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
    external = 8080
  }
}

resource "docker_image" "database" {
  name = "postgres:latest"
}

resource "docker_container" "database_container" {
  name  = "database"
  image = docker_image.database.name
  ports {
    internal = 5432
    external = 5432
  }
  env = ["POSTGRES_DB=mydb", "POSTGRES_USER=backend_user", "POSTGRES_PASSWORD=securepassword"]
}
