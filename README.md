[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/CayoM/HashiStack/tree/03-skalierung)

# Skalierung der Anwendung (Scaling)

## Ziel
In diesem Schritt wird die zuvor erstellte **3-Tier-Applikation** skaliert, um mehrere Instanzen des Anwendungstiers bereitzustellen und die Last dynamisch zu verteilen. Dies geschieht unter Verwendung von **HashiCorp-Tools**, insbesondere **Terraform**, **Consul** und **Vault**, um die Skalierung, Service Discovery und das geheime Management zu automatisieren.

## Architektur
```
+-------------+          +----------------+          +----------------+
|  Frontend   | ----->   |    Backend     | ----->   |    Datenbank   |
|  (Nginx+PHP)|          | (Flask API)    |          | (PostgreSQL)   |
+-------------+          +----------------+          +----------------+
       |                        |                        |
       |                        |                        |
       v                        v                        v
  +----------------+       +----------------+       +----------------+
  |  Terraform     |       |    Consul      |       |     Vault      |
  +----------------+       +----------------+       +----------------+
```

## Komponenten

### 1. Frontend (Nginx + PHP)
- Ein Webserver zeigt dynamische Informationen über die laufenden Backend-Instanzen an.
- Die API-Anfragen werden über die Consul-Service-URL (`backend.service.consul`) an das Backend weitergeleitet.

### 2. Backend (Flask API)
- Mehrere Instanzen des Backends werden über **Terraform** bereitgestellt.
- Jede Instanz startet einen **Consul Agent**, der sich beim zentralen Consul-Server registriert.
- Die Registrierung erfolgt automatisch zur Ermöglichung der Service Discovery.
- Consul stellt eine einfache Form des Loadbalancing bereit (DNS Round-Robin).
- Die API greift über ein geteiltes Volume auf geheime Zugangsdaten zu, die von einem Vault Agent bereitgestellt werden. So kann das Backend sensible Daten verwenden, **ohne den Anwendungscode verändern zu müssen**.

### 3. Datenbank (PostgreSQL)
- PostgreSQL dient als zentrale persistente Datenbank.
- Vault verwaltet sicher die Zugangsdaten.

### 4. HashiCorp-Integration
- **Terraform** provisioniert mehrere Instanzen des Backends und vernetzt sie mit Consul.
- **Consul** dient zur automatisierten Service-Erkennung und Health Checks.
- **Vault** verwaltet sensible Daten. Ein **Vault Agent** läuft in einem separaten Container und speichert die Secrets in einem **shared Volume**, auf das das Backend zugreift.

## Implementierung

### 1. Skalierung der Backend-Instanzen
Terraform wird verwendet, um mehrere Instanzen des Backends bereitzustellen:

```bash
terraform apply -auto-approve
```

Die Anzahl der Instanzen kann über Variablen gesteuert werden (z. B. `backend_instance_count`).

### 2. Service Discovery mit Consul
Jede Instanz des Backends startet einen lokalen **Consul Agent**, der sich automatisch beim Consul-Server registriert.  
Anfragen werden über die Adresse `backend.service.consul` verteilt. Consul nutzt dabei **DNS-basiertes Loadbalancing (Round-Robin)** und filtert ungesunde Instanzen heraus.

```bash
consul catalog services
```

### 3. Geheimnisverwaltung mit Vault
Ein **Vault Agent** läuft in einem separaten Container neben dem Backend.  
Er authentifiziert sich bei Vault, holt die benötigten Secrets und speichert sie als Dateien in einem **shared Volume**, das vom Backend eingehängt wird.  
Dadurch kann das Backend auf sensible Informationen zugreifen, **ohne Vault direkt zu kennen oder Code anzupassen**.

Beispiel zum Setzen eines Secrets:
```bash
vault kv put secret/db password="supersecret"
```

### 4. Frontend-Anzeige aktualisieren
Das Frontend zeigt dynamisch:
- Anzahl aktiver Backend-Instanzen (ermittelt durch Anfragen an das Backend)
- Informationen über Version und Status

## Fazit

Mit dieser Skalierung kann die Anwendung dynamisch wachsen, um Lastspitzen abzufangen. Die Kombination aus **Terraform**, **Consul** und **Vault** sorgt für eine automatisierte, sichere und robuste Infrastruktur.  
Consul bietet dabei eine einfache, aber effektive Möglichkeit zur Lastverteilung über DNS-Service-Discovery.  
Vault ermöglicht eine sichere Bereitstellung von Geheimnissen – transparent und ohne Codeänderung durch den Vault Agent.
