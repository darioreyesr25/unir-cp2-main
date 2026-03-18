#!/bin/sh
set -eu

# Script para destruir y volver a crear la infraestructura desde cero.
# Uso (WSL / Linux):
#   ./redeploy.sh
# Opcional: exportar SSH_PUBKEY con el contenido de tu clave pública si quieres usar otra.

cd "$(dirname "$0")"

# Preferir variable de entorno si está definida.
if [ -z "${SSH_PUBKEY:-}" ]; then
  if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    SSH_PUBKEY=$(cat "$HOME/.ssh/id_rsa.pub")
  elif [ -f "/mnt/host/c/Users/dario/.ssh/id_rsa.pub" ]; then
    # Fallback for WSL donde la clave está en el home de Windows.
    SSH_PUBKEY=$(cat "/mnt/host/c/Users/dario/.ssh/id_rsa.pub")
  else
    echo "ERROR: No se encontró ~/.ssh/id_rsa.pub ni /mnt/host/c/Users/dario/.ssh/id_rsa.pub, y no se ha definido SSH_PUBKEY." >&2
    echo "Define SSH_PUBKEY como el contenido de tu clave pública, por ejemplo:"
    echo "  export SSH_PUBKEY=\"$(cat ~/.ssh/id_rsa.pub 2>/dev/null)\"" 2>/dev/null || true
    exit 1
  fi
fi

terraform destroy --auto-approve -var "ssh_public_key=${SSH_PUBKEY}"
terraform apply --auto-approve -var "ssh_public_key=${SSH_PUBKEY}"
