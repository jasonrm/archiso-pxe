#!/bin/bash

if [[ $(tty) != "/dev/tty1" ]]; then
    exit 0
fi

cat > /etc/resolv.conf <<DELIM
nameserver 8.8.8.8
nameserver 8.8.4.4
DELIM

mkdir -p /root/.ssh
curl -L https://github.com/jasonrm.keys -o /root/.ssh/authorized_keys

# Work around a weird issue since ArchISO 2014.12.01
mkdir -p /root/.gnupg/
touch /root/.gnupg/dirmngr_ldapservers.conf

cp /etc/pacman.conf /etc/pacman.conf.orig

# Install archiso-zfs
cat >> /etc/pacman.conf <<DELIM
[demz-repo-archiso]
Server = http://demizerone.com/\$repo/\$arch
SigLevel = Never
DELIM

pacman -Sy --noconfirm zfs-git || exit 1

# Restore original pacman config
cp /etc/pacman.conf.orig /etc/pacman.conf

# aur.atomica.net
pacman-key -r 5EF75572
pacman-key --lsign-key 5EF75572
cat >> /etc/pacman.conf <<DELIM
[atomica]
Server = http://aur.atomica.net/\$repo/\$arch
DELIM

pacman -Sy --noconfirm git mbuffer tmux sysstat ioping pv || exit 1

systemctl start sshd

git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier
export PATH="$HOME/.tmuxifier/bin:$PATH"
eval "$(tmuxifier init -)"

cat > ~/.tmuxifier/layouts/archiso.session.sh <<DELIM
if initialize_session "archiso"; then
  load_window "archiso"
fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
DELIM

cat > ~/.tmuxifier/layouts/archiso.window.sh <<DELIM
window_root "~/"
new_window "archiso"
split_v 50
run_cmd "journalctl -f"
split_v 50
run_cmd "iostat -xm 5"
split_h 40
run_cmd "watch -t 'ip addr | grep inet'"
select_pane 0
DELIM

tmuxifier load-session archiso
