# Dockerfile

# --- Stage 1: Builder ---
# Utiliser une image Go officielle
FROM golang:1.23.0 as builder

# Définir le répertoire de travail DANS le conteneur de build
WORKDIR /src

# Copier les fichiers de modules pour utiliser le cache de dépendances Docker
COPY go.mod go.sum ./
RUN go mod download

# Copier TOUT le code source du dépôt local dans le conteneur de build
COPY . .

# Compiler le binaire tesla-http-proxy spécifiquement
# -o /bin/tesla-http-proxy : spécifie le chemin de sortie DANS le conteneur de build
# CGO_ENABLED=0 : Désactive CGO pour un build statique (plus portable)
# -ldflags="-s -w" : Réduit la taille du binaire (optionnel)
# ./cmd/tesla-http-proxy : Chemin vers le package main à compiler
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /bin/tesla-http-proxy ./cmd/tesla-http-proxy

# --- Stage 2: Image Finale ---
# Image finale basée sur Debian (qui contient /bin/sh) ---
FROM debian:stable-slim

# Installer les certificats CA (bonne pratique, souvent nécessaire pour HTTPS sortant, ex: vers GCP)
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail (optionnel mais propre)
WORKDIR /app

# Copier le binaire tesla-http-proxy depuis le stage builder
COPY --from=builder /bin/tesla-http-proxy /usr/local/bin/tesla-http-proxy

# Copier notre script d'entrypoint personnalisé
COPY ./fly/entrypoint.sh /app/entrypoint.sh

# Rendre l'entrypoint exécutable DANS le conteneur
RUN chmod +x /app/entrypoint.sh

# Créer le répertoire pour les secrets à l'avance (évite des problèmes potentiels)
RUN mkdir -p /secrets

# Définir l'entrypoint pour utiliser notre script via le shell
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]

# Exposer le port (documentaire, Fly utilise la section [services])
EXPOSE 443