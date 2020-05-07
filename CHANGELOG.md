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


## [Unreleased]

### Added

- Added CHICKEN Scheme regexes (thanks Mario Domenech Goulart)
- Added short options `-h` (for `--help`) and `-V` (for `--version`)
- New tests for all the command line options (`tests/cmdline.md`)
- New regex tester that runs the supported programs with specially
  crafted regexes, verifying how they behave in "real life", instead of
  relying in documentation (`tests/regex-tester.sh`)

### Removed

- Removed support for Lisp, OpenOffice.org, VBScript regexes

### Changed

- Minimal required Bash version was bumped from 2.04 to 2.05
- Changed the default programs: +egrep +grep -perl -php -postgres
- Now `--showmeta` also shows the version for each program
- Now the "!! not supported" legend only appears when there are
  unsupported metacharacters in the current regex
- Converted everything (code, docs, translations) to UTF-8
- Improved the source code quality (`shellcheck`) and formatting
  (`shfmt`)
- Simplified the man page
- Improved `--help` message

### Fixed

- Fixed to work properly in bash5 (thanks Yanmarshus Bachtiar)
- Fixed `eval` bug when running in bash3 or newer (thanks Marcus
  Habermehl)

### Translations

- Added Turkish translations provided by erayalakese
- Added Catalan translations provided by Carles (ChAoS)
  <chaos ct (a) gmail com>
- Added French translations provided by wwp
  <subscript (a) free fr>

## [Version 0.8] released in 2004-09-28

- Added OpenOffice.org regexes support
- Documentation updated: cleaner README and new Man page
- Fixed bash version test, now works on bash-3.0 and newer
  (thanks Rene Engelhard @ Debian)
- Fixed sed script bug on `procmail-re-test` (thanks JulioB @ caltech)
- Added Romanian translations provided by Robert Claudiu Gheorghe
  <RobertGheorghe2004 (a) yahoo ca>
- Added Spanish translations provided by Diego Moya Velázquez
  <diego moya (a) madrid com>
- Added Italian translations provided by Daniele Pizzolli and
  revised by Marco Pagnanini
  <ors (a) tovel it> and <info (a) marcopagnanini it>

## [Version 0.7] released in 2002-03-04

- Fixed Makefile bug on `DESTDIR` (thanks Martin Butterwecki @ Debian)
- Added man page and "Really quit?" message (Martin request again)
- Added `--version` option (it's a classic, so...)
- Added Japanese translations provided by Hajime Dei
- Ready-to-use common regexes (date, hour, number) with `--make`
- Added `--prog` option to choose which programs to use
- Groups are now quantifiable

## [Version 0.6] released in 2001-09-05

- Added (group|and|alternation) support
- Added groups balance check -> `(((3)))`
- Option `--history` improved and sync'ed with all features
- Added MySQL regexes support
- Added German translations provided by Jan Parthey
  <parthey (a) web de>

## [Version 0.5] released in 2001-08-28

- New command line options: `--showmeta`, `--showinfo`

## [Version 0.4] released in 2001-08-02

- Updated Polish translations
- Added Postgres, javascript, VBscript and procmail regexes support
- Test-suite improved and included on the tarball
- New `procmail-re-test` utility for procmail cmdline regex test

## [Version 0.3.1] released in 2001-06-26

- Updated Indonesian and Polish translations
- Took out `seq` command (not bash), and substituted by the new `sek()`
  function. Pretty cool, just 2 lines.
  And so, last release was NOT 100% bash, /me <- Luser
  but now it is. I think. &:)

## [Version 0.3] released in 2001-06-13

- Support to localized POSIX character classes `[[:abc:]]`
- Support to special user combinations inside lists `[]`
- A friendly `--help` output
- New command line option: `--whitebg`
- Final human sentence improved with more detailed data
- Added Polish translations provided by Chris Piechowicz
  <chris_piechowicz (a) hotmail com>
- Took out `clear` and `stty` commands, because they were not bash
  now we have a 100% bash builtins script!

## [Version 0.2] released in 2001-04-24

- New command line options: `--nocolor`, `--history`
- A new dynamic history for user input:
  `.oO(history)(¤user_input1¤userinput2¤...)`
- Added Indonesian (Bahasa) translations provided by Muhamad Faizal
  <faizal (a) mfaizal net>

## [Version 0.1] released in 2001-02-23

- Initial release (as txt2regexp)
