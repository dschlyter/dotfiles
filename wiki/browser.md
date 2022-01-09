## Video speed improvement

There are plugins, but otherwise:

    document.querySelectorAll("video").forEach(x => x.playbackRate = 3)

Or quicker, if there is only one video

    document.querySelector("video")playbackRate = 3