FROM ubuntu:24.10

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt install -y \
    curl \
    sudo \
    git \
    python-dev-is-python3 \
    python3-pip \
    python3-venv \
    redis-server \
    mariadb-server \
    mariadb-client \
    xvfb \
    libfontconfig \
    cron \
    nginx \
    && apt clean

# Create new user with home directory, improve Docker compatibility with UID/GID 1001,
# add user to sudo group, allow passwordless sudo, switch to that user
RUN useradd --no-log-init -r -m -u 1001 -g sudo -G sudo appuser \
    && echo "appuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


# Switch to the non-root user
USER appuser

# Set up the home directory for appuser
WORKDIR /home/appuser

# Install nvm, Node.js 18, npm, and Yarn for appuser
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="/home/appuser/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install 18 && \
    nvm use 18 && \
    npm install -g npm@latest yarn

# Add nvm and node to PATH for appuser
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /home/appuser/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/appuser/.bashrc && \
    echo 'nvm use 18' >> /home/appuser/.bashrc

# Create a directory for the virtual environment
WORKDIR /home/appuser/app

# Create a virtual environment
RUN python3 -m venv venv

# Activate the virtual environment and install frappe-bench
RUN /bin/bash -c "source venv/bin/activate && pip install frappe-bench"

EXPOSE 8000-8005 9000-9005 6787

# Set the entrypoint to use the virtual environment
ENTRYPOINT ["/bin/bash", "-c", "source venv/bin/activate && exec \"$@\"", "--"]

# Set the default command to bash
CMD ["bash"]
