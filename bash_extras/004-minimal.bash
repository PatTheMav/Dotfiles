MNML_OK_COLOR=${MNML_OK_COLOR:-$(tput setaf 2)}
MNML_ERR_COLOR=${MNML_ERR_COLOR:-$(tput setaf 7)}

MNML_USER_CHAR=${MNML_USER_CHAR:-'λ'}
MNML_INSERT_CHAR=${MNML_INSERT_CHAR:-'›'}

# GIT-INFO style settings
MNML_CLEAN_COLOR=${MNML_CLEAN_COLOR:-$(tput setaf 2)}
MNML_DIV_COLOR=${MNML_DIV_COLOR:-$(tput setaf 5)}
MNML_DIRTY_COLOR=${MNML_DIRTY_COLOR:-$(tput setaf 1)}
MNML_BEHIND_COLOR=${MNML_BEHIND_COLOR:-$(tput setaf 11)}
MNML_AHEAD_COLOR=${MNML_AHEAD_COLOR:-$(tput setaf 11)}

MNML_AHEAD_CHAR=${MNML_AHEAD_CHAR:-'↑'}
MNML_BEHIND_CHAR=${MNML_BEHIND_CHAR:-'↓'}
MNML_DIRTY_CHAR=${MNML_DIRTY_CHAR:-''}
MNML_CLEAN_CHAR=${MNML_CLEAN_CHAR:-''}
MNML_DIV_CHAR=${MNML_DIV_CHAR:-''}

function __prompt_setup() {
    function __minimal_cwd() {
      function join { local IFS="$1"; shift; echo "$*"; }
      local segments="${1:-2}"
      local seg_len="${2:-0}"

      if [ "${segments}" -le 0 ]; then
        segments=1
      fi

      if [ "${seg_len}" -gt 0 ] && [ "${seg_len}" -lt 4 ]; then
        seg_len=4
      fi

      local seg_hlen=$((seg_len / 2 - 1))

      local cwd="$(pwd | sed "s|^$HOME|~|")"
      # cwd=$(basename $(dirname $cwd))/$(basename $cwd)
      cwd=$(echo ${cwd} | rev | cut -f1,2 -d'/' - | rev)
      cwd=($(echo ${cwd} | tr "/" " "))

      local pi=""

      for i in ${!cwd[@]}; do
        if [ "${i}" -gt 0 ]; then
          pi="${cwd[$i]}"
          if [ "${seg_len}" -gt 0 ] && [ "${#pi}" -gt "${seg_len}" ]; then
            cwd[$i]="${pi:0:$seg_hlen}..${pi: -$seg_hlen}"
          fi
        fi
      done

      local result=$(join / ${cwd[@]})
      echo -n "${result:-/}"
    }

    function short_pwd () {
        local current_dir="${1:-${PWD}}"
        local return_dir='~'
        current_dir="${current_dir/#${HOME}/~}"
        if [ $current_dir == $HOME ]; then echo -n "~"; return; fi
        if [ $current_dir == "/" ]; then echo -n "/"; fi

        for l in $(echo $current_dir | tr "/" "\n"); do
            [[ "$l" != "~" ]] && echo -n "/"
            [[ "${l:0:1}" == "." ]] && echo -n ${l:0:2} || echo -n ${l:0:1}
            # echo -n ${l:0:1}
        done
        [[ "${l:0:1}" == "." ]] && echo -n ${l:2} || echo -n ${l:1}
    }

    function __minimal_setup() {
      root_char="#"
      on_color="${MNML_OK_COLOR}"
      off_color="${MNML_ERR_COLOR}"
      err_color="${MNML_ERR_COLOR}"
      reset_color="$(tput sgr0)"
      git_dirty="${MNML_DIRTY_COLOR}"
      git_clean="${MNML_CLEAN_COLOR}"
      git_behind="${MNML_BEHIND_COLOR}"
      git_ahead="${MNML_AHEAD_COLOR}"
      underline="$(tput smul)"
      underline_reset="$(tput rmul)"
    }

    function __minimal_preexec() {
        function prompt_left() {
            # echo -n "$(__minimal_user)$(__minimal_jobs)$(__minimal_status) "
            echo -n "$(__minimal_status)$(__minimal_jobs)$(__minimal_user) "
        }

        function prompt_right() {
            #echo -n "$(__minimal_path)$(__minimal_git) "
            echo -n "${rprompt}"
        }

        export rprompt="$(__minimal_path) $(__minimal_git)"
        local rprompt_clean=$(sed -E 's:\\\[([^\\]|\\[^]])*\\\]::g' <<<"$rprompt")

        PS1=$(printf "%$((COLUMNS + ${#rprompt} - ${#rprompt_clean} - 1))s\r%s" "$rprompt" "$(prompt_left)")
        export PS1
    }

    function __minimal_user() {
        [ ${UID} -eq 0 ] && echo -n "$root_char" || echo -n "${MNML_USER_CHAR}"
        echo -n "\[$reset_color\]\[$underline_reset\] ${MNML_INSERT_CHAR}"
    }

    function __minimal_jobs() {
        [ $(jobs -l | wc -l) -gt 0 ] && echo -n "\[$underline\]" || echo -n ""
        # echo -n "$prompt_char\[$reset_color\]"
    }

    function __minimal_status() {
        [[ $RETVAL > 0 ]] && echo -n "\[$err_color\]" || echo -n "\[$on_color\]"
        # echo -n "$prompt_char\[$reset_color\]"
    }

    function __minimal_path() {
        local path_color=$(tput setaf 8)
        local sep="\\\[$reset_color\\\]/\\\[$path_color\\\]"

        echo -n "\[$path_color\]$(sed s_/_${sep}_g <<< $(__minimal_cwd))\[$reset_color\]"
    }

    function __git_branch_name() {
      local branch_name="$(command git rev-parse --abbrev-ref HEAD 2> /dev/null)"
      [[ -n $branch_name ]] && echo -n "$branch_name"
    }

    function __git_branch_name() {
      local branch_name="$(command git rev-parse --abbrev-ref HEAD 2> /dev/null)"
      [[ -n $branch_name ]] && echo -n "$branch_name"
    }

    function __git_repo_status(){
      local rs="$(command git status --porcelain -b)"

      if $(echo -n "$rs" | grep -v '^##' &> /dev/null); then # is dirty
        echo -n "\[$git_dirty\]${MNML_DIRTY_CHAR} "
      elif $(echo -n "$rs" | grep '^## .*diverged' &> /dev/null); then # has diverged
        echo -n "\[$git_dirty\]${MNML_DIV_CHAR} "
      elif $(echo -n "$rs" | grep '^## .*behind' &> /dev/null); then # is behind
        echo -n "\[$git_behind\]${MNML_BEHIND_CHAR} "
      elif $(echo -n "$rs" | grep '^## .*ahead' &> /dev/null); then # is ahead
        echo -n "\[$git_ahead\]${MNML_AHEAD_CHAR} "
      else # is clean
        echo -n "\[$git_clean\]${MNML_CLEAN_CHAR} "
      fi
    }

    function __minimal_git() {
      local bname=$(__git_branch_name)
      if [[ -n ${bname} ]]; then
        local infos="$(__git_repo_status)${bname}\[$reset_color\]"
        echo -n " $infos"
      fi
    }

    function _render_prompt() {
        RETVAL=$?
        __minimal_preexec
    }

    __minimal_setup

    if [[ ! $PROMPT_COMMAND == *_render_prompt* ]]; then
        export PROMPT_COMMAND="_render_prompt; $PROMPT_COMMAND"
    fi
}

__prompt_setup
unset __prompt_setup
