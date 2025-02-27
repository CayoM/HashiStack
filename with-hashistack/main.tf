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


resource "docker_image" "hashistack" {
  name         = "hashistack:latest"
  build {
    context    = "../"      # Directory with the Dockerfile
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "hashistack_container" {
  name  = "hashistack"
  image = docker_image.hashistack.name
  ports {
    internal = 80
    external = 8080
  }
}
