# bashpass Password Generator "correct horse battery staple"

## Usage Example

```bash
./bashpass -d german.dic -n 4
./bashpass -d german.dic -n 4 |tr "&1234567890\`=@+#~\!\%*_^-" " "  # for classic xkcd passowrds
```

## bashpass

* Source: https://github.com/joshuar/bashpass
* License: Apache

## German Word List

* Source: http://www.htdig.org
* License: GPL
* http://www.htdig.org/files/contrib/wordlists/

## OS X

```bash
brew install coreutils

# in execution context
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
```

