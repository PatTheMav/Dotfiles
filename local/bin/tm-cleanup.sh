#!/bin/zsh
# -*- coding: utf-8; tab-width: 2; indent-tabs-mode: nil; sh-basic-offset: 2; sh-indentation: 2; -*- vim:fenc=utf-8:et:sw=2:ts=2:sts=2
#
# Copyright (C) 2016-2017 Enrico M. Crisostomo
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
setopt local_options
setopt local_traps
unsetopt glob_subst

set -o errexit
set -o nounset

PROGNAME=$0
VERSION=2.1.1

# Define an integer variable to store the deletion threshold for each mode.
# Default: 30 days
# Default: 7 backups
typeset -i DAYS_TO_KEEP=30
typeset -i NUMBER_TO_KEEP=7
typeset -i DRY_RUN=0
typeset -i FORCE_EXECUTION=0
# Execution modes
#   - 0: number of days
#   - 1: number of backups
typeset -ri MODE_DAYS=1
typeset -ri MODE_BACKUPS=2
typeset -ri MODE_SHOW_BACKUPS=4
typeset -ri MODE_UNKNOWN=0
typeset -i EXECUTION_MODE=${MODE_UNKNOWN}
typeset -i ARGS_PROCESSED=0
typeset -a TM_BACKUPS
typeset -i TM_BACKUPS_LOADED=0
typeset -a TM_DIALOG_OPTS=( --backtitle "Time Machine Cleanup" )
typeset -a TM_DIALOG_CMD=( dialog ${TM_DIALOG_OPTS} )
typeset -a TM_OPERATIONS=( D "Delete backups" E "Exit" )
typeset -A TM_OPERATION_NAMES=( D "Delete backups" E "Exit" )

typeset -ri DIALOG_OK=0
typeset -ri DIALOG_CANCEL=1
typeset -ri DIALOG_HELP=2
typeset -ri DIALOG_EXTRA=3
typeset -ri DIALOG_ITEM_HELP=4
typeset -ri DIALOG_ESC=255
typeset -r TM_ERR_TEMP_FILE=$(mktemp)

trap 'tm_cleanup' INT TERM EXIT

zshexit()
{
  exec 3>&-
}

tm_cleanup()
{
  rm -f ${TM_ERR_TEMP_FILE}
}

tm_check_required_programs()
{
  command -v tmutil > /dev/null 2>&1 ||
    {
      >&2 print -- Cannot find tmutil.
      exit 1
    }
}

print_usage()
{
  print -- "${PROGNAME} ${VERSION}"
  print
  print -- "Usage:"
  print -- "${PROGNAME} (-d days | -n number) [-f] [-x]"
  print -- "${PROGNAME} [-h]"
  print
  print -- "Options:"
  print -- " -d         Number of days to keep."
  print -- " -f         Force execution even if a Time Machine backup is in progress."
  print -- " -h         Show this help."
  print -- " -n         Number of backups to keep."
  print -- " -s         Show backups."
  print -- " -x         Perform a dry run."
  print
  print -- "Report bugs to <https://github.com/emcrisostomo/Time-Machine-Cleanup>."
}

parse_opts()
{
  while getopts ":hd:fn:sx" opt
  do
    case $opt in
      h)
        print_usage
        exit 0
        ;;
      d)
        DAYS_TO_KEEP=${OPTARG}
        EXECUTION_MODE=$((MODE_DAYS | EXECUTION_MODE))
        ;;
      f)
        FORCE_EXECUTION=1
        ;;
      n)
        NUMBER_TO_KEEP=${OPTARG}
        EXECUTION_MODE=$((MODE_BACKUPS | EXECUTION_MODE))
        ;;
      s)
        EXECUTION_MODE=$((MODE_SHOW_BACKUPS))
        ;;
      x)
        DRY_RUN=1
        ;;
      \?)
        >&2 print -- "Invalid option -${OPTARG}."
        exit 1
        ;;
      :)
        >&2 print -- "Missing argument to -${OPTARG}."
        exit 1
        ;;
    esac
  done

  ARGS_PROCESSED=$((OPTIND - 1))
}

tm_validate_backup_dates()
{
  # As a safety precaution, just check that the output format has not changed.
  # If it has, let's not proceed.
  for i in ${TM_BACKUPS}
  do
    local TM_DATE=$(basename $i)

    if [[ ! ${TM_DATE} =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}$" ]]
    then
      >&2 print -- "Unexpected snapshot name: ${TM_DATE}."
      >&2 print -- "Aborting."
      exit 8
    fi
  done
}

process_by_days()
{
  (( ${DAYS_TO_KEEP} > 0 )) ||
    {
      >&2 print -- "The number of days to keep must be positive."
      exit 2
    }

  tm_validate_backup_dates

  # Establish the threshold date before which backups will be deleted
  THRESHOLD_DATE=$(date -j -v-${DAYS_TO_KEEP}d +"%Y-%m-%d")

  for i in ${TM_BACKUPS}
  do
    local TM_DATE=$(basename $i)

    if [[ ${THRESHOLD_DATE} > ${TM_DATE} ]]
    then
      if [[ ${i} != ${TM_BACKUPS[-1]} ]]
      then
        print -- "${TM_DATE} will be deleted."

        if (( ${DRY_RUN} == 0 ))
        then
          tmutil delete -t ${i} -d "$MACHINE_DIR"
        fi
      else
        print -- "${TM_DATE} will not be deleted because it is the latest available Time Machine snapshot."
      fi
    fi
  done
}

process_by_backups()
{
  (( ${NUMBER_TO_KEEP} > 0 )) || {
    >&2 print -- "The number of backups to keep must be positive."
    exit 2
  }

  if (( ${NUMBER_TO_KEEP} >= ${#TM_BACKUPS} ))
  then
    exit 0
  fi

  typeset -i LAST_IDX=$(( ${#TM_BACKUPS} - ${NUMBER_TO_KEEP} ))

  for i in $(seq 1 ${LAST_IDX})
  do
    if [[ ${i} != ${TM_BACKUPS[-1]} ]]
    then
      print -- "${TM_BACKUPS[i]:t} will be deleted."

      if (( ${DRY_RUN} == 0 ))
      then
        tmutil delete -t ${TM_BACKUPS[i]} -d "$MACHINE_DIR"
      fi
    else
      print -- "${TM_DATE} will not be deleted because it is the latest available Time Machine snapshot."
    fi
  done
}

tm_health_checks()
{
  tm_check_required_programs

  MACHINE_DIR=$(tmutil machinedirectory)
  if [[ -z "$MACHINE_DIR" ]]; then
    echo "failed to set the machine directory for tmutil"
    exit 3
  fi

  (( $# == 0 )) || {
    >&2 print -- "No arguments are allowed."
    exit 2
  }

  (( ${EUID} == 0 )) || {
    >&2 print -- "This command must be executed with super user privileges."
    exit 1
  }

  if (( ${FORCE_EXECUTION} == 0 )); then
    if tmutil status | grep -E -q 'Starting|PreparingSourceVolumes|FindingChanges|Copying|ThinningPostBackup'; then
      print -- "A Time Machine backup is being performed. Skipping execution." >&2
      exit 4
    fi
  fi

  # Check if a backup is running and if it is, skip execution.
  # This check relies on the undocumented tmutil `status' verb.
  if (( ${FORCE_EXECUTION} == 0 )) && tmutil status | grep -E -q 'Starting|PreparingSourceVolumes|FindingChanges|Copying|ThinningPostBackup';
  then
    >&2 print -- "A Time Machine backup is being performed.  Skip execution."
    exit 4
  fi

  if (( EXECUTION_MODE & (EXECUTION_MODE - 1) ))
  then
    >&2 print -- "Only one mode can be specified.  Exiting."
    exit 2
  fi
}

tm_clear_backup_status()
{
  TM_BACKUPS_LOADED=0
  TM_LOAD_BACKUPS_STATUS=0
  TM_BACKUPS=( )
}

tm_load_backups()
{
  if (( TM_BACKUPS_LOADED > 0 ))
  then
    return
  fi

  # Get the full list of backups from tmutil
  if TMUTIL_OUTPUT=$(tmutil listbackups 2> ${TM_ERR_TEMP_FILE})
  then
    TM_BACKUPS=( "${(ps:\n:)$(tmutil listbackups -t)}" )

    # We are sorting the output of tmutil listbackups because its documentation
    # states nowhere that the output is sorted in any way.
    TM_BACKUPS=( ${(n)TM_BACKUPS} )

    TM_BACKUPS_LOADED=1
    TM_LOAD_BACKUPS_STATUS=0
  else
    TM_BACKUPS_LOADED=0
    TM_LOAD_BACKUPS_STATUS=1
  fi
}

tm_start_batch()
{
  tm_load_backups

  case ${EXECUTION_MODE} in
    ${MODE_DAYS})
      process_by_days
      ;;
    ${MODE_BACKUPS})
      process_by_backups
      ;;
    ${MODE_SHOW_BACKUPS})
      tmutil listbackups
      ;;
    *)
      >&2 print -- "Unexpected mode.  Exiting."
      exit 4
      ;;
  esac
}

tm_show_last_error()
{
  tm_show_dialog \
    --title "Error" \
    --msgbox "$(cat ${TM_ERR_TEMP_FILE})" 0 0
}

tm_delete_backups()
{
  local -a backup_idx_to_delete=( ${=*} )

  if (( ${#backup_idx_to_delete} == 0 ))
  then
    return
  fi

  if (( ${#backup_idx_to_delete} == ${#TM_BACKUPS} ))
  then
    tm_show_dialog \
      --title "Invalid choice" \
      --msgbox "At least one backup must be kept." 0 0
    return
  fi

  {
    for ((i = 1 ; i <= ${#backup_idx_to_delete} ; i += 1))
    do
      # TODO: needs to be updated for macOS Sonoma 
      if ! tmutil delete ${TM_BACKUPS[${i}]} 2> ${TM_ERR_TEMP_FILE}
      then
        tm_show_last_error
      fi
      print -- $(( $i * 100 / $# ))
    done
  } | ${TM_DIALOG_CMD} \
        --title "Deleting backups" \
        --gauge "Please wait while Time Machine backups are being deleted..." 0 0 0

  tm_clear_backup_status
}

tm_confirm_delete_backups()
{
  tm_show_dialog \
    --title "Confirmation" \
    --yesno "Are you sure you want to delete the selected Time Machine backups?" 0 0

  case ${TM_DLG_LAST_STATUS} in
    ${DIALOG_OK})
      tm_delete_backups $*
      ;;
  esac
}

tm_open_delete_dialog()
{
  tm_load_backups

  if (( TM_LOAD_BACKUPS_STATUS != 0 ))
  then
    tm_show_last_error
    return
  fi

  local -a tm_backup_items

  # Populate the list in descreasing order
  for i in $(seq ${#TM_BACKUPS} 1)
  do
    tm_backup_items+=${i}
    tm_backup_items+=${TM_BACKUPS[${i}]}
    tm_backup_items+=on
  done

  # Always disable the first element
  tm_backup_items[3]=off

  tm_show_dialog \
    --title ${TM_OPERATION_NAMES[D]} \
    --checklist "Select the backups to delete" 0 0 \
    ${#TM_BACKUPS} ${tm_backup_items}

  case ${TM_DLG_LAST_STATUS} in
    ${DIALOG_OK})
      tm_confirm_delete_backups ${TM_DLG_LAST_RET}
      ;;
  esac
}

tm_show_dialog()
{
  set +o errexit

  TM_DLG_LAST_RET=$( ${TM_DIALOG_CMD} $* 2>&1 1>&3 )
  TM_DLG_LAST_STATUS=$?

  set -o errexit
}

tm_open_operation()
{
  case $1 in
    D)
      tm_open_delete_dialog
      ;;
    E)
      exit 0
      ;;
    *)
      >&2 print -- "Unknown operation $1.  This is a bug."
      exit 1
      ;;
  esac
}

tm_start_dialog()
{
  command -v dialog > /dev/null 2>&1 ||
    {
      >&2 print -- "dialog is required to use the interactive mode."
      exit 1
    }

  exec 3>&1

  while true
  do
    tm_show_dialog \
      --no-cancel \
      --title "Main Menu" \
      --menu "Select the operation to perform" 0 0 \
      ${#TM_OPERATIONS} ${TM_OPERATIONS}

    case ${TM_DLG_LAST_STATUS} in
      ${DIALOG_OK})
        tm_open_operation ${TM_DLG_LAST_RET}
        ;;
      *)
        break
        ;;
    esac
  done
}

# Main
parse_opts $* && shift ${ARGS_PROCESSED}

tm_health_checks

if (( ${EXECUTION_MODE} == ${MODE_UNKNOWN} ))
then
  tm_start_dialog
else
  tm_start_batch
fi

# Local variables:
# coding: utf-8
# mode: sh
# eval: (sh-set-shell "zsh")
# tab-width: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# sh-indentation: 2
# End:
