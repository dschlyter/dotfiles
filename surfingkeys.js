// Load from: https://jsapp.dschlyter.se/public/surfingkeys.js
// Mirror of: https://raw.githubusercontent.com/dschlyter/dotfiles/master/surfingkeys.js

// Coolest stuffs to remember
/*
alt-t - toggle

E R - switch tabs
<< >> - reorder tabs
alt-p - pin tab
. - repeat

cf - open multiple links tabs
i - select input
T - select used tab
yv - select text to copy
Ctrl-i - vim editor for input
alt-m - mute tab

S D - back/forward
gu gU - up
B F - back/forward in tab history
H - text search history
X - reopen
ox - recently closed search
om - search marks
*/

// NO EMOJI!
iunmap(":");

// Unmap specific keys, on specific domains
unmap('t', /inbox.google.com/);
unmap('c', /inbox.google.com/);
unmap('g', /mail.google.com/);
unmap('c', /mail.google.com/);
unmap('.', /jira./);
unmap('i', /jira./);

// These are too common as app shortcuts, and not used much
unmap('j');
unmap('k');
unmap('e');

// Proxy keys are annoying
unmap('spa')
unmap('spb')
unmap('spd')
unmap('sps')
unmap('spc')
unmap('sfr')

// New key for toggle surfingkeys
map('K', '<Alt-s>');

// Disable surfingkeys for a second (allows for escaping application shortcuts)
mapkey('-', 'Escape', function() {
    toggleBlacklistSilent();
    setTimeout(function() { toggleBlacklistSilent(); }, 1000);
});

// Copy of the source code to toggle surfingkeys, but avoid showing popup https://github.com/brookhong/Surfingkeys/blob/master/content_scripts/normal.js#L351
// This depends on internal details and may break in the future
function toggleBlacklistSilent() {
    runtime.command({
        action: 'toggleBlacklist',
        blacklistPattern: (runtime.conf.blacklistPattern ? runtime.conf.blacklistPattern.toJSON() : "")
    });
}

// Enable ctrl-c
vmapkey('<Ctrl-c>', 'Abort', function() {
    Visual.exit();
});

imapkey('<Ctrl-c>', 'Abort', function() {
    document.activeElement.blur();
});

// Settings
settings.incsearch = true;

// Debug shortcut
mapkey('<Ctrl-t>', 'Abort', function() {
    window.settings = settings;
    console.log(settings)
    Front.showPopup(Object.keys(settings).join(" "));
});

// set theme (dark theme)
settings.theme = `
.sk_theme {
        background: #000;
            color: #fff;
}
.sk_theme tbody {
        color: #fff;
}
.sk_theme input {
        color: #d9dce0;
}
.sk_theme .url {
        color: #2173c5;
}
.sk_theme .annotation {
        color: #38f;
}
.sk_theme .omnibar_highlight {
        color: #fbd60a;
}
.sk_theme ul>li:nth-child(odd) {
        background: #1e211d;
}
.sk_theme ul>li.focused {
        background: #4ec10d;
}`;
