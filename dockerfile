FROM debian:12 as downloader

# Install git and git-lfs, clone repo, and pull LFS files in a single layer
RUN apt-get update && apt-get install -y git git-lfs && \
    git lfs install && \
    mkdir /build && \
    cd /build && \
    git clone https://github.com/joubin/printos . && \
    git lfs pull && \
    rm -rf /build/.git

FROM debian:12

# Install all packages and configure everything in a single layer
RUN apt-get update && apt-get install -y \
    vim \
    cups \
    cups-client \
    cups-filters \
    cups-pdf \
    sane \
    sane-utils \
    avahi-daemon \
    dbus \
    dbus-x11 \
    avahi-utils && \
    # Create user and add to group
    useradd -m -s /bin/bash pi && \
    usermod -a -G lpadmin pi && \
    usermod -a -G lpadmin root && \ # Probably not safe, but it works
    # Configure CUPS
    mkdir -p /etc/cups/ssl && \
    chmod 700 /etc/cups/ssl && \
    echo "ServerName /var/run/cups/cups.sock" >> /etc/cups/cupsd.conf && \
    echo "Listen 0.0.0.0:631" >> /etc/cups/cupsd.conf && \
    echo "DefaultAuthType Basic" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
    # Configure SANE
    echo "net" >> /etc/sane.d/net.conf && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy and install the Brother scanner driver from the downloader stage
COPY --from=downloader /build/brscan4-0.4.10-1.i386.deb /br.deb
RUN dpkg -i /br.deb && rm /br.deb

# Expose ports
EXPOSE 631 5353

# Start services
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]