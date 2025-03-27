[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/CayoM/HashiStack/tree/02-weiter-entwicklung-3tier)

# Weiterentwicklung zu einer 3-Tier Applikation

## Ziel
In diesem Schritt wird die zuvor erstellte einfache Webserver-Applikation in eine **3-Tier-Architektur** umgebaut. Die neue Struktur besteht aus:

1. **Frontend:** Ein Nginx-Webserver mit PHP, der API-Daten vom Backend anzeigt.
2. **Backend:** Eine API in Python (Flask), die Anfragen verarbeitet und mit der Datenbank kommuniziert.
3. **Datenbank:** Eine relationale Datenbank (PostgreSQL), die persistente Daten speichert.

Zusätzlich werden **HashiCorp-Tools** integriert, um Infrastruktur und Secrets-Management zu automatisieren:
- **Terraform:** Automatisiert die Bereitstellung der Umgebung.
- **Vault:** Verwalten von Geheimnissen (z. B. API-Keys, Datenbank-Zugangsdaten).

## Architektur
```
+-------------+          +----------------+          +----------------+
|  Frontend   | ----->   |    Backend     | ----->   |    Datenbank   |
|  (Nginx+PHP)|          | (Flask API)    |          | (PostgreSQL)   |
+-------------+          +----------------+          +----------------+
```

Mit HashiCorp:
```
+-------------+         +----------------+         +----------------+
|  Frontend   | ----->  |    Backend     | ----->  |    Datenbank   |
|  (Nginx+PHP)|         | (Flask API)    |         | (PostgreSQL)   |
+-------------+         +----------------+         +----------------+
       |                        |                        |
       |                        |                        |
       v                        v                        v
  +----------------+     +----------------+       +----------------+
  |  Terraform     |     |   Terraform    |       |   Terraform    |
  |                |     |  Vault-Agent   |       |     Vault      |
  +----------------+     +----------------+       +----------------+
```

## Setup der Umgebung

### 1. Frontend (Nginx + PHP)
- Ein **Nginx-Container** wird erstellt, der statische Dateien ausliefert und API-Anfragen an das Backend stellt.
- Ein PHP-Skript (`index.php`) ruft Daten vom Backend ab und zeigt sie dynamisch an.
- Zeigt Informationen über die laufenden Komponenten an (z. B. Version, Instanzen).

### 2. Backend (Flask API)
- Eine einfache API in **Python (Flask)** verarbeitet Anfragen und gibt Daten zurück.
- Der Endpunkt `/status` liefert:
  - Server-Informationen (z. B. Hostname, IP-Adresse, Laufzeit)
- Liest geheime Zugangsdaten aus **Vault** (z. B. API-Token).
- Bei der Variante mit HashiCorp-Integration wird ein **Vault Agent** im Backend-Container verwendet, um automatisch ein Vault-Token zu erhalten und auf die geheimen Werte (z. B. API-Token in der Datenbank) zuzugreifen.

### 3. Datenbank (PostgreSQL)
- **PostgreSQL** wird als persistente Datenbank eingesetzt.
- Terraform wird verwendet, um eine Datenbank-Instanz bereitzustellen.
- Vault verwaltet sicher die Zugangsdaten.

### 4. Integration von HashiCorp-Tools
- **Terraform** automatisiert das Erstellen der Umgebung.
- **Vault** schützt geheime Zugangsdaten.

## Deployment mit Terraform

Terraform wird verwendet, um die Infrastruktur für die 3-Tier-App bereitzustellen:

```bash
terraform init
terraform apply -auto-approve
```

## Fazit

Diese Version der Anwendung ist nun **modular aufgebaut** und verwendet moderne **DevOps-Methoden** für eine flexible Bereitstellung.  
Die HashiCorp-Tools unterstützen dabei die Automatisierung und sichere Verwaltung der Infrastruktur.
