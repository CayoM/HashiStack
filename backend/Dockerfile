FROM python:3.9
WORKDIR /app

RUN curl -fsSL https://releases.hashicorp.com/consul/1.16.0/consul_1.16.0_linux_amd64.zip -o consul.zip && \
    unzip consul.zip && \
    mv consul /usr/local/bin/consul && \
    rm consul.zip

COPY app.py secrets.env consul-service.hcl /app/

RUN pip install flask psycopg2 python-dotenv

# Starte Consul-Agent und die Flask-App
CMD ["sh", "-c", "consul agent -dev -client=0.0.0.0 -bind=0.0.0.0 -retry-join=consul -config-file=/app/consul-service.hcl & python app.py"]
