# Build development server

# Usage

```
$ . ./venv/bin/activate
(vnev) $ pip -r requirements.txt
```

`ansible-playbook` can run with checking mode by adding `--check` option like below.

```
(venv) $ ansible-playbook -i production -l [hostname or group name] --check sites.yml
// Some options might be needed like `--ask-pass`, `--become` or `--ask-become-pass` depending on your environment.
```

If NO errors were reported then you can run Ansible without the option `--check`.

```
(venv) $ ansible-playbook -l localhost -K site.yml
```
