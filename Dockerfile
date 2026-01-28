FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    ca-certificates curl dpkg bash coreutils \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# teldrive
ADD https://github.com/tgdrive/teldrive/releases/download/1.7.4/teldrive-1.7.4-linux-amd64.tar.gz /tmp/teldrive.tar.gz
RUN tar -xzf /tmp/teldrive.tar.gz -C /usr/local/bin \
 && chmod +x /usr/local/bin/teldrive

# rclone (tgdrive fork)
ADD https://github.com/tgdrive/rclone/releases/download/v1.72.1/rclone-v1.72.1-linux-amd64.deb /tmp/rclone.deb
RUN dpkg -i /tmp/rclone.deb || (apt-get update && apt-get install -f -y && rm -rf /var/lib/apt/lists/*)

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
