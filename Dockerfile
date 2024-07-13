FROM ubuntu:latest

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

# Create a non-root user
RUN useradd -ms /bin/bash appuser

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

# Set the entrypoint to use the virtual environment
ENTRYPOINT ["/bin/bash", "-c", "source venv/bin/activate && exec \"$@\"", "--"]

# Set the default command to bash
CMD ["bash"]
