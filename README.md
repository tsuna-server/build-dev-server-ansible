# Build development server

# Usage

```
$ . ./venv/bin/activate
(vnev) $ pip install -r requirements.txt
```

Install `ansible-galaxy` requirements.

```
(venv) $ ansible-galaxy install -r requirements.yml
```


`ansible-playbook` can run with checking mode by adding `--check` option like below.

```
(venv) $ ansible-playbook -i production -l [hostname or group name] --check sites.yml
// Some options might be needed like `--ask-pass`, `--become` or `--ask-become-pass` depending on your environment.
```

If NO errors were reported then you can run Ansible without the option `--check`.

```
(venv) $ ansible-playbook -l localhost site.yml
```

## Usage with docker
You can run the ansible if you can not prepare the environment to run ansible on your machine.
You have to copy SSH private key (in this example, that named `private-key`) that is used to login the host into the `build-dev-server-ansible` directory.

```
$ git clone https://github.com/tsuna-server/build-dev-server-ansible.git
$ cd build-dev-server-ansible
$ cp /path/to/private-key ./private-key
$ docker run --rm \
    --volume ${PWD}:/opt/ansible \
    --add-host target-host:x.x.x.x \
    tsutomu/build-dev-server-ansible
```

* `--volume /path/to/private-key:/private-key` is the option to specify the private key that can log in to the node that you want to build the environment to.
* `--add-host target-host:x.x.x.x` is the option to specify the host name and ip which you want to build the environment to.

# Links
* [KVM: Testing cloud-init locally using KVM for an Ubuntu cloud image](https://fabianlee.org/2020/02/23/kvm-testing-cloud-init-locally-using-kvm-for-an-ubuntu-cloud-image/)
* [Documentation/CreateSnapshot](https://wiki.qemu.org/Documentation/CreateSnapshot)

