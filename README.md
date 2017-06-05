[![Build Status](https://travis-ci.org/zoffixznet/perl6-Proc-Q.svg)](https://travis-ci.org/zoffixznet/perl6-Proc-Q)

# WARNING!! DANGERUS STUF AHED!

Ecosystem toasting is Serious Business™. **You're LITERALLY running
arbitrary code from hundreds of strangers!**

It's HIGHLY unrecommended to run this software on anything but a throw-away
install that contains no sensitive data. Are you OK if ALL the files on the
system published somewhere publicly but without you being able to ever get them
again? If not, don't run this software!

# Blank Debian GCE VM Setup

On an out-of-the-box Debian, run these commands to prepare the system for
toasting:

```bash
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install build-essential git curl aptitude libssl-dev \
        wget htop zip
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

    zef install Toaster
```

# Toasting

To toast the ecosystem, run the `toaster-perl6` command, giving it as
positionals args the tags, branches or commits (basically anything
`git checkout` will accept).

Note: toasting takes ages, so don't go wild with toasting all the commits, if
you're not prepared to wait for it.

The toaster will create an SQLite database, with toasting results for each
of the toasted module, and each of the given commits.

```bash
    toaster-perl6 2017.03 2017.05 some-branch nom 64e898f9baa159e2019
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Proc-Q

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Proc-Q/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
