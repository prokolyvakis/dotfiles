FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root

# Minimal bootstrap — only what's needed to run ansible + chezmoi
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      curl \
      sudo \
      python3 \
      python3-pip \
      python3-venv \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Ansible
RUN python3 -m pip install --break-system-packages ansible

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# Copy repo into container
COPY . /root/.dotfiles
WORKDIR /root/.dotfiles

# Install Ansible collections
RUN cd ansible && ansible-galaxy collection install -r requirements.yml

# Run Ansible playbook (system provisioning)
RUN cd ansible && ansible-playbook playbook.yml --diff

# Run chezmoi (dotfiles)
RUN chezmoi init --source=home/ && chezmoi apply --source=home/

# Verify: check key files exist
RUN test -f /root/.zshrc && echo "OK: .zshrc" || exit 1
RUN test -f /root/.bashrc && echo "OK: .bashrc" || exit 1
RUN test -f /root/.gitconfig && echo "OK: .gitconfig" || exit 1
RUN test -d /root/.shell && echo "OK: .shell/" || exit 1
RUN test -f /root/.shell/git.sh && echo "OK: .shell/git.sh" || exit 1
RUN test -f /root/.shell/aliases.sh && echo "OK: .shell/aliases.sh" || exit 1
RUN test -f /root/.config/nvim/init.lua && echo "OK: nvim/init.lua" || exit 1

# Verify: zsh is installed and nvim is present
RUN zsh --version
RUN nvim --version | head -1

# Verify: Ansible idempotence — second run should report no changes
RUN cd ansible && ansible-playbook playbook.yml --diff \
    | tee /tmp/idempotence.txt && \
    grep -q 'changed=0' /tmp/idempotence.txt && \
    echo "OK: idempotent" || \
    echo "WARN: not fully idempotent (check output above)"

CMD ["zsh"]
