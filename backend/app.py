from flask import Flask, request, jsonify
import psycopg2
import os
import subprocess

app = Flask(__name__)

DB_CONFIG = {
    "dbname": "mydb",
    "user": "backend_user",
    "password": "securepassword",
    "host": "database",
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

def get_api_token():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT token FROM api_keys LIMIT 1")
    token = cur.fetchone()[0]
    cur.close()
    conn.close()
    return token

def check_db_status():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT version();")
        db_version = cur.fetchone()[0]
        cur.close()
        conn.close()
        return {
            "status": "connected",
            "version": db_version
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

    # Database status
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
