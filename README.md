# HashiStack
Die Evolution einer Webanwendung
Dieses Projekt erzählt die Geschichte der Entwicklung einer Webanwendung, beginnend mit einem einfachen statischen Webserver und fortschreitend zu einer modernen, cloud-nativen 3-Tier-App, die auf Kubernetes läuft. Während dieser Evolution werden auch HashiCorp-Tools wie Terraform, Vault, Nomad und Consul integriert, um die Infrastruktur und Verwaltung der Anwendung zu optimieren.

## 1. Einfacher Webserver (Initialer Zustand)
Zu Beginn der Reise erstellen wir einen einfachen Webserver, der nur eine statische HTML-Seite anzeigt. Dies wird als Grundlage genutzt, um das Verständnis für die Funktionsweise eines Webservers und die Darstellung von Systeminformationen zu erweitern.

Technologie: Ein einfacher Webserver, z.B. mit Nginx oder Apache, wird verwendet, um eine HTML-Seite zu liefern.
Ziel: Die Seite soll Informationen über den Servertyp und die Version anzeigen. Zum Beispiel:
Servertyp (z.B. Apache oder Nginx)
Version des Webservers (z.B. Nginx Version)
Diese einfache Anwendung dient als erster Schritt in der Evolution und hilft, die grundlegenden Konzepte des Webserver-Setups und der Versionierung zu verstehen.

Was passiert:

Du baust einen einfachen Webserver, der eine statische HTML-Seite über Nginx oder Apache bereitstellt.
Die HTML-Seite wird mit Informationen über den Servertyp und die Version ausgestattet, um den Benutzer zu informieren.
Ziel: Ein statischer Webserver, der grundlegende Infrastrukturinformationen anzeigt.

## 2. Weiterentwicklung zu einer 3-Tier Applikation (Nächster Schritt)
Der nächste Schritt in der Entwicklung ist die Erweiterung des einfachen Webservers zu einer 3-Tier-Anwendung. Hierbei wird die Webanwendung in drei Hauptkomponenten unterteilt:

Frontend: Webserver, der die Benutzeroberfläche bereitstellt (z.B. HTML, CSS, JavaScript).
Backend: Server, der die Logik verarbeitet und Daten aus einer Datenbank abruft.
Datenbank: Eine persistente Datenquelle, um Daten zu speichern und zu verwalten.
Was passiert:

Du führst einen Backend-Server ein, der mit einer Datenbank verbunden ist.
Die Anwendung kommuniziert über ein API mit dem Backend, um dynamische Daten zu liefern, die aus der Datenbank abgerufen werden.
Ziel: Eine funktionale 3-Tier-Anwendung mit einem separaten Frontend, Backend und einer Datenbank.

## 3. Skalierung der Anwendung
Nachdem die 3-Tier-Anwendung funktioniert, geht es darum, die Skalierbarkeit zu erhöhen. Die Anwendung muss nun in der Lage sein, zusätzliche Instanzen der verschiedenen Komponenten zu starten, um den wachsenden Anforderungen gerecht zu werden. Dies umfasst:

Lastverteilung zwischen mehreren Instanzen des Frontend-Servers.
Horizontal Scaling des Backend-Servers und der Datenbank, je nach Anforderung.
Was passiert:

Du implementierst Load Balancer, um den eingehenden Traffic zwischen mehreren Instanzen zu verteilen.
Auto-Scaling wird konzipiert, um Ressourcen dynamisch je nach Last hinzuzufügen oder zu reduzieren.

## 4. Containerisierung und Cloud-native Architektur
Jetzt, wo die Anwendung skalierbar ist, wird sie für eine Cloud-native Umgebung vorbereitet. Dies bedeutet, dass die Anwendung containerisiert wird, um sie auf einer Plattform wie Kubernetes bereitzustellen. Dabei kommen folgende Technologien zum Einsatz:

Docker für die Containerisierung.
Kubernetes für die Orchestrierung und Verwaltung der Container in einer Cloud-Umgebung.
Was passiert:

Du erstellst Docker-Container für jede der 3 Komponenten (Frontend, Backend, Datenbank).
Du implementierst Kubernetes für das Deployment und das Management der Container.
Du konfigurierst Helm zur Verwaltung der Kubernetes-Ressourcen.

## 5. Integration von HashiCorp-Tools
Parallel zur Entwicklung der Anwendung werden HashiCorp-Tools genutzt, um die Infrastruktur zu verwalten und die Sicherheit zu gewährleisten:

Terraform für Infrastructure-as-Code (IaC), um die gesamte Infrastruktur (z.B. virtuelle Maschinen, Netzwerke, Kubernetes-Cluster) bereitzustellen.
Vault für das Management von Geheimnissen (z.B. API-Schlüssel, Passwörter) und sicheren Zugriff auf sensible Daten.
Nomad für die Verwaltung von Jobs und Workloads in einer dynamischen Umgebung.
Consul für das Service-Discovery und das Management der Microservices-Kommunikation.
Was passiert:

Mit Terraform definierst du die Infrastruktur in Code und stellst diese automatisch bereit.
Vault wird für die sichere Verwaltung von Geheimnissen und Konfigurationsdaten in der Cloud-native Umgebung genutzt.
Nomad und Consul sorgen für das Management von Jobs und das automatische Auffinden von Services in der Kubernetes-Umgebung.

## Fazit
Dieses Projekt zeigt die Reise einer Webanwendung von einem einfachen statischen Webserver bis hin zu einer komplexen, skalierbaren, cloud-nativen Anwendung, die mit modernen DevOps-Praktiken und HashiCorp-Tools verwaltet wird. Durch die Evolution der Anwendung werden verschiedene Technologien und Ansätze wie Containerisierung, Kubernetes, Microservices, Terraform, Vault, Nomad und Consul genutzt, um die Infrastruktur zu automatisieren, zu sichern und zu skalieren.

Die Visualisierung der laufenden Komponenten und deren Status ermöglicht es, die Funktionsweise der Anwendung zu überwachen und sicherzustellen, dass alle Teile der Infrastruktur optimal zusammenarbeiten.
