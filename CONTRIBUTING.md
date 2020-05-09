# Contributing to txt2regex

Please follow the usual GitHub workflow to contribute to this project:

- Use [GitHub issues](https://github.com/aureliojargas/txt2regex/issues) for bug reports and feature requests.

- Use GitHub pull requests to submit code and translations.

## Guidelines

The following guidelines are reminders for the future me (the author), because I cannot hold all of that information in my head. You, as a contributor, are not required to follow them (but thanks if you do).

- Keep the current code style (even if you find it odd)

- Keep the code formatted (`make fmt`) and validated (`make lint`)

- Do not use any system command, this is a Bash built-ins script

- Do not use any Bash feature that is not supported by the old minimal version txt2regex supports (see https://mywiki.wooledge.org/BashFAQ/061)

- Do not use `echo`, use `printf`

- Always use `[` instead of `test` in `txt2regex.sh`

- Use `-eq` and `-ne` instead of `==` and `!=` for numeric tests

- Use `-n` and `-z` when testing variables for emptiness

- Always use `$"..."` for strings that the user will see (i18n)

- Think about translations, keep strings short and direct

- Update the man page when there are relevant changes

- Update the Changelog when there are relevant changes

- New files should always be UTF-8

## Testing

All tests must always be successful. The CI will refuse changes that break tests.

- Add/update tests in `tests/*.md` when adding/updating features

- Make sure all the tests are passing: `make test`

- Make sure it's working in all Bash versions: `make test-bash`

- When touching the regex tester, run it (`make test-regex`) and check the `regex-tester.txt` contents for changes

- Do some manual testing to make sure the interactive usage is ok
