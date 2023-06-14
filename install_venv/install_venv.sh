sudo apt-get install -y python3-dev python3-pip python3-testresources
sudo pip install virtualenv virtualenvwrapper
echo "installing virtualenvironment"

echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/$(python3 -V | cut -d " " -f 2 | cut -d . -f 1,2)" >> ~/.bashrc
echo "export WORKON_HOME=$HOME/pyenvs" >> ~/.bashrc
echo "export PROJECT_HOME=$HOME/projects" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc


source ~/.bashrc

# mkvirtualenv test
# workon test
# pip install -U numpy

echo "Installation was finished."
