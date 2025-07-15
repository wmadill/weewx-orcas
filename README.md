# weewx-orcas
This repo has the various changes made to a stock weewx installation
for my Orcas configuration.

## Repo Contents
- `weewx.conf` - production version after installing extensions; check
  carefully before overwriting the running weewx.conf and merge
  any changes.
- `weewx.conf-test` - initial installation version before any extensions
  installed.
- `weewx-bkup` - directory of database backup files.
  - `bin` - contains install script and backup script.
  - `util` - logrotate configuration to rotate backup logs.
- `pre-weewx-5` - directory of contents before upgrade to weewx 5. Will 
  be deleted at some point because it is likely not useful,
- CHANGELOG.md, README.md - the usual...

## Installation
There will be a more detailed version in a file
added later but here is the general process.

1. Install `weewx` in `/home/weewx` using `pip` and test it.
2. Install these extensions (github repos):\
   - `forecast` (chaunceygardiner/weewx-forecast.git)\
   - `S3upload` (wmadill/weewx-S3upload.git)\
   -  `orcas-skin` (wmadill/weewx-orcas-skin.git)\
   - `sysinfo` (wmadill/weewx-sysinfo.git)
3. Update `weewx.conf` with the one in this repo, changing any settings
   required. Test.
4. Copy `weewx-bkup` to `/home/weewx/weewk-bkup`, run `bin/install.sh`, and
   copy `util/logrotate.d/weewx-bkup` to `/etc/logrotate.d`.
