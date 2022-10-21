## Mounting disks

Not supported on Win 10 :@

    wmic diskdrive list brief
    wsl --mount \\.\PHYSICALDRIVE1 --bare

How it works for encrypted partions remains to be seen.

## Opening uris and files

wslview