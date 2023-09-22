# ================================
# Build image
# ================================
FROM swift:5.9-jammy as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y\
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release --static-swift-stdlib

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/swift-sample" ./

# ================================
# Run image
# ================================
FROM ubuntu:22.04

# timezone
RUN apt update && apt install -y \
      nano \
      # ca-certificates \
      ## If your app or its dependencies import FoundationNetworking, also install `libcurl4`.
      # libcurl4 \
      ## If your app or its dependencies import FoundationXML, also install `libxml2`.
      # libxml2 \
      tzdata; \
    apt clean

# sshd
RUN mkdir /run/sshd; \
    apt install -y openssh-server; \
    sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
    sed -i 's/^#\(PasswordAuthentication\) .*/\1 no/' /etc/ssh/sshd_config; \
    # sed -i 's/^#\(PubkeyAuthentication\) .*/\1 yes/' /etc/ssh/sshd_config; \
    # sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
    # sed -i 's/^\(LogLevel DEBUG\)/# \1/' /etc/ssh/sshd_config; \
    apt clean;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

# Create an ubuntu user and group with /app as its home directory
# RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app ubuntu
# RUN usermod -aG sudo ubuntu
# RUN echo 'echo "ubuntu:${UBUNTU_PASSWORD}" | chpasswd'

# Install ssh keys for root & ubuntu users
COPY ./key/key.pub /root/.ssh/authorized_keys
# COPY --chown=ubuntu:ubuntu ./key/key.pub /home/ubuntu/.ssh/authorized_keys
RUN chmod 0700 /root/.ssh
# RUN chmod 0700 /home/ubuntu/.ssh
RUN chmod 0600 /root/.ssh/authorized_keys
# RUN chmod 0600 /home/ubuntu/.ssh/authorized_keys

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
# COPY --from=build --chown=ubuntu:ubuntu /staging /app
COPY --from=build /staging /app
RUN ln -s /app/swift-sample /usr/sbin/swift-sample
# RUN chown ubuntu:ubuntu /usr/sbin/swift-sample

ENV TZ Etc/UTC

EXPOSE ${SSH_INTERNAL_PORT}

ENTRYPOINT ["entry_point.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
