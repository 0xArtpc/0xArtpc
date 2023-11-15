# Tomcat

## Recon

### Port Scan

`nmap tomcat.thm -A -sCV -T4 -oN nmap.txt`

![Untitled](images/Untitled.png)

## Web

Found tomcat exploit

### Tomcat exploit CVE-2020-1938

`python2 ex.py 10.10.43.143 -p 8009 -f WEB-INF/web.xml`

![Untitled](images/Untitled%201.png)

### SSH

Using the above credentials

![Untitled](images/Untitled%202.png)

### GPG Key’s

![Untitled](images/Untitled%203.png)

![Untitled](images/Untitled%204.png)

### Decrypt credentials.gpg

![Untitled](images/Untitled%205.png)

Change user to merlin

![Untitled](images/Untitled%206.png)

### ZIP as Sudo

![Untitled](images/Untitled%207.png)

![Untitled](images/Untitled%208.png)

### Root flag

We tried to decrypt root’s hash but it take some time, so while that we saw that we could run ZIP as root

![Untitled](images/Untitled%209.png)
