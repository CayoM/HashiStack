#!/bin/sh

# Install jq if it's not already installed
if ! command -v jq &> /dev/null
then
    echo "jq not found, installing..."
    apk add --no-cache jq
fi

# Poll Vault for dynamic credentials periodically
while true; do
  # Fetch dynamic credentials for the readonly role
  creds=$(vault read -format=json database/creds/readonly)

  # Extract username and password from the response
  username=$(echo "$creds" | jq -r '.data.username')
  password=$(echo "$creds" | jq -r '.data.password')

  # Set the credentials as environment variables or write to a file
  echo "DB_USERNAME=$username" > /shared-credentials/.env
  echo "DB_PASSWORD=$password" >> /shared-credentials/.env

  # Sleep before requesting new credentials (adjust as needed)
  sleep 60
done
