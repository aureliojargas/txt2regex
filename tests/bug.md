```console
$ set -o | grep -e pipefail -e errexit
$ set +e
$ set +o pipefail
$ set -o | grep -e pipefail -e errexit
$ seq 20 | head -n 1
1
$ yes | head -n 1
y
$
```

