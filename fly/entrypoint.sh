#!/bin/sh
set -e # Quitte immédiatement si une commande échoue

# Chemins où écrire les fichiers depuis les secrets
CMD_KEY_FILE_PATH="/secrets/fleet-key.pem"
TLS_CERT_FILE_PATH="/secrets/tls-cert.pem"
TLS_KEY_FILE_PATH="/secrets/tls-key.pem"

# --- Vérification et écriture de la Clé de Commande ---
if [ -z "$FLEET_KEY_PEM" ]; then
  echo "Erreur: Le secret FLEET_KEY_PEM n'est pas défini."
  exit 1
fi
mkdir -p "$(dirname "$CMD_KEY_FILE_PATH")"
printf '%s' "$FLEET_KEY_PEM" > "$CMD_KEY_FILE_PATH"
if [ $? -ne 0 ]; then echo "Erreur: Écriture de $CMD_KEY_FILE_PATH échouée"; exit 1; fi
chmod 600 "$CMD_KEY_FILE_PATH"

# --- Vérification et écriture du Certificat TLS ---
if [ -z "$TLS_CERT_PEM" ]; then
  echo "Erreur: Le secret TLS_CERT_PEM n'est pas défini."
  exit 1
fi
mkdir -p "$(dirname "$TLS_CERT_FILE_PATH")" # Au cas où ce serait un chemin différent
printf '%s' "$TLS_CERT_PEM" > "$TLS_CERT_FILE_PATH"
if [ $? -ne 0 ]; then echo "Erreur: Écriture de $TLS_CERT_FILE_PATH échouée"; exit 1; fi

# --- Vérification et écriture de la Clé Privée TLS ---
if [ -z "$TLS_KEY_PEM" ]; then
  echo "Erreur: Le secret TLS_KEY_PEM n'est pas défini."
  exit 1
fi
mkdir -p "$(dirname "$TLS_KEY_FILE_PATH")" # Au cas où ce serait un chemin différent
printf '%s' "$TLS_KEY_PEM" > "$TLS_KEY_FILE_PATH"
if [ $? -ne 0 ]; then echo "Erreur: Écriture de $TLS_KEY_FILE_PATH échouée"; exit 1; fi
chmod 600 "$TLS_KEY_FILE_PATH"

# --- Vérification finale de l'existence des fichiers ---
if ! [ -f "$CMD_KEY_FILE_PATH" ]; then echo "ERREUR FATALE: $CMD_KEY_FILE_PATH non trouvé!"; exit 1; fi
if ! [ -f "$TLS_CERT_FILE_PATH" ]; then echo "ERREUR FATALE: $TLS_CERT_FILE_PATH non trouvé!"; exit 1; fi
if ! [ -f "$TLS_KEY_FILE_PATH" ]; then echo "ERREUR FATALE: $TLS_KEY_FILE_PATH non trouvé!"; exit 1; fi

echo "Secrets écrits. Démarrage de tesla-http-proxy en mode HTTPS..."

# Exécute tesla-http-proxy en lui passant les fichiers de clé et certificats
# Le port est défini par la variable d'environnement ou par défaut 443 si TLS activé
# Le host est défini par la variable d'environnement
exec tesla-http-proxy \
    -key-file "$CMD_KEY_FILE_PATH" \
    -cert "$TLS_CERT_FILE_PATH" \
    -tls-key "$TLS_KEY_FILE_PATH"