# zefyr

Ecosystem toaster.

# Blank Debian GCE VM Setup

```bash
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install build-essential git curl aptitude libssl-dev \
        wget htop
    \curl -L https://install.perlbrew.pl | bash
    git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
    echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bashrc
    echo 'export PATH=~/.rakudobrew/bin:~/.rakudobrew/moar-nom/install/share/perl6/site/bin:$PATH' >> ~/.bashrc
    wget https://temp.perl6.party/.bash_aliases
    echo 'source ~/.bash_aliases' >> ~/.bashrc
    source ~/.bashrc
    perlbrew install perl-5.26.0 --notest -Duseshrplib -Dusemultiplicity
    perlbrew switch perl-5.26.0
    perlbrew install-cpanm
    rakudobrew build moar
    rakudobrew build zef
```


#  Building The Toaster

```bash
    rakudobrew build moar
    rakudobrew build zef
    zef install --debug --serial WWW

    git clone https://github.com/zoffixznet/zefyr
    cd zefyr
```
