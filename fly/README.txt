# Initialisation du projet sans déployer
fly launch --no-deploy --copy-config --name tesla-http-proxy

# Ajout des secrets
fly secrets set FLEET_KEY_PEM="$(cat fleet-key.pem)" --app tesla-http-proxy
fly secrets set TLS_CERT_PEM="$(cat tls-cert.pem)" --app tesla-http-proxy
fly secrets set TLS_KEY_PEM="$(cat tls-key.pem)" --app tesla-http-proxy
fly secrets set PROXY_INTERNAL_SECRET="$(cat proxy-internal-secret.txt)" --app tesla-http-proxy

# Pour avoir une adresse IPV4 dédiée
fly ips allocate-v4 --app=tesla-http-proxy

# Déploiement
fly deploy

# Pour reboot les machines
fly apps restart tesla-http-proxy

# Pour n'avoir qu'une seule machine
fly scale count 1