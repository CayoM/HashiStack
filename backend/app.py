from flask import Flask, request, jsonify
import psycopg2
import os
from dotenv import load_dotenv
import subprocess

app = Flask(__name__)

def load_secrets(secrets_file=None):
    # Stelle sicher, dass das SECRETS_FILE geladen wird, falls angegeben.
    if secrets_file:
        # Lege sicher, dass wir den Inhalt neu laden, um frische Daten zu erhalten
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

@app.route('/status', methods=['GET'])
def status():
    expected_token = get_api_token()
    token = request.headers.get("Authorization")

    if token != expected_token:
        return jsonify({"error": "Unauthorized"}), 403

    # DB-Status abrufen
    db_status = check_db_status()

    # Systeminformationen abrufen
    server_info = {
        "server": "Flask API",
        "status": "running",
        "backend_version": subprocess.getoutput("python3 --version 2>&1").split(":")[-1].strip(),
        "database": db_status
    }
    return jsonify(server_info)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
