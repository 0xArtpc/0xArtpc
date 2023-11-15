# MrRobot

## Recon

### Port Scan

`nmap -sC -sV -O -oN nmap mrrobot.thm`

![Untitled](images/Untitled.png)

Found a wordlist

![Untitled](images/Untitled%201.png)

`ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://mrrobot.thm/FUZZ -fs 1188 -o directory.dir`

![Untitled](images/Untitled%202.png)

By trying we could enumerate the username very easy

![Untitled](images/Untitled%203.png)

![Untitled](images/Untitled%204.png)

By finding the wordlist behind we can use hydra to brute-force the password

After getting the password

Reverse shell in a page that doesn’t exists, so when its loads the page `.404` it runs the shell

![Untitled](images/Untitled%205.png)

![Untitled](images/Untitled%206.png)

### Linux privilege escalation

Linux 3.13.0-55-generic ubunto x86_64

Ubuntu 4.8.2-19

`cat /etc/passwd`

![Untitled](images/Untitled%207.png)

Find files with SUID

`find / -type f -perm -4000 2>/dev/null`

![Untitled](images/Untitled%208.png)

Found nmap on SUID perm

![Untitled](images/Untitled%209.png)
