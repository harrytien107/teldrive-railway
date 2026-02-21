FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    ca-certificates curl dpkg bash coreutils jq \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# teldrive — auto-fetch latest release
RUN set -e && \
    TELDRIVE_URL=$(curl -fsSL https://api.github.com/repos/tgdrive/teldrive/releases/latest \
      | jq -r '.assets[] | select(.name | test("linux-amd64\\.tar\\.gz$")) | .browser_download_url') && \
    echo "📦 Downloading teldrive: $TELDRIVE_URL" && \
    curl -fsSL "$TELDRIVE_URL" -o /tmp/teldrive.tar.gz && \
    tar -xzf /tmp/teldrive.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/teldrive && \
    rm /tmp/teldrive.tar.gz

# rclone (tgdrive fork) — auto-fetch latest release
RUN set -e && \
    RCLONE_URL=$(curl -fsSL https://api.github.com/repos/tgdrive/rclone/releases/latest \
      | jq -r '.assets[] | select(.name | test("linux-amd64\\.deb$")) | .browser_download_url') && \
    echo "📦 Downloading rclone: $RCLONE_URL" && \
    curl -fsSL "$RCLONE_URL" -o /tmp/rclone.deb && \
    (dpkg -i /tmp/rclone.deb || (apt-get update && apt-get install -f -y && rm -rf /var/lib/apt/lists/*)) && \
    rm /tmp/rclone.deb

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
