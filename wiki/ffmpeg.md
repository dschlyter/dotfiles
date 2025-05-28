## Basic with default settings

    ffmpeg -i input output.mp4

## Just getting into about file

    ffpmeg -i input

Or use this alias from your dotfiles to get codec, resolution and bitrate for each file

    ffinfo

## Cut a file

Check out `ffcut` utility in your dotfiles

## Reencode to smaller

From limited testing there seems to be a tradeoff between encoding speed and size. Hardware encoding is as expected faster but also bigger footprint.

Quality seems somewhat the same - but limited checks. Could play around with quality (lower is better) for additional results.

1. Fast but big (1 MB/s bitrate, 5x encoding speed)

This might be bigger than original.

    ffmpeg -i input.mp4 -vf "scale='min(1920,iw)':-2" -c:v hevc_nvenc -rc vbr -cq 28 output.mp4

2. Default (0.75 MB/s, 1x encoding speed)

Default settings may depend on input - reuse resolution for example.

    ffmpeg -i input.mp4 output.mp4

3. Good tradeoff between size and speed (0.41 MB/s 1x bitrate, 1.3x encoding speed)

    ffmpeg -i input.mp4 -vf "scale='min(1920,iw)':-2" -c:v libx264 -crf 28 output.mp4

4. Slowest but smallest (0.28 MB/s bitrate, 0.25x encoding speed)

    ffmpeg -i input.mp4 -vf "scale='min(1920,iw)':-2" -c:v libx265 -crf 28 output.mp4

## List available encoders

    ffmpeg -encoders