# create local registry
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

# create k3d cluster
k3d cluster create --registry-use k3d-registry.localhost:5500

# install tilt to sync files to kubernetes
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | sudo bash