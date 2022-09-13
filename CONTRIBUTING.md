# Contributing to txt2regex

Please follow the usual GitHub workflow to contribute to this project:

- Use [GitHub issues](https://github.com/aureliojargas/txt2regex/issues) for bug reports and feature requests.

- Use GitHub pull requests to submit code and translations.

## Guidelines

The following guidelines are reminders for the future me (the author), because I cannot hold all of that information in my head. You, as a contributor, are not required to follow them (but thanks if you do).

- Keep the current code style (even if you find it odd)

- Keep the code formatted (`make fmt`) and validated (`make lint`)

- Do not use any system command, this is a Bash builtins script

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

- Make sure it's working in all the supported Bash versions: `make test-bash`

- When touching the regex tester, run it (`make test-regex`) and check the `regex-tester.txt` contents for changes

- Do some manual testing to make sure the interactive usage is ok

## Releasing

- Make sure all the tests are passing (see previous topic)

- Make sure the manual page contents is up-to-date with the current code and regenerate it with `make doc`

- Make sure the Changelog is up-to-date, containing all the relevant changes since the last released version

- In the `TODO` file, is there anything to be added/removed?

- In the `README.md` file, is there anything to be added/removed?

- Update the `po/*.{po,pot}` files to match the current code: run `make po` and commit

- Create the official release commit:

  - Update the version number in `txt2regex.sh` and `Makefile`
  - Update the version number in `tests/cmdline.md`
  - Update the version number and creation date in the potfile: `make pot`
  - Update the man page date to the release date and regenerate it: `make doc`
  - Update the changelog with the version number and release date
    - Remember to update the "compare" links at the top
  - Rerun the tests, just in case: `make check`
  - Commit
  - Tag this commit with the version number
  - Example: https://github.com/aureliojargas/txt2regex/commit/be3e0fa

- Publish the release: `git push && git push --tags`

- Get back to the development version:
  - Update the version number in `txt2regex.sh` and `Makefile`
    - Use `version+1` and add the `b` suffix (for beta)
  - Example: https://github.com/aureliojargas/txt2regex/commit/193c011

## History rewrite

In 2020-05-19 the whole Git history for this repository was rewritten. It was necessary to set the correct date for the initial commits, so they reflect the official release date for the releases.

Before:

    699db55 2012-12-21  adding txt2regex version 0.1 (2001-02-23)
    fb48115 2012-12-21  Revert "adding txt2regex version 0.1 (2001-02-23)"
    1a45c22 2012-12-21  add txt2regex version 0.1 (2001-02-23)
    961f8fa 2012-12-21  Program renamed from txt2regexp to txt2regex
    f4ac6e7 2012-12-21  Add txt2regex version 0.2 (2001-04-24)
    4c037d1 2012-12-21  Renamed file: id.po => id_ID.po
    7c4de30 2012-12-21  Add txt2regex version 0.3 (2001-06-13)
    5d56afd 2012-12-21  Add txt2regex version 0.3.1 (2001-06-26)
    92c7677 2012-12-21  Add txt2regex version 0.4 (2001-08-02)
    cd23c57 2012-12-21  Add txt2regex version 0.5 (2001-08-28)
    4b572b5 2012-12-21  Add txt2regex version 0.6 (2001-09-05)
    20ac0f5 2012-12-21  Add txt2regex version 0.7 (2002-03-04)
    6fe0ae8 2012-12-21  Add txt2regex version 0.8 (2004-09-28)
    3bbfa3b 2012-12-21  Add txt2regex version 0.9 beta (unreleased)

After:

    f17f458 2001-02-22  Initial commit
    2f066eb 2001-02-22  Remove empty README
    eff18e0 2001-02-23  Add txt2regex version 0.1 (2001-02-23)
    5f685c5 2001-04-24  Program renamed from txt2regexp to txt2regex
    da3e729 2001-04-24  Add txt2regex version 0.2 (2001-04-24)
    db8a71e 2001-06-13  Renamed file: id.po => id_ID.po
    6fa7545 2001-06-13  Add txt2regex version 0.3 (2001-06-13)
    98c60e8 2001-06-26  Add txt2regex version 0.3.1 (2001-06-26)
    f2acfd3 2001-08-02  Add txt2regex version 0.4 (2001-08-02)
    bdd05d1 2001-08-28  Add txt2regex version 0.5 (2001-08-28)
    7e9159f 2001-09-05  Add txt2regex version 0.6 (2001-09-05)
    b8b618a 2002-03-04  Add txt2regex version 0.7 (2002-03-04)
    8d96c9a 2004-09-28  Add txt2regex version 0.8 (2004-09-28)
    2768584 2012-12-21  Add txt2regex version 0.9 beta (unreleased)

Note that the initial commit was also fixed, instead of the old weird revert.

All of the existing Git tags (`v0.1`, `v0.2`, ...) were updated to point to the new commits.

Another change in this rewrite was the removal (not the revert) of the commit that added the `releases/` folder with all the `.tgz` files from all the releases (until v0.8):

    2a113fe 2013-09-22  Add new 'releases' folder with TGZ files

That was a bad idea. GitHub already provides automatic `.zip` and `.tar.gz` files for every tagged commit. Since all of those first commits were created by expanding the tarballs from the official releases, the GitHub ones should be equal.

The old `master` branch was saved as the `master-until-2020-05-19` branch.

All the pull requests until number 7 are now referencing not the `master` commits, but those in the `master-until-2020-05-19` branch.

I know this is a total mess. I'm sorry for that. But I think having the official dates for the commits of the old versions is important. Now the "Releases" listing in GitHub has the correct dates.
