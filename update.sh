#!/usr/bin/env bash

APP_NAME='APP_NAME' # change this!
UPDATER_VERSION='0.1.2-beta9' # change this!

VERBOSE_MODE=true
INTERACTION_MODE=true
TMP_LOCATION=$HOME/tmp

function do_update_procedure
{
  # TODO: implement do_update_procedure
  echo "do update procedure"
}

function set_local_version
{
  # TODO: implement set_local_version
  # usually it looks something like this:
  # LOCAL_VERSION=$(app --version)
  LOCAL_VERSION=0.0.1
}

function set_latest_version
{
  # This if block will skip this function in case you used the `use` command like `update-app use 1.2.3`
  if test -n "$LATEST_VERSION"
  then return 0
  fi
  # TODO: implement set_latest_version
  # For example you call the GitHub `latest` release API endpoint
  LATEST_VERSION=0.0.2
}

function set_latest_updater_version
{
  UPDATER_ORG=EV21 # Organisation or GitHub user
  UPDATER_REPO=bash-update-script-template
  UPDATER_GITHUB_API_URL=https://api.github.com/repos/$UPDATER_ORG/$UPDATER_REPO/releases/latest
  curl --silent $UPDATER_GITHUB_API_URL > "$TMP_LOCATION"/github_api_response.json
  LATEST_UPDATER_VERSION=$(jq --raw-output '.tag_name' "$TMP_LOCATION"/github_api_response.json)
}

function is_updater_update_available
{
  if is_version_lower_than $UPDATER_VERSION "$LATEST_UPDATER_VERSION"
  then return 0
  else return 1
  fi
}

function ask_yes_no_question
{
  local question=$1
  while true
  do
  read -r -p "$question (y/n) " ANSWER
  case $ANSWER in
    [Yy]* | [Jj]* )
      return 0
      ;;
    [Nn]* )
      return 1
      ;;
    * ) echo "Please answer yes or no. ";;
  esac
  done
}

# is_version_lower_than A B
# returns whether A < B
function is_version_lower_than
{
  test "$(echo "$@" |                 # get all version arguments
    tr " " "\n" |                     # replace `space` with `new line`
    sed '/alpha/d; /beta/d; /rc/d' |  # remove pre-release versions (version-sort interprets suffixes as patch versions)
    sort --version-sort --reverse |   # latest version will be sorted to line 1
    head --lines=1)" != "$1"          # filter line 1 and compare it to A
}

function is_update_available
{
  if is_version_lower_than "$LOCAL_VERSION" "$LATEST_VERSION"
  then return 0
  else return 1
  fi
}

function interaction_mode
{
  if test $INTERACTION_MODE = "true"
  then return 0
  else return 1
  fi
}

function verbose_mode
{
  if test $VERBOSE_MODE = "true"
  then return 0
  else return 1
  fi
}

function verbose_echo
{
  if verbose_mode
  then echo "$@"
  fi
}

function show_help_message
{
  cat << end_of_content
$APP_NAME Updater $UPDATER_VERSION

Usage:
$0 [ [--no-interaction] [--silent | --quiet] [--cron] [use <version-argument>] ] | [help | version]
$0 help                     shows this help message and exits
$0 version                  shows the update scripts version and exits
$0 use <version-argument>   manually set the version you like to update to - example: $0 use 1.0.42

Options:
  --no-interaction         the script will not ask you anything, it will just do its work (interaction mode is on by default)
  --silent                 the output is more silent and shuts up if there is no update (silet mode is off by default)
  --cron                   this is just a shortcut that sets no-interaction and silent mode

end_of_content
}

function process_parameters
{
  while test $# -gt 0
	do
    local next_parameter=$1
    case $next_parameter in
      help | --help )
        show_help_message
        exit 0
      ;;
      version | --version )
        echo $UPDATER_VERSION
        exit 0
      ;;
      use )
        LATEST_VERSION="$2"
        shift 2
      ;;
      --quiet | --silent )
        VERBOSE_MODE=false
        shift
      ;;
      --no-interaction )
        INTERACTION_MODE=false
        shift
      ;;
      --cron )
        VERBOSE_MODE=false
        INTERACTION_MODE=false
      ;;
      * )
        echo "$1 can not be processed, exiting script"
        exit 1
      ;;
    esac
  done
}

function main
{
  process_parameters "$@"
  set_latest_updater_version
  if is_updater_update_available
  then echo "$APP_NAME Updater $LATEST_UPDATER_VERSION is available, please update this script!"
  else verbose_echo "$APP_NAME Updater $LATEST_UPDATER_VERSION"
  fi
  set_local_version
  set_latest_version
  if is_update_available
  then
    echo "There is a new version available for $APP_NAME."
    echo "Do update from $LOCAL_VERSION to $LATEST_VERSION"
    if ! interaction_mode || ask_yes_no_question "Do you want to do this update?"
    then
      do_update_procedure
    fi
  else
    verbose_echo "Your $APP_NAME is already up to date."
    verbose_echo "You are running $APP_NAME $LOCAL_VERSION"
  fi
}

main "$@"
exit $?