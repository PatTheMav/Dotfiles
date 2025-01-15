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
    local file_url=${locations[-1]}
    local decoded=$(printf "%b" "${${file_url:t}//\%/\\x}")

    local md5_hash=""
    local md5_hash_actual=""

    if [[ ${decoded:e} == (exe|bin|pkg) ]] {
        md5_hash=$(curl -s "${file_url}.xml" | sed -E -n -e 's/^<file.*md5="([^"]+)".*>/\1/p' | tr -d '\r\n')
    }

    axel --no-clobber --num-connections=5 -H ${gog_cookie} --output="${decoded}" ${file_url}

    if [[ ${md5_hash} ]] {
        if (( ${+commands[pv]} )) {
            md5_hash_actual=$(pv ${decoded} | md5sum -b)
        } else {
            md5_hash_actual=$(md5sum -b ${decoded})
        }

        md5_hash_actual="${${(s: :)md5_hash_actual}[1]}"

        if [[ ${md5_hash_actual} != ${md5_hash} ]] {
            print -u2 -PR "%F{1}MD5 hash mismatch of downloaded file!"
            exit 2
        }
    }
}
