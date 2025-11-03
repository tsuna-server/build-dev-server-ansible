#!/usr/bin/env bash

main() {
    # Prepare .ssh directory
    mkdir -p ~/.ssh || {
        echo "Failed to create ~/.ssh directory"
        return 1
    }
    chmod 700 ~/.ssh || {
        echo "Failed to set permissions on ~/.ssh directory"
        return 1
    }

    # Create development ssh key pair with ed25519 if it doesn't exist
    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t ed25519 -f ~/.ssh/id_rsa -N "" -C "dev_key" || {
            echo "Failed to generate SSH key pair"
            return 1
        }
    fi

    # Create development ssh config if it doesn't exist.
    # That allows any host and use the created key to authenticate with user root.
    if [ ! -f ~/.ssh/config ]; then
        cat << EOF > ~/.ssh/config
Host *
    ServerAliveInterval 120
    PreferredAuthentications publickey,password,gssapi-with-mic,hostbased,keyboard-interactive
    User root
    IdentityFile ~/.ssh/private-key
EOF

        if [ $? -ne 0 ]; then
            echo "Failed to create SSH config file"
            return 1
        fi

        chmod 600 ~/.ssh/config || {
            echo "Failed to set permissions on SSH config file"
            return 1
        }
    fi

    return 0
}

main "$@"
