FROM ubuntu:24.04

RUN apt-get update && apt-get install -y sudo git vim zsh python3 python3-pip curl wget lsb-release tmux
RUN apt-get clean all

RUN mkdir -p /opt/app

WORKDIR /opt
RUN git clone https://github.com/dschlyter/dotfiles
WORKDIR /opt/dotfiles
RUN ./install.sh --no-zsh

WORKDIR /opt/app

CMD ["zsh"]

# commands added afterwards
RUN apt install -y yq
RUN apt install -y python-is-python3
