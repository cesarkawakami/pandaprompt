#!/bin/bash
#
# DESCRIPTION:
#
#   Set the bash prompt according to:
#    * the active virtualenv
#    * the branch/status of the current git repository
#    * the return value of the previous command
#
# USAGE:
#
#   1. Save this file as ~/.bash_prompt
#   2. Add the following line to the end of your ~/.bashrc or ~/.bash_profile:
#        . ~/.bash_prompt
#
# LINEAGE:
#
#   Almost entirely based on work by insin: https://gist.github.com/insin/1425703
#

# The various escape codes that we can use to color our prompt.
        RED="\[\033[0;31m\]"
    DYELLOW="\[\033[0;33m\]"
     YELLOW="\[\033[1;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[1;34m\]"
      DBLUE="\[\033[0;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
     PURPLE="\[\033[0;35m\]"
       CYAN="\[\033[0;36m\]"
 COLOR_NONE="\[\e[0m\]"

# Detect whether the current directory is a git repository.
function is_git_repository {
  git rev-parse --git-dir > /dev/null 2>&1
}

# Determine the branch/state information for this git repository.
function set_git_branch {
  rev_parse="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  if [[ ${rev_parse} != "HEAD" ]]; then
    branch="${GREEN}${rev_parse}${COLOR_NONE}"
  else
    branch="${RED}<detached>${COLOR_NONE}"
  fi

  # Set the final branch string.
  BRANCH=" ${state}${branch}${remote}${COLOR_NONE}"
}

function set_last_return_value () {
    if test $1 -eq 0 ; then
        LAST_RETURN_VALUE=""
    else
        LAST_RETURN_VALUE=" ${COLOR_NONE}${LIGHT_RED}$1${COLOR_NONE}"
    fi
}

# Determine active Python virtualenv details.
function set_virtualenv () {
  if test -z "$VIRTUAL_ENV" ; then
      PYTHON_VIRTUALENV=""
  else
      PYTHON_VIRTUALENV=" ${LIGHT_GRAY}[`basename \"$VIRTUAL_ENV\"`]${COLOR_NONE}"
  fi
}

function set_date () {
    MY_DATE=" ${LIGHT_GRAY}$(date '+%Y/%m/%d %H:%M:%S.%3N')${COLOR_NONE}"
}

# Set the full bash prompt.
function set_bash_prompt () {
  # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
  # return value of the last command.
  set_last_return_value $?

  # Set the PYTHON_VIRTUALENV variable.
  set_virtualenv

  # Set the BRANCH variable.
  if is_git_repository ; then
    set_git_branch
  else
    BRANCH=''
  fi

  # Prints a date on the screen for time tracking purposes
  set_date

  # Compute which color is desired
  desired_color=${COMPUTER_COLOR:-DBLUE}
  eval desired_color=\$$desired_color

  # Set the bash prompt variable.
  export PS1="
${LIGHT_GRAY}\u${DYELLOW}@${desired_color}\h${GREEN}:${WHITE}\w${COLOR_NONE}${PYTHON_VIRTUALENV}${BRANCH}${LAST_RETURN_VALUE}${MY_DATE}
\$ "
}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt
