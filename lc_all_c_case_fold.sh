#!/bin/bash

## PITFALL: LC_ALL=C silently breaks case-insensitive matching of non-ASCII text.
##
## Setting `LC_ALL=C` -- the usual "make it deterministic" reflex -- forces the
## byte locale. toupper/tolower, `[[ ]]` nocasematch, and `${v,,}`/`${v^^}` then
## fold ONLY ASCII A-Z. Any accented / non-ASCII letter is compared
## case-SENSITIVELY, so two strings differing only in the case of such a letter
## are treated as a MISMATCH -- with no error.

set -o errexit
set -o nounset

## E-acute = C3 89, e-acute = C3 A9 in UTF-8. Built with printf so the source
## file stays pure ASCII.
UPPER="$(printf 'CAF\xc3\x89')"   # "CAFE" with an uppercase accented E
LOWER="$(printf 'caf\xc3\xa9')"   # "cafe" with a lowercase accented e

for loc in C C.UTF-8; do
   result="$(UPPER="${UPPER}" LOWER="${LOWER}" LC_ALL="${loc}" bash -c '
      shopt -s nocasematch
      [[ "${UPPER}" == "${LOWER}" ]] && printf MATCH || printf "no match"
   ')"
   printf 'LC_ALL=%-8s : nocasematch upper == lower -> %s\n' "${loc}" "${result}"
done

## Expected:
##   LC_ALL=C        : nocasematch upper == lower -> no match   <-- the pitfall
##   LC_ALL=C.UTF-8  : nocasematch upper == lower -> MATCH
##
## FIX: do not force LC_ALL=C on data that may be non-ASCII. Keep a UTF-8 locale
## for case- and character-class-sensitive work, and add an explicit `LC_ALL=C`
## prefix ONLY on the byte-exact commands that need it, e.g. `LC_ALL=C sort`,
## `LC_ALL=C tr`.
