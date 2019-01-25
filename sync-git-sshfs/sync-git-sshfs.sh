#!/bin/bash
# Small helper to sync a git repository on webserver without ssh shell
# Passwords in a script should only be used in exceptional cases if there is no other option
# An SSH certificate is always recommended!
# Replace entries in square brackets with appropriate values.
#
pass="[BASE64_ENCODED_PASSWORD]"
sshkey=$HOME/.ssh/[SSH_KEY_FILE]
host="[USERNAME]@[FQDN]"
target="$HOME/[MOUNTFOLDER]"
echo "$pass"|base64 --decode|sshfs -o password_stdin $host:/ $target	# Connect via sshfs with password
#sshfs -o IdentityFile=$sshkey $host:/ $target	# Connect via sshfs with certificate
cd $target/ttrss	# Move into sshfs mountpoint
git pull origin master	# Update repository
cd $HOME	# Move out otherwise unmount sshfs target is blocked
umount $target	# Unmount sshfs connection
