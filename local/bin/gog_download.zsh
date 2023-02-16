#!/usr/bin/env zsh


if (( ! # || # < 2 )) {
    print -u2 -PR "%F{1}Usage: %B${0}%b <URL LIST> <COOKIE_FILE>%f"
    exit 2
} elif (( ! ${+commands[axel]} )) {
    print -u -PR "%F{1}${0} requires %Baxel%b%f"
}

local url_list=${1}

local gog_cookie="Cookie: $(<${2})"

local -a files=($(<${url_list}))

for file (${files}) {
    local -a locations=($(curl -s -I -L ${file} -H ${gog_cookie} | tr -d '\r' | sed -En 's/^[lL]ocation: (.*)/\1/p'))
    local decoded=$(printf "%b" "${${${locations[-1]}:t}//\%/\\x}")
    axel --no-clobber --num-connections=5 -H ${gog_cookie} --output="${decoded}" ${file}
}
