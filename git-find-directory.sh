#!/bin/bash

# Script per cercare ricorsivamente directory con .git e stampare l'URL del remote origin

find . -type d -name ".git" -print | while read gitdir; do
    repodir=$(dirname "$gitdir")
    url=$(git -C "$repodir" config --get remote.origin.url 2>/dev/null)
    if [ $? -eq 0 ]; then
        #echo -e "$repodir: \n\t> $url\n"
        echo
        echo -e "$repodir >>> $url\n"
    fi
done