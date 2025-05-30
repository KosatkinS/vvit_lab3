FROM kalilinux/kali-rolling

RUN apt-get update 
RUN apt-get install -y --no-install-recommends \
    kali-linux-headless \
    nmap \
    curl \
    ffmpeg \
    iproute2

USER root
WORKDIR /root