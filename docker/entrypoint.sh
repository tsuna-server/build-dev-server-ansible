#!/usr/bin/env bash

PYTHON_VIRTUALENV_DIRECTORY="venv"
ANSIBLE_DIRECTORY="/opt/ansible"
PHYSICAL_VENV_DIRECTORY="/opt/venv"

log_err() {
    echo "ERROR: $1" >&2
}

main() {
    cd "$ANSIBLE_DIRECTORY" || {
        log_err "Failed to change directory to $ANSIBLE_DIRECTORY"
        return 1
    }

    python3 -m "$PYTHON_VIRTUALENV_DIRECTORY" "${PYTHON_VIRTUALENV_DIRECTORY}/" || {
        log_err "Failed to install python virtual env in $ANSIBLE_DIRECTORY"
        return 1
    }

    # Create symbolic link to cache packages of ansible-galaxy
    ln -s "${ANSIBLE_DIRECTORY}/.ansible" ~/.ansible

    ${ANSIBLE_DIRECTORY}/${PYTHON_VIRTUALENV_DIRECTORY}/bin/pip install --upgrade pip
    #python3 -m pip install --upgrade pip

    #${ANSIBLE_DIRECTORY}/${PYTHON_VIRTUALENV_DIRECTORY}/bin/pip --upgrade pip
    ${ANSIBLE_DIRECTORY}/${PYTHON_VIRTUALENV_DIRECTORY}/bin/pip install -r requirements.txt
    #python3 -m pip install -r requirements.txt

    #/opt/ansible/venv/bin/ansible-galaxy 
    ${ANSIBLE_DIRECTORY}/${PYTHON_VIRTUALENV_DIRECTORY}/bin/ansible-galaxy install -r requirements.yml

    prepare_ssh_key || {
        log_err "Failed to prepare ssh-keys to authenticate"
        return 1
    }

    ${ANSIBLE_DIRECTORY}/${PYTHON_VIRTUALENV_DIRECTORY}/bin/ansible-playbook -l target-host -i production site.yml

    tail -f /dev/null
}

prepare_ssh_key() {
    mkdir ~/.ssh

    [[ ! -f "/private-key" ]] && {
        log_err "private-key file does not existed"
        return 1
    }

    cp /private-key ~/.ssh/private-key || {
        log_err "Failed to copy /private-key to user's ssh config directory"
        return 1
    }

    cat << EOF > ~/.ssh/config
Host *
    ServerAliveInterval 120
    PreferredAuthentications publickey,password,gssapi-with-mic,hostbased,keyboard-interactive

Host target-host
    PreferredAuthentications publickey,password
    HostName target-host
    User root
    IdentityFile ~/.ssh/private-key
EOF

    cp ./private-key ~/.ssh/private-key

    chmod 700 ~/.ssh
    chmod -R 600 ~/.ssh/*
}

main "$@"
