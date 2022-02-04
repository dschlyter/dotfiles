# SSH 
## port forward

    ssh -L local_port:remove_ip:remote_port server

Example, forward 8081 locally to 8080

    ssh -L 8081:localhost:8080 server_name