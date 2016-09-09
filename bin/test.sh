#!/bin/bash

FILE="/tmp/rake.out"


parse() {
  while read CMD; do
  printf "%s\n" "$CMD"
  done < "$FILE"
}

parse
