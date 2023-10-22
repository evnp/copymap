#!/usr/bin/env bash
# : copymap 0.0.1 ::

set -euo pipefail

function buildmap() {
  local iptfile="" outfile=""
  iptfile="$1"
  outfile="$2"
}

function applymap() {
  local iptfile="" outfile="" mapfile="" lineno=0
  mapfile="$1"
  iptfile="$2"
  outfile="$3"

  while IFS="" read -r line || [[ -n "${line}" ]]; do
    (( lineno++ )) || true
    if [[ "${line}" =~ ^[[:space:]]*([0-9a-f]+)[[:space:]](.*)$ ]]; then
      hash="${BASH_REMATCH[1]}"
      content="${BASH_REMATCH[2]}"
      echo "hash: ${hash}"
      echo "content: ${content}"
    else
      echo "Error: Invalid map file. Line ${lineno} is invalid:"
      echo "${line}"
      exit 1
    fi
  done < "${mapfile}"
}

function copymap() {
  local iptfile="" outfile="" mapfile="" args=() arg="" argidx=0

  args=( "${@:-}" )

  while (( argidx < $# )); do
    arg="${args[argidx++]:-}"
    if [[ "${arg}" =~ ^(-m|--map)$ ]]; then
      mapfile="${args[argidx++]:-}"
    elif [[ "${arg}" =~ ^(-m=|--map=)(.*)$ ]]; then
      mapfile="${BASH_REMATCH[2]}"
    elif [[ "${arg}" =~ ^(-m)(.*)$ ]]; then
      mapfile="${BASH_REMATCH[2]}"
    elif [[ -z "${iptfile}" ]]; then
      iptfile="${arg}"
    elif [[ -z "${outfile}" ]]; then
      outfile="${arg}"
    else
      echo "Error: Too many arguments."
      exit 1
    fi
  done

  if [[ -z "${iptfile}" ]]; then
    echo "Error: No input file was specified."
    exit 1
  elif ! [[ -f "${iptfile}" ]]; then
    echo "Error: Specified input file ${iptfile} does not exist."
    exit 1
  elif [[ -n "${mapfile}" ]] && ! [[ -f "${mapfile}" ]]; then
    echo "Error: Specified mapfile ${mapfile} does not exist."
    exit 1
  fi

  if [[ -n "${outfile}" ]] && [[ -f "${outfile}" ]]; then
    read -rsn1 -p "Output file already exists · Press ENTER to overwrite · CTRL+C to cancel"$'\n\n'
  fi

  if [[ -n "${mapfile}" ]]; then
    applymap "${mapfile}" "${iptfile}" "${outfile}"
  else
    buildmap "${iptfile}" "${outfile}"
  fi
}

copymap "$@"
