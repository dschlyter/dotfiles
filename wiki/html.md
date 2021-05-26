*Warning:* I'm not a frontend dev so this page might have tips that are bad or outdated.

## Javascript links

If you are building a real site then you should create real links to go to meaningful locations.
This allows the user to use history, share links, etc. It is just good practice.

However for quicker hacks it can be useful to just have a "link" that executes JS without messing with the path.

For this avoid `<a>` and instead use `<span class="link" onclick=.../>`. Then add some css.

    .link {
        cursor:pointer;
        color:blue;
        text-decoration:underline;
    }
    .link:hover {
        text-decoration:none;
    }

## CSS units

Don't use `px`. Use `rem` for margins, `ex`/`em` for font distances and `vw`/`vw` for viewpot

From MDN

* em	Font size of the parent, in the case of typographical properties like font-size, and font size of the element itself, in the case of other properties like width.
* ex	x-height of the element's font. (height of the letter 'x' in the font)
* ch	The advance measure (width) of the glyph "0" of the element's font.
* rem	Font size of the root element.
* lh	Line height of the element.
* vw	1% of the viewport's width.
* vh	1% of the viewport's height.
* vmin	1% of the viewport's smaller dimension.
* vmax	1% of the viewport's larger dimension.