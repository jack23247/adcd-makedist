#!/bin/bash
# run.sh
# Conveniently launches Hercules (V1R2)

desktop_mode=0
net_autocfg=1
prefer_x3270=1 # Only used in Desktop Mode

hash sudo 2>/dev/null || { echo "Please install \"sudo\" before running."; exit; }
hash hercules 2>/dev/null || { echo "Please install \"hercules\" before running."; exit; }
hash c3270 2>/dev/null || { echo "Please install \"c3270\" before running."; exit; }
hash tmux 2>/dev/null || { echo "Please install \"tmux\" before running."; exit; }

if [[ ! server_mode ]]; then
    hash x3270 2>/dev/null || { echo "Please install \"x3270\" before running."; exit; }
fi

if [[ $net_autocfg ]]; then
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo sysctl -w net.ipv4.conf.all.proxy_arp=1
    #sudo ufw disable
    sudo ip tuntap add tap0 mode tap user $(whoami)
    echo "Please wait..."
    sleep 3
fi

if [[ ! -d "rdr/" ]]; then
    mkdir -p rdr/
fi

if [[ ! -d "os390/" ]] || [[ ! -f "os390/mvswk1.122" ]] || [[ ! -f "os390/pr39r2.260" ]] || [[ ! -f "os390/pr39d2.261" ]]; then
    echo "Distribution files missing, please run \"makedist\"."
    exit
fi

if [[ $desktop_mode ]]; then
    gnome-terminal --tab -- hercules -f p390.cnf
    sleep 1
    if [[ $prefer_x3270 ]]; then
        x3270 127.0.0.1:3270 &
        x3270 127.0.0.1:3270 &
    else
        gnome-terminal --window --title="P/390 Operator Console" -- c3270 127.0.0.1:3270
        gnome-terminal --window --title="P/390 TSO Session Console" -- c3270 127.0.0.1:3270
    fi
else
    echo "Running P/390 in server mode..."
    tmux new-session \; send-keys 'hercules -f p390.cnf' C-m \; split-window -h \; send-keys 'sleep 1 && c3270 127.0.0.1:3270' C-m \;
fi