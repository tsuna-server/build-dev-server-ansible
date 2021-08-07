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

# Links
* [KVM: Testing cloud-init locally using KVM for an Ubuntu cloud image](https://fabianlee.org/2020/02/23/kvm-testing-cloud-init-locally-using-kvm-for-an-ubuntu-cloud-image/)
* [Documentation/CreateSnapshot](https://wiki.qemu.org/Documentation/CreateSnapshot)

