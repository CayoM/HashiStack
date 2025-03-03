# Weiterentwicklung zu einer 3-Tier Applikation

## Ziel
In diesem Schritt wird die zuvor erstellte einfache Webserver-Applikation in eine **3-Tier-Architektur** umgebaut. Die neue Struktur besteht aus:

1. **Frontend:** Ein Nginx-Webserver mit PHP, der API-Daten vom Backend anzeigt.
2. **Backend:** Eine API in Python (Flask), die Anfragen verarbeitet und mit der Datenbank kommuniziert.
3. **Datenbank:** Eine relationale Datenbank (PostgreSQL), die persistente Daten speichert.

Zusätzlich werden **HashiCorp-Tools** integriert, um Infrastruktur und Service-Management zu automatisieren:
- **Terraform:** Automatisiert die Bereitstellung der Umgebung.
- **Vault:** Verwalten von Geheimnissen (z. B. API-Keys, Datenbank-Zugangsdaten).
- **Consul:** Service Discovery und Health Checks für die Anwendung.
- **Nomad:** Orchestrierung der Anwendungskomponenten.

## Architektur
```
+-------------+          +----------------+          +----------------+
|  Frontend   | ----->  |    Backend     | ----->  |    Datenbank   |
|  (Nginx+PHP)|         | (Flask API)    |         | (PostgreSQL)   |
+-------------+          +----------------+          +----------------+
```

Mit HashiCorp:
```
+-------------+          +----------------+          +----------------+
|  Frontend   | ----->  |    Backend     | ----->  |    Datenbank   |
|  (Nginx+PHP)|         | (Flask API)    |         | (PostgreSQL)   |
+-------------+          +----------------+          +----------------+
       |                        |                        |
       |                        |                        |
       v                        v                        v
  +----------------+    +----------------+    +----------------+
  | Consul        |    | Nomad         |    | Vault         |
  +----------------+    +----------------+    +----------------+
```

## Setup der Umgebung

### 1. Frontend (Nginx + PHP)
- Ein **Nginx-Container** wird erstellt, der statische Dateien ausliefert und API-Anfragen an das Backend stellt.
- PHP-Skript (`index.php`) ruft Daten vom Backend ab und zeigt sie dynamisch an.
- Zeigt dynamische Informationen über die laufenden Komponenten an (z. B. Version, Instanzen).

### 2. Backend (Flask API)
- Eine einfache API in **Python (Flask)** verarbeitet Anfragen und gibt Daten zurück.
- Endpunkt `/status` liefert:
  - Server-Informationen (z. B. Hostname, IP-Adresse, Laufzeit)
  - Anzahl der Backend-Instanzen
- Registriert sich automatisch in **Consul** für Service Discovery.
- Liest geheime Zugangsdaten aus **Vault** (z. B. DB-Passwort).

### 3. Datenbank (PostgreSQL)
- **PostgreSQL** wird als persistente Datenbank eingesetzt.
- Terraform wird verwendet, um eine Datenbank-Instanz bereitzustellen.
- Vault verwaltet sicher die Zugangsdaten.

### 4. Integration von HashiCorp-Tools
- **Terraform** automatisiert das Erstellen der Umgebung.
- **Vault** schützt geheime Zugangsdaten.
- **Consul** ermöglicht Service Discovery und Health Checks.
- **Nomad** orchestriert die Container.

## Deployment mit Terraform

Terraform wird verwendet, um die Infrastruktur für die 3-Tier-App bereitzustellen.

```bash
terraform init
terraform apply -auto-approve
```

## Skalierung

Nomad verwaltet die Skalierung des Backends und der Datenbank. Die Anzahl der Instanzen kann in **Nomad Jobs** definiert werden.

```bash
nomad run backend.nomad
nomad run database.nomad
```

## Fazit
Diese Version der Anwendung ist nun **skalierbar**, **modular** und verwendet moderne DevOps-Methoden für eine flexible Bereitstellung. HashiCorp-Tools helfen bei der Automatisierung und Verwaltung der Infrastruktur.

