#!/bin/sh

# Start Vault in dev mode (and wait until it's ready)
vault server -dev -dev-listen-address="0.0.0.0:8200" -dev-root-token-id=${VAULT_DEV_ROOT_TOKEN_ID} &
VAULT_PID=$!

# Wait for Vault to start
sleep 5

# Enable PostgreSQL secrets engine
vault secrets enable database
sleep 5

# Configure the PostgreSQL secrets engine (replace with your actual database credentials)
vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  connection_url="postgresql://{{username}}:{{password}}@database:5432/mydb?sslmode=disable" \
  allowed_roles="readonly" \
  username="backend_user" \
  password="securepassword"

# Create a role that can read from PostgreSQL
vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}'; GRANT CONNECT ON DATABASE mydb TO \"{{name}}\"; GRANT USAGE ON SCHEMA public TO \"{{name}}\"; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="2m" \
  max_ttl="24h"


# Define Vault policies to allow read access to secrets
vault policy write readonly-policy -<<EOF
path "database/creds/readonly" {
  capabilities = ["read"]
}
EOF

# Create a dynamic user based on the role to get credentials
vault read database/creds/readonly

# Keep the Vault server running
wait $VAULT_PID
