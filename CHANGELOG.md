# Changelog for txt2regex

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog].

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/

[Unreleased]: https://github.com/aureliojargas/txt2regex/compare/v0.9...HEAD
[Version 0.9]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.9
[Version 0.8]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.8
[Version 0.7]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.7
[Version 0.6]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.6
[Version 0.5]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.5
[Version 0.4]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.4
[Version 0.3.1]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.3.1
[Version 0.3]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.3
[Version 0.2]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.2
[Version 0.1]: https://github.com/aureliojargas/txt2regex/releases/tag/v0.1

[#12]: https://github.com/aureliojargas/txt2regex/pull/12
[#9]: https://github.com/aureliojargas/txt2regex/pull/9
[#7]: https://github.com/aureliojargas/txt2regex/pull/7
[#6]: https://github.com/aureliojargas/txt2regex/pull/6
[#5]: https://github.com/aureliojargas/txt2regex/pull/5
[#3]: https://github.com/aureliojargas/txt2regex/pull/3

[307ae9a]: https://github.com/aureliojargas/txt2regex/commit/307ae9a
[d0c6254]: https://github.com/aureliojargas/txt2regex/commit/d0c6254
[bee846a]: https://github.com/aureliojargas/txt2regex/commit/bee846a
[dbcd055]: https://github.com/aureliojargas/txt2regex/commit/dbcd055
[f1d80c9]: https://github.com/aureliojargas/txt2regex/commit/f1d80c9
[0a7127a]: https://github.com/aureliojargas/txt2regex/commit/0a7127a
[1660d83]: https://github.com/aureliojargas/txt2regex/commit/1660d83
[61abe24]: https://github.com/aureliojargas/txt2regex/commit/61abe24
[3a3fd24]: https://github.com/aureliojargas/txt2regex/commit/3a3fd24
[8e1f6ea]: https://github.com/aureliojargas/txt2regex/commit/8e1f6ea
[4b98e2b]: https://github.com/aureliojargas/txt2regex/commit/4b98e2b
[f5d0125]: https://github.com/aureliojargas/txt2regex/commit/f5d0125
[d7850d2]: https://github.com/aureliojargas/txt2regex/commit/d7850d2
[f323926]: https://github.com/aureliojargas/txt2regex/commit/f323926
[190906c]: https://github.com/aureliojargas/txt2regex/commit/190906c
[2768584]: https://github.com/aureliojargas/txt2regex/commit/2768584
[4b41298]: https://github.com/aureliojargas/txt2regex/commit/4b41298
[7a1b0cb]: https://github.com/aureliojargas/txt2regex/commit/7a1b0cb
[674d7bb]: https://github.com/aureliojargas/txt2regex/commit/674d7bb
[bee220c]: https://github.com/aureliojargas/txt2regex/commit/bee220c
[a3f7fef]: https://github.com/aureliojargas/txt2regex/commit/a3f7fef
[c084ed8]: https://github.com/aureliojargas/txt2regex/commit/c084ed8


## [Unreleased]

### Added

- CI: Now also run the tests for Bash version 5.1 [307ae9a]

### Changed

- CI: Moved from Travis CI to GitHub Actions [#9]

### Fixed

- Fixed to work properly in Bash 5.2 (thanks Nick Rosbrook) [#12]


## [Version 0.9] released in 2020-05-21

### Added

- Added CHICKEN Scheme regexes (thanks Mario Domenech Goulart)
  [dbcd055], [f1d80c9]
- New tests for all the command line options (`tests/cmdline.md`)
- New tests for txt2regex features (`tests/features.md`) [#5]
- New regex tester that runs the supported programs in a Docker
  container. Using specially crafted regexes, it verifies how the
  programs behave in "real life". This avoids manual testing or reading
  the program documentation to get regex-related information
  (`tests/regex-tester.sh`) [#6]
- New automatic testing in all Bash versions from 3.0 to 5.0, to make
  sure txt2regex works in all of them (`make test-bash`)
- Now using Travis CI to run all the tests at every push to the GitHub
  repository
- New Makefile targets to perform common tasks: `check`, `fmt`,
  `install-bin`, `install-mo`, `lint`, `test`, `test-bash`,
  `test-regex`, `test-regex-build`, `test-regex-shell`
- Added short options `-h` (for `--help`) and `-V` (for `--version`)
  [0a7127a], [1660d83]

### Removed

- Removed Lisp regexes (choose Emacs and/or CHICKEN Scheme instead)
- Removed OpenOffice.org regexes (not supported by the new regex tester)
- Removed VBScript regexes (not supported by the new regex tester)
- Removed the old regex tester `test-suite/*`
- Removed `tools/bashdump-rmdup.sh` since `msguniq` has the same
  functionality
- Removed the NEWS file for not adding too much value over the changelog

### Changed

- Bumped minimal required Bash version from 2.04 to 3.0 [d0c6254]
- Bumped the versions for all the supported programs [#7]
- Validated and updated the regex data for all the supported programs,
  thanks to the new regex tester. Some programs now support new
  metacharacters, while others got updates on the escaping rules and
  POSIX character classes support [#7]
- JavaScript regexes: now using Node.js instead of Netscape [61abe24]
- lex regexes: now using GNU flex [3a3fd24]
- PHP regexes: switch from old `ereg` to `preg` (PCRE) [8e1f6ea]
- Changed the default programs: +egrep +grep +emacs -perl -php -postgres
- Remove repeated characters inside a list `[]` (if the user has typed
  `abbbca`, make it `[abc]`) [4b98e2b]
- Now `--showmeta` also shows the version for each program [d7850d2]
- Now the "!! not supported" legend only appears when there are
  unsupported metacharacters in the current regex [f323926]
- Converted everything (code, docs, translations) to UTF-8
- Improved the source code quality (`shellcheck`) and formatting
  (`shfmt`)
- Unset `$PATH` in the top of the script to make sure only Bash builtin
  commands are used [bee846a]
- Simplified the man page contents [f5d0125]
- i18n: Improve some translatable strings to make them shorter and
  easier to translate
- Moved the project hosting from SourceForge to GitHub
- Converted this changelog to the [Keep a Changelog] format

### Fixed

- Fixed to work properly in bash5 (thanks Yanmarshus Bachtiar) [190906c]
- Fixed `eval` bug when running in bash3 or newer (thanks Marcus
  Habermehl) [2768584]
- Fixed incorrect metacharacters for `?` and `+` showing up for `vi` in
  `--showmeta` and `--showinfo` [c084ed8]
- Fixed the escaping of the `}` character to be matched as a literal
- Fixed the escaping of the `\` character to be matched as a literal,
  for programs that use `\\` for escaping: before: `\\\`, now: `\\\\`
  [4b41298]
- Fixed the escaping of the `\` character when inside a list `[]`
  [a3f7fef]
- Fixed the handling of the `[` character when inside a list `[]`: it is
  not special at all and should not be handled [7a1b0cb]
- Fixed the handling of the `^` character when inside a list `[]`: only
  move it to the end when it is in the first position [674d7bb]
- Fixed the handling of the `-` character when inside a list `[]`: do
  not move it to the end when it is in the first position, since it is
  not special there [bee220c]

### Translations

- Added Turkish translations provided by erayalakese [#3]
- Added Catalan translations provided by Carles (ChAoS)
- Added French translations provided by wwp

## [Version 0.8] released in 2004-09-28

### Added

- Added OpenOffice.org regexes support

### Changed

- Documentation updated: cleaner README and new man page contents

### Fixed

- Fixed bash version test, now works on bash 3.0 and newer (thanks Rene
  Engelhard)
- Fixed sed script bug on `procmail-re-test` (thanks JulioB @ caltech)

### Translations

- Added Romanian translations provided by Robert Claudiu Gheorghe
- Added Spanish translations provided by Diego Moya Velázquez
- Added Italian translations provided by Daniele Pizzolli and
  revised by Marco Pagnanini

## [Version 0.7] released in 2002-03-04

### Added

- Groups are now quantifiable, i.e. `(foo|bar){1,5}`
- New option `--prog` to choose which programs to show the regexes for
- New option `--make` to automatically compose regexes for common
  patterns: date, hour, number
- New option `--version` to show the txt2regex version
- Added the "Really quit?" confirmation (thanks Martin Butterwecki)
- Added man page (thanks Martin Butterwecki)

### Fixed

- Fixed Makefile bug on `DESTDIR` (thanks Martin Butterwecki)

### Translations

- Added Japanese translations provided by Hajime Dei

## [Version 0.6] released in 2001-09-05

- Added (group|and|alternation) support
- Added groups balance check -> `(((3)))`
- Added MySQL regexes support
- Option `--history` now supports all the txt2regex features
- Added German translations provided by Jan Parthey

## [Version 0.5] released in 2001-08-28

- New option `--showmeta` to print a complete metacharacters table
- New option `--showinfo` to print regex-related information about a
  program

## [Version 0.4] released in 2001-08-02

- Added JavaScript regexes support
- Added PostgreSQL regexes support
- Added procmail regexes support
- Added VBScript regexes support
- New `procmail-re-test` utility to test the procmail regexes from the
  command line
- Test-suite improved and now included on the tarball
- Updated Polish translations

## [Version 0.3.1] released in 2001-06-26

- Now using a custom `sek()` function instead of the `seq` command, thus
  removing the last external (non-bash-builtin) command from txt2regex
- Updated Indonesian translation
- Updated Polish translation

## [Version 0.3] released in 2001-06-13

- Added support for localized POSIX character classes `[[:abc:]]`
- Added support for special user combinations inside lists `[]`
- New option `--whitebg` to adjust the colors for white background
  terminals
- Improve the final human sentence with more detailed data
- Remove the usage of the `clear` and `stty` commands, because they are
  not Bash builtin commands (and txt2regex strives to be 100% Bash
  builtins powered)
- The project is now hosted at SourceForge
- Added Polish translations provided by Chris Piechowicz

## [Version 0.2] released in 2001-04-24

- Changed project name from txt2regexp to txt2regex
- New option `--history` to "replay" from history data a regex
  previously composed in txt2regex
- New option `--nocolor` to not use colors in the interface
- New dynamic history for user input:
  `.oO(history)(¤user_input1¤userinput2¤...)`
- Added Indonesian (Bahasa) translations provided by Muhamad Faizal

## [Version 0.1] released in 2001-02-23

- Initial release (as txt2regexp)
