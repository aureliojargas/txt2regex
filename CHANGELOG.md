# Changelog for txt2regex

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog].

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/

[Unreleased]: https://github.com/aureliojargas/txt2regex/compare/v0.8...HEAD
[Version 0.8]: https://github.com/aureliojargas/txt2regex/compare/v0.7...v0.8
[Version 0.7]: https://github.com/aureliojargas/txt2regex/compare/v0.6...v0.7
[Version 0.6]: https://github.com/aureliojargas/txt2regex/compare/v0.5...v0.6
[Version 0.5]: https://github.com/aureliojargas/txt2regex/compare/v0.4...v0.5
[Version 0.4]: https://github.com/aureliojargas/txt2regex/compare/v0.3.1...v0.4
[Version 0.3.1]: https://github.com/aureliojargas/txt2regex/compare/v0.3...v0.3.1
[Version 0.3]: https://github.com/aureliojargas/txt2regex/compare/v0.2...v0.3
[Version 0.2]: https://github.com/aureliojargas/txt2regex/compare/v0.1...v0.2
[Version 0.1]: https://github.com/aureliojargas/txt2regex/commit/1a45c22

[#7]: https://github.com/aureliojargas/txt2regex/pull/7
[#6]: https://github.com/aureliojargas/txt2regex/pull/6
[#5]: https://github.com/aureliojargas/txt2regex/pull/5
[#3]: https://github.com/aureliojargas/txt2regex/pull/3

## [Unreleased]

### Added

- Added CHICKEN Scheme regexes (thanks Mario Domenech Goulart)
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

### Removed

- Removed Lisp regexes (choose Emacs and/or CHICKEN Scheme instead)
- Removed OpenOffice.org regexes (not supported by the new regex tester)
- Removed VBScript regexes (not supported by the new regex tester)
- Removed the old regex tester `test-suite/*`
- Removed `tools/bashdump-rmdup.sh` since `msguniq` has the same
  functionality
- Removed the NEWS file for not adding too much value over the changelog

### Changed

- Bumped minimal required Bash version from 2.04 to 3.0
- Bumped the versions for all the supported programs
- Validated and updated the regex data for all the supported programs,
  thanks to the new regex tester. Some programs now support new
  metacharacters, while others got updates on the escaping rules and
  POSIX character classes support [#7]
- JavaScript regexes: now using Node.js instead of Netscape
- lex regexes: now using GNU flex
- PHP regexes: switch from old `ereg` to `preg` (PCRE)
- Changed the default programs: +egrep +grep +emacs -perl -php -postgres
- Remove repeated characters inside a list `[]` (if the user has typed
  `abbbca`, make it `[abc]`)
- Now `--showmeta` also shows the version for each program
- Now the "!! not supported" legend only appears when there are
  unsupported metacharacters in the current regex
- Converted everything (code, docs, translations) to UTF-8
- Improved the source code quality (`shellcheck`) and formatting
  (`shfmt`)
- Unset `$PATH` in the top of the script to make sure only Bash built-in
  commands are used
- Simplified the man page contents
- i18n: Improve some translatable strings to make them shorter and
  easier to translate
- Moved the project hosting from SourceForge to GitHub
- Converted this changelog to the [Keep a Changelog] format

### Fixed

- Fixed to work properly in bash5 (thanks Yanmarshus Bachtiar)
- Fixed `eval` bug when running in bash3 or newer (thanks Marcus
  Habermehl)
- Fixed incorrect metacharacters for `?` and `+` showing up for `vi` in
  `--showmeta` and `--showinfo`
- Fixed the escaping of the `}` character to be matched as a literal
- Fixed the escaping of the `\` character to be matched as a literal,
  for programs that use `\\` for escaping: before: `\\\`, now: `\\\\`
- Fixed the escaping of the `\` character when inside a list `[]`
- Fixed the handling of the `[` character when inside a list `[]`: it is
  not special at all and should not be handled
- Fixed the handling of the `^` character when inside a list `[]`: only
  move it to the end when it is in the first position
- Fixed the handling of the `-` character when inside a list `[]`: do
  not move it to the end when it is in the first position, since it is
  not special there

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
  not Bash built-in commands (and txt2regex strives to be 100% Bash
  built-ins powered)
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
