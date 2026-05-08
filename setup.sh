#!/bin/bash
set -euo pipefail

[ "$EUID" -ne 0 ] && { echo "Run as root (sudo)." >&2; exit 1; }
pkgs=(nginx git build-essential)

echo "[*] Update des Systems"
apt-get update -y

is_installed(){ dpkg -s "$1" &>/dev/null; }

for pkg in "${pkgs[@]}"; do
    if is_installed "$pkg"; then
        printf "[*] %s bereits installiert\n" "$pkg"
    else
        printf "[*] Installiere %s...\n" "$pkg"
        case "$pkg" in
            nginx) apt-get install -y nginx ;;
            git) apt-get install -y git ;;
            build-essential) apt-get install -y build-essential ;;
            *) apt-get install -y "$pkg" ;;
        esac
    fi
done

echo "[*] Fertig."
echo "[*] reze-fetch bauen"
if [ ! -d /opt/reze-fetch ]; then
  git clone https://github.com/deadprocess/reze-fetch.git /opt/reze-fetch
fi

cat << 'EOF' > /opt/reze-fetch/reze-fetch-linux.c
#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *f;
    char buffer[256];

    printf("REZE-FETCH (Linux)\n\n");

    f = fopen("/etc/hostname", "r");
    if (f != NULL) {
        fgets(buffer, sizeof(buffer), f);
        printf("Hostname: %s", buffer);
        fclose(f);
    }

    f = fopen("/proc/version", "r");
    if (f != NULL) {
        fgets(buffer, sizeof(buffer), f);
        printf("Kernel: %s", buffer);
        fclose(f);
    }

    return 0;
}
EOF

gcc /opt/reze-fetch/reze-fetch-linux.c -o /usr/local/bin/reze-fetch

echo "[*] Service installieren"
cp services/reze-fetch.service /etc/systemd/system/

systemctl daemon-reexec
systemctl enable reze-fetch
systemctl restart reze-fetch

echo "[*] nginx sicherstellen"
systemctl enable nginx
systemctl restart nginx

echo "[✓] Setup fertig"
