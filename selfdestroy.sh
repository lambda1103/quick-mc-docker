#!/bin/bash

export $(grep -v '^#' .env | xargs)

if [ -f /root/minecraft/mc-data/.paused ]; then
    # Find Server ID
    server_id=$(curl -s -X GET \
        -H "Authorization: Bearer $HETZNER_API_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.hetzner.cloud/v1/servers" | \
        jq -r --arg SERVER_NAME "$SERVER_NAME" '.servers[] | select(.name == $SERVER_NAME) | .id')

    # Check if server exists
    if [ -z "$server_id" ]; then
        echo "Server $SERVER_NAME not found."
        # Send error message to Discord webhook
        curl -H "Content-Type: application/json" \
            -X POST \
            -d "{\"content\":\"Error: Server $SERVER_NAME not found for deletion.\"}" \
            $DISCORD_WEBHOOK_URL
        exit 1
    fi

    # Delete Server
    curl -X DELETE \
        -H "Authorization: Bearer $HETZNER_API_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.hetzner.cloud/v1/servers/$server_id"

    echo "Server $SERVER_NAME with ID $server_id deleted successfully."

    # Check if deletion was successful
    if [ $? -eq 0 ]; then
        echo "Server $SERVER_NAME with ID $server_id deleted successfully."
        # Send success message to Discord webhook
        curl -H "Content-Type: application/json" \
            -X POST \
            -d "{\"content\":\"Success: Server $SERVER_NAME with ID $server_id deleted successfully.\"}" \
            $DISCORD_WEBHOOK_URL
    else
        echo "Failed to delete server $SERVER_NAME with ID $server_id."
        # Send error message to Discord webhook
        curl -H "Content-Type: application/json" \
            -X POST \
            -d "{\"content\":\"Error: Failed to delete server $SERVER_NAME with ID $server_id.\"}" \
            $DISCORD_WEBHOOK_URL
        exit 1
    fi
fi
