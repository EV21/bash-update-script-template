#!/usr/bin/env bash

APP_NAME='APP_NAME'
UPDATER_VERSION='1.0.0' 

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

function process_parameters
{
  while test $# -gt 0
	do
    local next_parameter=$1
    case $next_parameter in
      version )
        echo $UPDATER_VERSION
        exit 0
      ;;
      use )
        LATEST_VERSION="$2"
        shift 2
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
  set_local_version
  set_latest_version
  if is_update_available
  then
    echo "There is a new version of available for $APP_NAME."
    echo "Doing update from $LOCAL_VERSION to $LATEST_VERSION"
    do_update_procedure
  else
    echo "Your $APP_NAME is already up to date."
    echo "You are running $APP_NAME $LOCAL_VERSION"
  fi
}

main "$@"
exit $?