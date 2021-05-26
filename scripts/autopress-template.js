// What this does:
// Runs in the background and presses buttons

// How to install
// Chrome: Cmd-Option-C -> Sources tab -> Snippets tab (might be under >> icon) -> Create new snippet called "autogoalie"
// Other browsers: This is just some javascript, find a way to run a javascript snipped on any page in your browser.

// How to run:
// Chrome: Cmd-Option-C -> Cmd-P -> !autogoalie

// Indicate that the script is running in this tab
document.title = "🤖" + document.title

const greenButtonCssClass = "btn-primary";
let branchUpdateCount = 0;
let periodicCheck = setInterval(autoPress, 20 * 1000);
autoPress();
log("running!")

function autoPress() {
    let button = findButtonWithTextAndClass("Click me!", "btn-primary")

    if (button) {
        doThings(button)
    } else {
        log("did not find button")
    }
}

function doThings(aButton) {
    aButton.click()
}

function findButtonWithTextAndClass(buttonText, buttonClass) {
    let matches = [...document.querySelectorAll('button')].filter(btn => btn.innerText.trim() === buttonText && btn.classList.contains(buttonClass))
    if (matches.length === 1) {
        return matches[0]
    }
    return null;
}

function log(msg) {
    console.log(new Date().toISOString(), "Autopresser", msg)
}
