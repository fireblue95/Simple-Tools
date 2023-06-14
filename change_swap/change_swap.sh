sudo swapoff -a
sudo swapon --show
free -h

# For temporary
sudo dd if=/dev/zero of=/swap_file bs=1GB count=64
sudo chmod 600 /swap_file
sudo mkswap /swap_file
sudo swapon /swap_file

# For permanent
#sudo dd if=/dev/zero of=/swapfile bs=1GB count=64
#sudo chmod 600 /swapfile
#sudo mkswap /swapfile
#sudo swapon /swapfile
#-----

free -h
