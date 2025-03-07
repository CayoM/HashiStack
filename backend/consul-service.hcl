# Consul configuration for client
server = false
retry_join = ["consul"]

data_dir = "/consul/data"

# Enable Consul's DNS server on all network interfaces (0.0.0.0)
addresses {
  dns = "0.0.0.0"  # Listen on all network interfaces for DNS
}

# Service configuration for backend
services {
  name    = "backend"
  id      = "backend"
  port    = 5000
  tags    = ["api", "backend"]

  check {
    http     = "http://localhost:5000/health"
    interval = "10s"
  }
}

# Service configuration for DNS
services {
  id      = "dns"
  name    = "dns"
  tags    = ["primary"]
  address = "localhost"
  port    = 8600
  enable_tag_override = false

  check {
    id        = "dns"
    name      = "Consul DNS TCP on port 8600"
    tcp       = "localhost:8600"
    interval  = "10s"
    timeout   = "1s"
  }
}
