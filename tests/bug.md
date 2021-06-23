```console
$ txt2regex() { bash ./txt2regex.sh "$@"; }
$
```


```console
$ txt2regex --foo | head -n 3 | sed '3 s/:.*//'
--foo: invalid option

usage
$
```

