FROM debian:12

# Install vim
RUN apt-get update && apt-get install -y vim curl net-tools wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install CUPS and related packages
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    cups-filters \
    cups-pdf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install SANE and related packages
RUN apt-get update && apt-get install -y \
    sane \
    sane-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Avahi and related packages
RUN apt-get update && apt-get install -y \
    avahi-daemon \
    avahi-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install DBus and related packages
RUN apt-get update && apt-get install -y \
    dbus \
    dbus-x11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install 32-bit compatibility libraries
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    lib32z1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create and configure user
RUN useradd -m -s /bin/bash pi && \
    usermod -a -G lpadmin pi && \
    usermod -a -G lpadmin root

# Configure CUPS
RUN mkdir -p /etc/cups/ssl && \
    chmod 700 /etc/cups/ssl && \
    echo "ServerName /var/run/cups/cups.sock" >> /etc/cups/cupsd.conf && \
    echo "Listen 0.0.0.0:631" >> /etc/cups/cupsd.conf && \
    echo "DefaultAuthType Basic" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# Configure SANE
RUN echo "net" >> /etc/sane.d/net.conf

# Copy and install the Brother scanner driver
ADD brscan4-0.4.10-1.i386.deb /br.deb
RUN dpkg -i /br.deb && rm /br.deb

# Install Brother printer driver
ADD linux-brprinter-installer-2.2.4-1 /usr/local/bin/
RUN chmod +x /usr/local/bin/linux-brprinter-installer-2.2.4-1 && \
    /usr/local/bin/linux-brprinter-installer-2.2.4-1 && \
    rm /usr/local/bin/linux-brprinter-installer-2.2.4-1

# Expose ports
EXPOSE 631 5353

# Start services
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]