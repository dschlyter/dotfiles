FROM ubuntu:24.04

# Basic image for playing around with tech. Ubuntu with useful stuff installed
# Run: docker run -it -v $(pwd):/opt/app --name whatever devplay

RUN apt-get update && apt-get install -y sudo git vim zsh python3 python3-pip curl wget lsb-release tmux
RUN apt-get clean all

RUN mkdir -p /opt/app

WORKDIR /opt
RUN git clone https://github.com/dschlyter/dotfiles && cd dotfiles && ./install.sh

WORKDIR /opt/app

CMD zsh
