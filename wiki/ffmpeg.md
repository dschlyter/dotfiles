## Basic with default settings

    ffmpeg -i input output.mp4

## Just getting into about file

    ffpmeg -i input

Or use this alias from your dotfiles to get codec, resolution and bitrate for each file

    ffinfo

## Reencode to smaller

    ffmpeg -i input.mp4 -vf "scale='min(1920,iw)':-2" -c:v hevc_nvenc -preset slow -rc vbr -cq 28 -c:a aac -b:a 128k output.mp4

## List available encoders

    ffmpeg -encoders