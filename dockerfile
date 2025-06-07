FROM debian:12

# Install required packages
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    cups-filters \
    cups-pdf \
    sane \
    sane-utils \
    avahi-daemon \
    dbus \
    dbus-x11 \
    avahi-utils

# Copy and install the Brother scanner driver
COPY brscan4-0.4.10-1.i386.deb /br.deb
RUN dpkg -i /br.deb && \
    rm /br.deb

# Create pi user
RUN useradd -m -s /bin/bash pi

# Add pi user to lpadmin group
RUN usermod -a -G lpadmin pi

# Configure CUPS
RUN mkdir -p /etc/cups/ssl && \
    chmod 700 /etc/cups/ssl && \
    echo "ServerName /var/run/cups/cups.sock" >> /etc/cups/cupsd.conf && \
    echo "Listen 0.0.0.0:631" >> /etc/cups/cupsd.conf && \
    echo "DefaultAuthType Basic" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# Configure SANE
RUN echo "net" >> /etc/sane.d/net.conf

# Expose ports
EXPOSE 631 5353

# Start services
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]