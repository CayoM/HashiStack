docker build -t hashistackwebserver .
docker run -d --name webserver -p 8080:80 hashistackwebserver