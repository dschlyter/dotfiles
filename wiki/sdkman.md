Sdkman feels like a terrible hack

# Use a sdk and remember it in that dir

    sdk use java 11.0.18-amzn
    sdk env init

(You need to delete this file and re-run if you change java version - very good indead)

# Clear it 

Seems to be no good built in command for this.

    rm .sdkmanrc

# List installed and available

    sdk list java

# Set global default

    sdk default java 17.0.6-amzn