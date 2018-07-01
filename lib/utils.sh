#!/bin/bash
# Some helper functions taken from martinburger/bash-common-helpers

# Copyright (c) 2014 Martin Burger
# Released under the MIT License (MIT)
# https://github.com/martinburger/bash-common-helpers/blob/master/LICENSE

################################################################################
#
# SEE README.MD ON HOW TO USE THE FUNCTIONS PROVIDED BY THIS LIBRARY.
#
################################################################################

#
# SCRIPT INITIALIZATION --------------------------------------------------------
#

# init
#
# Should be called at the beginning of every shell script.
#
# Exits your script if you try to use an uninitialised variable and exits your
# script as soon as any statement fails to prevent errors snowballing into
# serious issues.
#
# Example:
# init
#
# See: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
#
function init {
  # Will exit script when a simple command (not a control structure) fails:
  set -o errexit
}

#
# PRINTING TO THE SCREEN -------------------------------------------------------
#

# info message ...
#
# Writes the given messages in green letters to standard output.
#
# Example:
# info "Task completed."
#
function info {
  local green=$(tput setaf 2)
  local reset=$(tput sgr0)
  echo -e "${green}$@${reset}"
}

# important message ...
#
# Writes the given messages in yellow letters to standard output.
#
# Example:
# important "Please complete the following task manually."
#
function important {
  local yellow=$(tput setaf 3)
  local reset=$(tput sgr0)
  echo -e "${yellow}$@${reset}"
}

# warn message ...
#
# Writes the given messages in red letters to standard output.
#
# Example:
# warn "There was a failure."
#
function warn {
  local red=$(tput setaf 1)
  local reset=$(tput sgr0)
  echo -e "${red}$@${reset}"
}

#
# ERROR HANDLING ---------------------------------------------------------------
#

# die message ...
#
# Writes the given messages in red letters to standard error and exits with
# error code 1.
#
# Example:
# die "An error occurred."
#
function die {
  local red=$(tput setaf 1)
  local reset=$(tput sgr0)
  echo >&2 -e "${red}$@${reset}"
  exit 1
}

#
# AVAILABILITY OF COMMANDS AND FILES -------------------------------------------
#

# assert_command_is_available command
#
# Makes sure that the given command is available.
#
# Example:
# assert_command_is_available "ping"
#
# See: http://stackoverflow.com/a/677212/66981
#
function assert_command_is_available {
  local cmd=${1}
  type ${cmd} >/dev/null 2>&1 || die "Cancelling because required command '${cmd}' is not available."
}

# assert_file_exists file "Print this message"
#
# Makes sure that the given regular file exists. Thus, is not a directory or
# device file.
#
# Example:
# assert_file_exists "myfile.txt"
#
function assert_file_exists {
  local file=${1}
  if [[ ! -f "${file}" ]]; then
    if [[ -z $2 ]]; then
        die "Cancelling because required file '${file}' does not exist."
    else
        die $2
    fi
  fi
}

# assert_dir_exists dir "Print this message"
#
# Makes sure that the given regular directory exists
#
# Example:
# assert_dir_exists "mydir/"
#
function assert_dir_exists {
  local dir=${1}
  if [[ ! -d "${dir}" ]]; then
    if [[ -z $2 ]]; then
        die "Cancelling because required directory '${dir}' does not exist."
    else
        die $2
    fi
  fi
}

# assert_file_does_not_exist file "Print this message"
#
# Makes sure that the given file does not exist.
#
# Example:
# assert_file_does_not_exist "file-to-be-written-in-a-moment"
#
function assert_file_does_not_exist {
  local file=${1}
  if [[ -e "${file}" ]]; then
    if [[ -z $2 ]]; then
        die "Cancelling because required file '${file}' does not exist."
    else
        die $2
    fi
  fi
}

#
# USER INTERACTION -------------------------------------------------------------
#

# ask_to_continue message
#
# Asks the user - using the given message - to either hit 'y/Y' to continue or
# 'n/N' to cancel the script.
#
# Example:
# ask_to_continue "Do you want to delete the given file?"
#
# On yes (y/Y), the function just returns; on no (n/N), it prints a confirmative
# message to the screen and exits with return code 1 by calling `die`.
#
function ask_to_continue {
  local msg=${1}
  local waitingforanswer=true
  while ${waitingforanswer}; do
    read -p "${msg} (hit 'y/Y' to continue, 'n/N' to cancel) " -n 1 ynanswer
    case ${ynanswer} in
      [Yy] ) waitingforanswer=false; break;;
      [Nn] ) echo ""; die "Operation cancelled as requested!";;
      *    ) echo ""; echo "Please answer either yes (y/Y) or no (n/N).";;
    esac
  done
  echo ""
}

# ask_for_password variable_name prompt
#
# Asks the user for her password and stores the password in a read-only
# variable with the given name.
#
# The user is asked with the given message prompt. Note that the given prompt
# will be complemented with string ": ".
#
# This function does not echo nor completely hides the input but echos the
# asterisk symbol ('*') for each given character. Furthermore, it allows to
# delete any number of entered characters by hitting the backspace key. The
# input is concluded by hitting the enter key.
#
# Example:
# ask_for_password "THEPWD" "Please enter your password"
#
# See: http://stackoverflow.com/a/24600839/66981
#
function ask_for_password {
  local VARIABLE_NAME=${1}
  local MESSAGE=${2}

  echo -n "${MESSAGE}: "
  stty -echo
  local CHARCOUNT=0
  local PROMPT=''
  local CHAR=''
  local PASSWORD=''
  while IFS= read -p "${PROMPT}" -r -s -n 1 CHAR
  do
    # Enter -> accept password
    if [[ ${CHAR} == $'\0' ]] ; then
      break
    fi
    # Backspace -> delete last char
    if [[ ${CHAR} == $'\177' ]] ; then
      if [ ${CHARCOUNT} -gt 0 ] ; then
        CHARCOUNT=$((CHARCOUNT-1))
        PROMPT=$'\b \b'
        PASSWORD="${PASSWORD%?}"
      else
        PROMPT=''
      fi
    # All other cases -> read last char
    else
      CHARCOUNT=$((CHARCOUNT+1))
      PROMPT='*'
      PASSWORD+="${CHAR}"
    fi
  done
  stty echo
  readonly ${VARIABLE_NAME}=${PASSWORD}
  echo
}

#
# FILE UTILITIES ---------------------------------------------------------------
#

# replace_in_files search replace file ...
#
# Replaces given string 'search' with 'replace' in given files.
#
# Important: The replacement is done in-place. Thus, it overwrites the given
# files, and no backup files are created.
#
# Note that this function is intended to be used to replace fixed strings; i.e.,
# it does not interpret regular expressions. It was written to replace simple
# placeholders in sample configuration files (you could say very poor man's
# templating engine).
#
# This functions expects given string 'search' to be found in all the files;
# thus, it expects to replace that string in all files. If a given file misses
# that string, a warning is issued by calling `warn`. Furthermore,
# if a given file does not exist, a warning is issued as well.
#
# To replace the string, perl is used. Pattern metacharacters are quoted
# (disabled). The search is a global one; thus, all matches are replaced, and
# not just the first one.
#
# Example:
# replace_in_files placeholder replacement file1.txt file2.txt
#
function replace_in_files {

  local search=${1}
  local replace=${2}
  local files=${@:3}

  for file in ${files[@]}; do
    if [[ -e "${file}" ]]; then
      if ( grep --fixed-strings --quiet "${search}" "${file}" ); then
        perl -pi -e "s/\Q${search}/${replace}/g" "${file}"
      else
        warn "Could not find search string '${search}' (thus, cannot replace with '${replace}') in file: ${file}"
      fi
    else
        warn "File '${file}' does not exist (thus, cannot replace '${search}' with '${replace}')."
    fi
  done

}