# THM - Team

## Starting

Add the machine ip to /etc/hosts

![Untitled](images/Untitled.png)

## Recon

Finding much information as we can

### Port scan

Scan using scripts and find service version, then save the output as “nmap” of the domain team.thm

`nmap -sC -sV -oN nmap team.thm`

![Untitled](images/Untitled%201.png)

### Finding Web Directories ( 80 )

Uses a wordlist to do a subdomain discover filtering 374 lines because its the error pattern 

`ffuf -u http://team.thm/ -H "Host: FUZZ.team.thm" -w /usr/share/wordlists/assetNotes/subdomain.txt -fl 374`

Found 3 subdomains but probably only 2 work

![Untitled](images/Untitled%202.png)

Adding to `/etc/hosts`

![Untitled](images/Untitled%203.png)

## Dev.team.thm

![Untitled](images/Untitled%204.png)

Some parameter

![Untitled](images/Untitled%205.png)

LFI vulnerabilitie, that allow us to read other files from the system

![Untitled](images/Untitled%206.png)

When used the extention wappalyzer to look the the technology running there is apache running

![Untitled](images/Untitled%207.png)

I tried to make some log poisoning but couldn’t read the logs so we the next thing to do was searching the `team.thm`

## Team.thm

### Discovering directories

`ffuf -u http://team.thm/FUZZ -w /usr/share/wordlists/secLists/web/directory-list-lowercase-2.3-medium.txt -fw 140`

![Untitled](images/Untitled%208.png)

Forbidden but can be some files that we could read

![Untitled](images/Untitled%209.png)

Found script.txt

![Untitled](images/Untitled%2010.png)

![Untitled](images/Untitled%2011.png)

When we download the script.old we get FTP credentials

`ftpuser:T3@m$h@r3`

![Untitled](images/Untitled%2012.png)

## FTP

Using the credentials found before we can login to FTP

![Untitled](images/Untitled%2013.png)

Getting the file

![Untitled](images/Untitled%2014.png)

Reading the file

![Untitled](images/Untitled%2015.png)

That is some hint to LFI related to ID_RSA

When we made bruteforce on the LFI field `ffuf -u http://dev.team.thm/script.php?page=FUZZ -w /usr/share/wordlists/generic/LFI-linux.txt -fl 2`

There is some `SSH` files

![Untitled](images/Untitled%2016.png)

Inside the `dev.team.thm` we can open that file and here we have the `id_rsa key`

![Untitled](images/Untitled%2017.png)

Copy the text and open in some code editor

![Untitled](images/Untitled%2018.png)

Now remove the comments and login with ssh

`ssh -i id_rsa dale@10.10.214.132`

![Untitled](images/Untitled%2019.png)

![Untitled](images/Untitled%2020.png)

## Getting next user

Here we saw that its possible to run the `admin_checks` file using the user gyles

![Untitled](images/Untitled%2021.png)

Reading the file

![Untitled](images/Untitled%2022.png)

While reading the code, we can run linux commands inside the file 

`sudo -u gyles /home/gyles/admin_checks`

After running the file the first input we can set something random and the next one i used `bash` and some command like `id` and we run everything as gyle

## Getting root

`cat .bash_history` to verify what has been done before us

![Untitled](images/Untitled%2023.png)

### Interesting files

`/opt/admin_checks/script.sh` is running some files to make a backup, and its running as root

![Untitled](images/Untitled%2024.png)

It’s running this `main_backup.sh` and we can change the content of it

![Untitled](images/Untitled%2025.png)

Setting a reverse shell

![Untitled](images/Untitled%2026.png)

Inside the atacker machine

![Untitled](images/Untitled%2027.png)

Finishing the challange

![Untitled](images/Untitled%2028.png)
