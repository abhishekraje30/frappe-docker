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
    && apt clean

# Install nvm, Node.js 18, npm, and Yarn
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install 18 && \
    nvm use 18 && \
    npm install -g npm@latest yarn

# Add these environment variables to ensure nvm works correctly
ENV NODE_VERSION=18
RUN echo "source $NVM_DIR/nvm.sh && nvm use $NODE_VERSION" >> /root/.bashrc

# Create a directory for the virtual environment
WORKDIR /app

# Create a virtual environment
RUN python3 -m venv venv

# Activate the virtual environment and install frappe-bench
RUN /bin/bash -c "source venv/bin/activate && pip install frappe-bench"

# Set the entrypoint to use the virtual environment
ENTRYPOINT ["/bin/bash", "-c", "source venv/bin/activate && exec \"$@\"", "--"]

# Set the default command to bash
CMD ["bash"]
