provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "hashistack" {
  name         = "hashistack:latest"
  build {
    context    = "../"      # Directory with the Dockerfile
    dockerfile = "Containerfile"
  }
}

resource "docker_container" "hashistack_container" {
  name  = "hashistack"
  image = docker_image.hashistack_container.name
  ports {
    internal = 80
    external = 8080
  }
}
