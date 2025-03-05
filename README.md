

# Skalierung der Anwendung (Scaling)

## Ziel
In diesem Schritt wird die zuvor erstellte **3-Tier-Applikation** skaliert, um mehrere Instanzen des Anwendungstiers bereitzustellen und die Last dynamisch zu verteilen. Dies geschieht unter Verwendung von **HashiCorp-Tools**, um die Skalierung, Service Discovery und das geheime Management zu automatisieren.

## Architektur
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

## Komponenten
1. **Frontend (Nginx + PHP)**
   - Der Webserver zeigt Informationen über die laufenden Instanzen an.
   - Die API-Anfragen werden über einen Load Balancer an das Backend weitergeleitet.

2. **Backend (Flask API)**
   - Mehrere Instanzen der API laufen parallel und registrieren sich bei **Consul**.
   - Anfragen werden über einen Load Balancer verteilt.

3. **Datenbank (PostgreSQL)**
   - Wird von der Anwendung für persistente Speicherung verwendet.
   - Vault verwaltet sicher die Zugangsdaten.

4. **HashiCorp-Integration**
   - **Terraform** automatisiert die Bereitstellung der Umgebung.
   - **Consul** dient zur Service-Erkennung und stellt Health Checks bereit.
   - **Nomad** orchestriert die Anwendungs- und Backend-Instanzen.
   - **Vault** verwaltet sensible Konfigurationsdaten.

## Implementierung
### 1. Skalierung der Backend-Instanzen
Nomad wird verwendet, um die Backend-Instanzen zu verwalten und dynamisch zu skalieren.

```bash
nomad run backend.nomad
```

Das Backend registriert sich automatisch in Consul. Die aktuelle Anzahl laufender Instanzen wird auf der Frontend-Seite angezeigt.

### 2. Load Balancer einrichten
Nomad und Consul arbeiten zusammen, um eine dynamische Lastverteilung über die Backend-Instanzen zu ermöglichen.

**Beispiel für eine Nomad-Job-Konfiguration:**
```hcl
task "flask" {
  driver = "docker"
  config {
    image = "myapp:latest"
    ports = ["http"]
  }
  service {
    name = "backend"
    tags = ["api"]
    port = "http"
    check {
      type     = "http"
      path     = "/health"
      interval = "10s"
      timeout  = "2s"
    }
  }
}
```

### 3. Konsistente Service-Erkennung mit Consul
Jede neue Instanz registriert sich automatisch bei Consul, wodurch sie in die Lastverteilung aufgenommen wird.

```bash
consul catalog services
```

### 4. Geheimnisverwaltung mit Vault
Vault speichert sensible Informationen wie API-Keys oder Datenbank-Zugangsdaten.

**Beispiel:**
```bash
vault kv put secret/db password="supersecret"
```

### 5. Frontend-Anzeige aktualisieren
Das Frontend zeigt dynamisch:
- Anzahl aktiver Backend-Instanzen
- Status des Load Balancers
- Informationen aus Consul

## Fazit
Mit dieser Skalierung kann die Anwendung dynamisch wachsen, um Lastspitzen abzufangen. Die Kombination aus **Nomad, Consul und Vault** sorgt für eine automatisierte, sichere und hochverfügbare Infrastruktur.

