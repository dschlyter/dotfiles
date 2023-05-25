# The missing console.log...

A dirty hack

        <script>
            let origLog = console.log
            console.log = (...args) => {
                origLog(...args)
                let e = document.getElementById("errorLog")
                let msg = ""
                for (let p of args) {
                    msg += p + " "
                }
                e.innerText += "\n" + msg;
            }
        </script>
        <div id="errorLog"></div>