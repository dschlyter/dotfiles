## Mounting disks

Not supported on Win 10 :@

    wmic diskdrive list brief
    wsl --mount \\.\PHYSICALDRIVE1 --bare

How it works for encrypted partions remains to be seen.

## Opening uris and files

wslview

## Accessing from another computer

Get the IP inside WSL

    ip addr

Then run cmd.exe with admin

    netsh interface portproxy add v4tov4 listenport=42001 listenaddress=0.0.0.0 connectport=42001 connectaddress=<WSL IP>
    netsh advfirewall firewall add rule name= "Open Port 42001 for WSL" dir=in action=allow protocol=TCP localport=42001