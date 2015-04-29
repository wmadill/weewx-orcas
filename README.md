# weewx-orcas
This repo has the various changes made to a stock weewx installation
for my Orcas configuration.

## File layout
Files are laid out the same way that weewx has them. Any directory
with a file supercedes the corresponding file in the stock
configuraiton. In most cases these are updated versions of the 
server configuration files such as for `/etc/logwatch`. There is a
modified `mem` extension which I will eventually replace with a
different extension with server information I want.

## Installation
There will be a more elaborate (and more correct) version in a file
added later but here is the general process.
1. Install weewx in `/home/weewx`
2. Install the forecast, mem, S3upload, and reports extensions
3. Replace the installed `mem.py` with the one in this repo.
3. Update weewx.conf with the one in this repo, changing any settings
required.
4. Hook up all the server scripts by symlinking from where they should
be to the ones in this repo.
