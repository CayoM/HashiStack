# HashiStack
Die Evolution einer Webanwendung
Dieses Projekt erzählt die Geschichte der Entwicklung einer Webanwendung, beginnend mit einem einfachen statischen Webserver und fortschreitend zu einer modernen, 3-Tier-App. Während dieser Evolution werden auch HashiCorp-Tools wie Terraform, Vault und Consul integriert, um die Infrastruktur und Verwaltung der Anwendung zu optimieren.

## 1. Einfacher Webserver (Initialer Zustand)
Zu Beginn der Reise erstellen wir einen einfachen Webserver, der nur eine statische HTML-Seite anzeigt. Dies wird als Grundlage genutzt, um das Verständnis für die Funktionsweise eines Webservers und die Darstellung von Systeminformationen zu erweitern.

Technologie: Ein einfacher Webserver mit Nginx wird verwendet, um eine HTML-Seite zu liefern.
Ziel: Die Seite soll Informationen über den Servertyp und die Version anzeigen. Zum Beispiel:
Servertyp (Nginx)
Version des Webservers (Nginx Version)
Diese einfache Anwendung dient als erster Schritt in der Evolution und hilft, die grundlegenden Konzepte des Webserver-Setups und der Versionierung zu verstehen.

Was passiert:

Du baust einen einfachen Webserver, der eine statische HTML-Seite über Nginx bereitstellt.
Die HTML-Seite wird mit Informationen über den Servertyp und die Version ausgestattet, um den Benutzer zu informieren.
Ziel: Ein statischer Webserver, der grundlegende Infrastrukturinformationen anzeigt.

## 2. Weiterentwicklung zu einer 3-Tier Applikation (Nächster Schritt)
Der nächste Schritt in der Entwicklung ist die Erweiterung des einfachen Webservers zu einer 3-Tier-Anwendung. Hierbei wird die Webanwendung in drei Hauptkomponenten unterteilt:

Frontend: Webserver, der die Benutzeroberfläche bereitstellt (HTML).
Backend: Server, der die Logik verarbeitet.
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

## 5. Integration von HashiCorp-Tools
Parallel zur Entwicklung der Anwendung werden HashiCorp-Tools genutzt, um die Infrastruktur zu verwalten und die Sicherheit zu gewährleisten:

Terraform für Infrastructure-as-Code (IaC), um die gesamte Infrastruktur (z.B. virtuelle Maschinen, Netzwerke, Kubernetes-Cluster, Docker-Container, Cloud-Services, etc) bereitzustellen.
Vault für das Management von Geheimnissen (z.B. API-Schlüssel, Passwörter) und sicheren Zugriff auf sensible Daten.
Consul für das Service-Discovery und das Management der Services-Kommunikation.

## Fazit
Dieses Projekt zeigt die Reise einer Webanwendung von einem einfachen statischen Webserver bis hin zu einer komplexen, skalierbaren Anwendung, die mit modernen DevOps-Praktiken und HashiCorp-Tools verwaltet wird. Durch die Evolution der Anwendung werden verschiedene Technologien und Ansätze genutzt, um die Infrastruktur zu automatisieren, zu sichern und zu skalieren.

Die Visualisierung der laufenden Komponenten und deren Status ermöglicht es, die Funktionsweise der Anwendung zu überwachen und sicherzustellen, dass alle Teile der Infrastruktur optimal zusammenarbeiten.
