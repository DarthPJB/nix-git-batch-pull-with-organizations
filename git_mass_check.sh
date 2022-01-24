#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq figlet

# git_mass_check.sh
#     This script will find and clone all of your repositories
#      including repositories belonging to your organizations
#      a handy tool on its own! but there's more.
#     The script will sort all the repositories into folders named
#      appropriately, if the repository already exists in the working_dir
#      then it will move it into the correct folder.
#     Also, if that wasn't enough, it will if run a second time (or the first)
#      it will fetch and pull any repository it would have otherwise cloned.
#
#     Expected usage:
#       $cd My_cluttered_repo_folder
#       $git_mass_check.sh ./
#
#   The Shbang above is used for Nix; it invokes bash with jq and figlet packages
#   if you are not using nix, or nixos, you will want to change this to #/!bin/#!/usr/bin/env bash
#   and pollute your user enviroment with these packages.
#
#   Created by John Bargman 2022
#   this code is MIT licenced, it's free software - keep it that way.


# Provides the ability to direct the script at a folder;
# for example
#     ./git_mass_checks.sh ./My_Repo_Folder
# otherwise it will use the current working folder
working_dir=${1-$(pwd)}
cd $working_dir

# insert your username here
user="USERNAME"
# add an API access token with repo-reading permissions here
# find this at : https://github.com/settings/tokens
token="API-TOKEN"
# add a list of your organization here!
organizations=("Org1" "Org2" "Etc")

# This is the regex used to clean the URL path
re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"

function BatchCheck
{
  source=$1;
  orgmode=$2;

  # I like figlet, it provides an attractive way of giving user messages!
  figlet "Checking: $source"

  #see if we are looking for a user or an organisation

  if [ "$orgmode" = "false" ];
  then
    #grab the organisation list and pass it through jq and sed to extract repository URLS
    echo "grabbing org data for $source"
    repo_list=$(curl https://api.github.com/orgs/$organization/repos?type=all\&per_page=1000 -u ${user}:${token}  | jq .[].ssh_url | sed -e 's/^"//'  -e 's/"$//')
  else
    #Grab user-repo list, passing it through jq and sed to extract repository URLS
    echo "grabbing user data for $source"
    repo_list=$(curl https://api.github.com/users/$source/repos?type=all\&per_page=1000 -u ${user}:${token}  | jq .[].ssh_url | sed -e 's/^"//'  -e 's/"$//')
  fi


  #check source-name folder exists, if not, creates it.
  cd $working_dir
  if cd $source;
    then
      echo "user dir exists"
    else
      echo "creating user dir";
      mkdir $source;
  fi

  # move back to the working directory
  cd $working_dir

  # Sort through all those repositories!
  for url in $repo_list
  do
     #The regex here only finds the name of the repo, but there's other options here
     # props to Hicham on stack overflow : https://serverfault.com/a/917253
     if [[ $url =~ $re ]]; then
         #protocol=${BASH_REMATCH[1]}
         #separator=${BASH_REMATCH[2]}
         #hostname=${BASH_REMATCH[3]}
         #user=${BASH_REMATCH[4]}
         repo=${BASH_REMATCH[5]}
     fi
     # check if we can enter the directory, if we can - move it to the correct folder
     if cd $repo 2>/dev/null;
     then
         echo "moving repo to user folder"
         cd $working_dir
         mv $repo $source
     fi
     # now we can move ourselves to the correct folder, and start cloning!
     cd $working_dir/$source
     # if the repo exists we will simply update it
     if cd $repo 2>/dev/null;
       then
         echo "updating $repo in $working_dir/$source/"
         git fetch;
         # note the use of --ff-only, this is non-destructive, and good practice.
         git pull --ff-only;
         cd $working_dir
       else
         #if the repo doesn't exist, we can git clone!
         echo New repo found for $repo at url: $url
         git clone $url $repo;
     fi
  done
}

BatchCheck $user "true";
for organization in ${organizations[@]}
do
  BatchCheck $organization "false";
done
