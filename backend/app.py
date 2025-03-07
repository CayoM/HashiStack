from flask import Flask, request, jsonify
import psycopg2
import os
from dotenv import load_dotenv
import subprocess
import json

app = Flask(__name__)

def load_secrets(secrets_file=None):
    if secrets_file:
        print(f"Lade Secrets aus: {secrets_file}")
        load_dotenv(secrets_file, override=True)  # 'override=True' stellt sicher, dass Variablen überschrieben werden
    else:
        load_dotenv('secrets.env', override=True)  # Fallback zu 'secrets.env'

def get_db_connection():
    # Versuche, das SECRETS_FILE zu laden, falls es gesetzt ist
    secrets_file = os.environ.get('SECRETS_FILE')

    # Lade SECRETS_FILE, wenn es gesetzt ist, und erzwinge, dass es neu geladen wird
    if secrets_file:
        load_secrets(secrets_file)
    else:
        load_secrets('secrets.env')  # Falls kein SECRETS_FILE gesetzt ist, lade 'secrets.env'

    # Überprüfen, ob DB_USER und DB_PASSWORD vorhanden sind
    db_user = os.environ.get('DB_USER')
    db_password = os.environ.get('DB_PASSWORD')

    if not db_user or not db_password:
        print("DB_USER oder DB_PASSWORD fehlen in SECRETS_FILE. Lade 'secrets.env'.")
        load_secrets('secrets.env')  # Lade 'secrets.env', wenn die Werte fehlen
        db_user = os.environ.get('DB_USER')
        db_password = os.environ.get('DB_PASSWORD')

    # DB-Verbindungsdaten
    db_host = os.environ.get('DB_HOST', 'database')  # Default to 'database' if not set
    db_port = os.environ.get('DB_PORT', '5432')      # Default to '5432' if not set
    db_name = os.environ.get('DB_NAME', 'mydb')      # Default to 'mydb' if not set

    # Wenn das Passwort fehlt, hebe einen Fehler hervor
    if not db_password:
        raise ValueError("DB_PASSWORD ist nicht gesetzt! Überprüfe die secrets.env Datei.")

    # Debugging-Ausgabe
    print(f"Verbindung mit den folgenden Daten: DB_HOST: {db_host}, DB_PORT: {db_port}, DB_NAME: {db_name}, DB_USER: {db_user}")

    # Versuche, die Verbindung aufzubauen
    try:
        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            dbname=db_name,
            user=db_user,
            password=db_password
        )
        return conn, db_user, db_password  # Rückgabe der Verbindung und der Zugangsdaten
    except psycopg2.Error as e:
        print(f"Fehler bei der Verbindung mit {secrets_file}: {e}")

        # Falls die Verbindung fehlschlägt, lade das Standard-secrets.env-File
        load_secrets('secrets.env')

        # Erneut Verbindungsdaten laden
        db_host = os.environ.get('DB_HOST', 'database')  # Default to 'database' if not set
        db_port = os.environ.get('DB_PORT', '5432')      # Default to '5432' if not set
        db_name = os.environ.get('DB_NAME', 'mydb')      # Default to 'mydb' if not set
        db_user = os.environ.get('DB_USER')
        db_password = os.environ.get('DB_PASSWORD')

        # Versuche erneut, eine Verbindung herzustellen
        try:
            conn = psycopg2.connect(
                host=db_host,
                port=db_port,
                dbname=db_name,
                user=db_user,
                password=db_password
            )
            return conn, db_user, db_password  # Rückgabe der Verbindung und der Zugangsdaten
        except psycopg2.Error as e:
            print(f"Fehler bei der Verbindung mit der Standard 'secrets.env': {e}")
            raise  # Fehler weitergeben, um die Anwendung zu stoppen

def get_api_token():
    # Holt sich die API-Token von der DB, falls erforderlich
    conn, _, _ = get_db_connection()  # Wir holen uns nur die Verbindung
    cur = conn.cursor()
    cur.execute("SELECT token FROM api_keys LIMIT 1")
    token = cur.fetchone()[0]
    cur.close()
    conn.close()
    return token

def check_db_status():
    try:
        # DB-Verbindung neu herstellen, jedes Mal mit aktuellen Daten
        conn, db_user, db_password = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT version();")
        db_version = cur.fetchone()[0]
        cur.close()
        conn.close()
        return {
            "status": "connected",
            "version": db_version,
            "user": db_user,  # Zeige den User an, der sich verbindet
            "password": db_password  # Zeige das Passwort an (nur zu Debugging-Zwecken, bitte in der Produktion entfernen!)
        }
    except psycopg2.Error as e:
        return {
            "status": "error",
            "message": str(e)
        }

def parse_consul_nodes_output(output):
    # Split the output into lines
    lines = output.splitlines()

    # Skip the first line (header) and process the remaining lines
    nodes = []
    for line in lines[1:]:  # Skip the first line (header)
        parts = line.split()
        if len(parts) >= 4:  # Ensure we have at least 4 parts (Node, ID, Address, DC)
            node = {
                "Node": parts[0],   # Node ID
                "ID": parts[1],     # Node's unique ID
                "Address": parts[2],  # Node's IP address
                "DC": parts[3],     # Data Center
                "Status": "unknown",  # Default value for Status
                "Tags": []            # Default to empty list for Tags
            }
            # You might need to modify the node parsing logic here to extract additional fields like 'Status' or 'Tags'
            nodes.append(node)

    return nodes


def get_consul_nodes():
    # Führe den Konsul-Befehl aus und hole die Nodes im Standardformat
    command = ["consul", "members", "-http-addr=http://consul:8500"]

    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        nodes_output = result.stdout  # Konsul-Ausgabe als Text
        print("Consul Nodes Output: ", nodes_output)  # Debugging output
        nodes = parse_consul_nodes_output(nodes_output)  # Extrahiere die relevanten Nodes
        return nodes
    except subprocess.CalledProcessError as e:
        print(f"Error while fetching Consul nodes: {e}")
        print(f"stderr: {e.stderr}")  # Capture the error message
        return []


def parse_consul_services_output(output):
    lines = output.splitlines()
    services = []

    for line in lines:
        service_info = line.strip()
        if service_info:
            service_name = service_info.split()[0]  # Assuming the service is the first word in the line
            tags = []  # Extract tags if available
            services.append({
                "Service": service_name,
                "Tags": tags
            })
    return services


def get_consul_services():
    # Führe den Konsul-Befehl aus und hole die Services im Standardformat
    command = ["consul", "catalog", "services", "-tags", "-http-addr=http://consul:8500"]

    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        services_output = result.stdout  # Konsul-Ausgabe als Text
        print("Consul Services Output: ", services_output)  # Debugging output
        services = parse_consul_services_output(services_output)  # Extrahiere die relevanten Services
        return services
    except subprocess.CalledProcessError as e:
        print(f"Error while fetching Consul services: {e}")
        print(f"stderr: {e.stderr}")  # Capture the error message
        return []


@app.route('/status', methods=['GET'])
def status():
    expected_token = get_api_token()
    token = request.headers.get("Authorization")

    if token != expected_token:
        return jsonify({"error": "Unauthorized"}), 403

    # DB-Status abrufen
    db_status = check_db_status()

    # Consul Nodes und Services abrufen
    consul_nodes = get_consul_nodes()
    consul_services = get_consul_services()

    # Systeminformationen abrufen
    server_info = {
        "server": "Flask API",
        "status": "running",
        "backend_version": subprocess.getoutput("python3 --version 2>&1").split(":")[-1].strip(),
        "database": db_status,
        "consul": {
            "nodes": consul_nodes,
            "services": consul_services
        }
    }
    return jsonify(server_info)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
