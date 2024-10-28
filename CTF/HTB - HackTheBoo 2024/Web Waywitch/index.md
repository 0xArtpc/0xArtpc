# Web WayWitch

Since we have the source code we can inspect how the JWT is handle, and inside the client-side they provide in clear-text the secret.

![image.png](images/image.png)

Inspect the default page and view the JS code.

![image.png](images/image%201.png)

Now that we have the JWT secret copy your current JWT to make some modifications

[https://jwt.io/](https://jwt.io/)

Make sure you paste the secret and modify your user to `admin`

![image.png](images/image%202.png)

If the token is valid and we are admin the function `get_tickets()` is executed and it will retrieve all tickets

![image.png](images/image%203.png)

The data retrieved is this with the flag

![image.png](images/image%204.png)

Paste the new JWT and navigate to `/tickets`

![image.png](images/image%205.png)
