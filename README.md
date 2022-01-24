# git mass checker
A simple and helpful utility script for nix (easily edited for legacy Linux distributions.)

This script will find and clone all of your repositories including repositories belonging to your organizations, a handy tool on its own! but there's more.

The script will sort all the repositories into folders named appropriately, if the repository already exists in the working_dir then it will move it into the correct folder.

Also, if that wasn't enough, it will if run a second time (or the first) it will fetch and pull any repository it would have otherwise cloned.

##     Expected usage:
Edit the script to insert your:
1. username
2. api-token (https://github.com/settings/tokens)
3. organisation names
then run:
```
$ cd My_cluttered_repo_folder
$ git_mass_check.sh ./
```
The Shebang at the top of the script is used for Nix; it invokes bash with jq and figlet packages
``` bash
   #!/usr/bin/env nix-shell
   #!nix-shell -i bash -p jq figlet
```
if you are not using nix, or nixos, you will want to change this to `` #/!bin/bash `` and pollute your user environment with these packages:
    1. jq
    2. figlet

## Final notes
There's obviously no warrenty; don't run code on your computer that you haven't read every line of, and understood. that's why programmers write comments.

### Created by John Bargman in January of 2022
### This code is MIT licensed, it's free software - keep it that way.
