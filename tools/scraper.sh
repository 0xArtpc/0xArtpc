#!/bin/bash

# Web URLs scraper, usage ./scraper.sh <URL> <Wordlist>

echo "[+] Welcome to scraper [+]"
# rm index.html* fileList* gobuster* subdomains*

if [[ $1 == "" || $2 == "" ]]; then
   echo "\nSyntax error"
   echo "\n./scraper.sh <URL> <WordlistPath>"
else
   if ! command -v gobuster &> /dev/null; then
      apt install gobuster -y
   else
      domain=$(echo "$1" | awk -F"//" '{print $2}')
      [ ! -d $domain ] && mkdir $domain
      cd $domain
      # /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
      gobuster dir -w $2 -u $1 -x html,php,js -o gobuster.txt
      cut -d ' ' -f1 gobuster.txt > fileList.txt
      files="fileList.txt"
      mkdir -p webFiles

      while IFS= read -r file; do
          wget "$1/$file" -P webFiles/
      done < "$files"
      echo "$1$file"
      grep href webFiles/* | awk -F"//" '{print $2}' | cut -d '/' -f1 | grep $1 | cut -d '"' -f1 | sort | uniq  > subdomains.txt
      clear
      echo "[+] Subdomains found [+]"
      cat subdomains.txt
      rm gobuster.txt fileList.txt 
   fi
fi
