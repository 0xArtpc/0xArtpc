# HTB - Analytics

## Recon

Gain much information as you can to hack the machine

### Port scanning

`nmap -sC -sV -oN nmap $Machine-IP` Does a port scanning with default scripts, show the version of the services and saves the output as `nmap`

![Untitled](images/Untitled.png)

Here we can see that redirects to `analytical.htb` so we put that to `/etc/hosts`

### Sudomain enumeration

Subdomain fuzzing changing the `FUZZ` by the single word inside the wordlist filtering the lines to 8 so doesn’t spam the errors

`ffuf -u http://analytical.htb/ -H "Host: FUZZ.analytical.htb" -w /usr/share/wordlists/assetNotes/subdomain.txt -fl 8`

![Untitled](images/Untitled%201.png)

## Subdomain data.analytical.htb

![Untitled](images/Untitled%202.png)

As we look at this page we search for an exploit for this and we found this **`CVE-2023-38646`**

### CVE-2023-38646

The token used can be found on this endpoint `http://data.analytical.htb/api/session/properties`

![Untitled](images/Untitled%203.png)

[https://github.com/m3m0o/metabase-pre-auth-rce-poc](https://github.com/m3m0o/metabase-pre-auth-rce-poc)

After that used some reverse shell to get access to the machine, in this case i used `bash`

![Untitled](images/Untitled%204.png)

Got access to the machine

![Untitled](images/Untitled%205.png)

## Escalating privileges

### Recon

Looking at environment variables using `env` we got some credentials

![Untitled](images/Untitled%206.png)

After that login into the machine using those creds

Here we are looking for some escalation point, like an exploit for the ubuntu version

![Untitled](images/Untitled%207.png)

Downloaded the exploit and compile inside my local machine and then send it to the victim

![Untitled](images/Untitled%208.png)

By running the exploit we got root

![Untitled](images/Untitled%209.png)
