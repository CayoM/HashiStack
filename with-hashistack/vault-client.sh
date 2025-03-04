#!/bin/sh

# Install jq if it's not already installed
if ! command -v jq &> /dev/null
then
    echo "jq not found, installing..."
    apk add --no-cache jq
fi

# Poll Vault for dynamic credentials periodically
while true; do
  # Try to fetch dynamic credentials for the readonly role
  creds=$(vault read -format=json database/creds/readonly 2>/dev/null)

  # Check if the vault read command was successful
  if [ $? -ne 0 ]; then
    echo "Error fetching credentials from Vault. Retrying in 30 seconds..."
    sleep 30
    continue
  fi

  # If credentials were fetched successfully, extract the username and password
  username=$(echo "$creds" | jq -r '.data.username')
  password=$(echo "$creds" | jq -r '.data.password')

  # Check if the required data is present in the response
  if [ -z "$username" ] || [ -z "$password" ]; then
    echo "Failed to get valid credentials. Retrying in 30 seconds..."
    sleep 30
    continue
  fi

  # Set the credentials as environment variables or write to a file
  echo "DB_USER=$username" > /shared-credentials/.env
  echo "DB_PASSWORD=$password" >> /shared-credentials/.env

  # Sleep before requesting new credentials (adjust as needed)
  echo "Credentials saved. Sleeping for 60 seconds..."
  sleep 60
done
