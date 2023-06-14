tar -jxvf FileZilla_3.63.1_x86_64-linux-gnu.tar.bz2
sudo mv FileZilla3 /usr/local
sudo update-alternatives --install /usr/bin/filezilla filezilla /usr/local/FileZilla3/bin/filezilla 10

DESKTOP_PATH=/usr/local/FileZilla3/share/applications/filezilla.desktop
sudo sed -i -e "s/Icon=filezilla/Icon=\/usr\/local\/FileZilla3\/share\/icons\/hicolor\/480x480\/apps\/filezilla.png/g" ${DESKTOP_PATH}
sudo cp ${DESKTOP_PATH} /usr/share/applications
echo "Done."
