docker-compose up -d

# docker network create hashi

# docker build -t frontend frontend/
# docker run -d --name frontend -p 8080:80 --network=hashi frontend

# docker build -t backend backend/
# docker run -d --name backend -p 5000:5000 --network=hashi backend

# docker run -d --name database -p 5432:5432 -v ./database/setup.sql:/docker-entrypoint-initdb.d/init.sql -e POSTGRES_DB='mydb' -e POSTGRES_USER='backend_user' -e POSTGRES_PASSWORD='securepassword' --network=hashi postgres:latest


# podman create network hashi

# podman build -t frontend frontend/
# podman run -d --name frontend -p 8080:80 --network hashi frontend
# podman run -d --name frontend -p 8080:80 --network hashi -v frontend/index.php:/usr/share/nginx/html/index.php frontend

# podman build -t backend backend/
# podman run -d --name backend -p 5000:5000 --network hashi backend

# podman run -d --name database -p 5432:5432 -v ./database/setup.sql:/docker-entrypoint-initdb.d/init.sql -e POSTGRES_DB='mydb' -e POSTGRES_USER='backend_user' -e POSTGRES_PASSWORD='securepassword' --network hashi postgres:latest
