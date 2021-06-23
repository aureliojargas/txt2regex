```console
$ txt2regex() { bash ./txt2regex.sh "$@"; }
$ set +e
$ set +o pipefail
$ seq 20 | head
$ yes | head
$ set +o pipefail; txt2regex --foo | head -n 3 | sed '3 s/:.*//'
--foo: invalid option

usage
$
```

