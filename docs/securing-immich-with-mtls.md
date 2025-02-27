# Securing Immich with mTLS using Caddy

Immich supports using a custom client certificate on both web and mobile apps, so it's one of the easiest and safest ways to limit access to only clients of your choice.

## Caddy docker-compose.yml

```yaml
version: "3.7"

services:
  caddy:
    image: caddy:2
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    ports:
      - "6443:443"
      - "6443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:Z
      - ./site:/srv:Z
      - ./data:/data:Z
      - ./config:/config:Z
```

## Authenticating with mutual TLS

### Generate your client certificate

This is a basic way to generate a certificate for a user. If it's only you using your own homelab, then you'll just need to make one certificate.

This certificate will last for ~10 years (although of course you can revoke it at any time by deleting it from Caddy's key store).

```bash
#!/bin/bash

mkdir -p certs

# Generate CA certificates
openssl genrsa -out certs/client-ca.key 4096
openssl req -new -x509 -nodes -days 3600 -key certs/client-ca.key -out certs/client-ca.crt

# Generate a certificate signing request
openssl req -newkey rsa:4096 -nodes -keyout certs/client.key -out certs/client.req

# Have the CA sign the certificate requests and output the certificates.
openssl x509 -req -in certs/client.req -days 3600 -CA certs/client-ca.crt -CAkey certs/client-ca.key -set_serial 01 -out certs/client.crt

echo
echo "Please enter a STRONG password. Many clients *require* a password for you to be able to import the certificate, and you want to protect it."
echo

# Convert the cerificate to PKCS12 format (for import into browser)
openssl pkcs12 -export -out certs/client.pfx -inkey certs/client.key -in certs/client.crt

# Clean up
rm certs/client.req
```

## Configure Caddyfile

```Caddyfile
https://immich.mydomain.com {
    tls {
        client_auth {
            mode require_and_verify
            trusted_ca_cert_file /data/client_certs/client.crt
        }
    }
    reverse_proxy internal_server.lan:2283
}
```
