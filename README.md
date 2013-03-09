## Wingolfsplattform
 
Dies ist der Quellcode der entstehenden neuen Plattform von Wingolfsbund und VAW, der sog **Wingolfsplattform**. Die Plattform soll vier Hauptaufgaben erfüllen: Hilfestellung bei der Verwaltung der Mitglieder des Wingolfs, Netzwerk der Mitglieder, Austausch von Informationen und Dokumenten, Präsentation nach außen. 
Nähere Informationen zum Anforderungsspektrum unter http://wingolf.org/ak-internet.

**Ansprechpartner**:
Sebastian Fiedlschuster  E 06  (B-xx)
<deleted-string>

### Host

Die laufende Seite ist erreichbar unter http://wingolfsplattform.org.

HTTP-Auth-Login: `aki`, Passwort: `deleted-string`

### Build Status 

Der Status kann derzeit nicht per Travis eingesehen werden, da unser Travis-Pro-Account ausgelaufen ist. 

### Contribution

Als Server-Side-Framework verwenden wir [Ruby on Rails](http://rubyonrails.org/) und als Client-Side-JS-Framework [AngularJS](http://angularjs.org/). 

Wir empfehlen die Verwendung von [rbenv](https://github.com/sstephenson/rbenv/), damit alle Entwickler mit der gleichen Ruby-Version am Projekt arbeiten. 
Andernfalls kann die Ruby-Version, mit der wir entwickeln in der Datei `.ruby-version` nachgeschlagen werden.

#### Installation von rbenv

TODO: Die Installation von rbenv und die Installation der aktuellen Ruby-Version in eine Wiki-Seite auslagern, die eine ausführliche Schritt-für-Schritt-Anleitung
zum Aufesetzen einer Entwicklungsumgebung (bis zum Punkt, an dem die Specs laufen) enthält.

1. Gegebenenfalles Ruby über die systemeigene Paketverwaltung deinstallieren.
1. Gegebenenfalles [rvm entfernen](http://stackoverflow.com/questions/3558656/how-to-remove-rvm-ruby-version-manager-from-my-system).
1. [rbenv installieren](https://github.com/sstephenson/rbenv/#installation). Hierbei aber darauf achten, dass die Initialisierung in `~/.bashrc` erfolgt, nicht in `.profile`, sofern die Systemarchitektur das so vorsieht.
1. Gegebenenfalles globale Ruby-Version setzen. Die Ruby-Version wird lokal durch die Datei `.ruby-version` im Repository festgelegt. Sollte man jedoch auch an anderen Ruby-Programmen arbeiten, empfiehlt sich das Setzen einer globalen Version: `$ rbenv global 1.9.3-p327`.
1. Die virtuellen Ruby-Binaries der Pfad-Variable hinzufügen: `$ echo 'export PATH="$HOME/.rbenv/shims:$PATH"' >> ~/.profile`
1. Die Shell reinitialisieren: `$ exec $SHELL -l`
1. Überprüfen, ob alles funktioniert. Das folgende Kommando sollte die aktuelle Ruby-Version anzeigen: `$ ruby --version`

#### Installation der aktuellen Ruby-Version

Sollte beim Ausführen von Ruby im Projektverzeichnis ein Fehler auftreten, der besagt, dass die benötigte Ruby-Version nicht installiert ist (z.B. `rbenv: version `2.0.0-p0' is not installed`), kann diese Version einfach nachinstalliert werden:

```bash
$ rbenv install 2.0.0-p0
$ rbenv rehash
```

Möglicherweise wird danach eine neue Installation des Gem Bundlers erforderlich: `$ gem install bundle && rbenv rehash`

* Danach die Shell neustarten (`$ bash -l`) und die Gems installieren: `$ bundle install`.
* Das Systempaket `libruby1.9.1` oder neuer installieren.
* `gem install rb-readline`, damit `guard` funktioniert (für die korrekte Ruby-Version).

#### Projekt-Setup

```bash
cd ~/rails
git clone --recursive git@github.com:fiedl/wingolfsplattform.git
cd ~/rails/wingolfsplattform
bundle install
bundle exec rake db:create db:migrate
bundle exec rake bootstrap:all
bundle exec rake db:test:prepare
bundle exec rake
```

#### Git Submodules

Das Repository verwendet sog. Git-Submodules. D.h. bestimmte Vendor-Komponenten werden nicht in das 
Repository kopiert, sondern verweisen auf andere Repositories. Beim Klonen bzw. Pullen muss folglich
darauf geachtet werden, dass diese Submodules auch geladen werden.

##### git clone

```bash
cd ~/rails
git clone --recursive git@github.com:fiedl/wingolfsplattform.git
```

##### git pull

```bash
git pull --recurse-submodules [origin] [master]
```

##### Argument vergessen?

Wenn man beim `git clone` das `--recursive`-Argument oder beim `git pull` das `--recurse-submodules` 
vergessen hat, lassen sich die Dateien natürlich auch nachträglich herunterladen:
```bash
cd ~/rails/wingolfsplattform    # oder in welches Projektverzeichnis auch immer
git pull
git submodule init
git submodule update
git submodule status            # nur, um sicherzustellen, dass alles funktioniert hat.
```

##### Automatismus

Ab Git 1.7.5 sollten die Submodules automatisch geladen werden. Falls das nicht funktioniert, 
kann man beispielsweise den `git pullall`-Alias definieren:

```bash
git config alias.pullall '!f(){ git pull "$@" && git submodule update --init --recursive; }; f'
```

Quelle: http://stackoverflow.com/questions/4611512/



#### Sendmail

Make sure, `/usr/sbin/sendmail` is installed on your development machine. The mailer won't raise an error if not. If you don't recaive email from your dev machine, check `/var/log/mail.err`.

#### your_platform

Der abstrakte Teil des Quellcodes, d.h. derjenige Teil, der auch von anderen Organisationen als dem Wingolf verwendet werden kann, ist in der `your_platform`-Engine unterzubringen. Die Konkretisierung und Anpassung auf die wingolfitischen Bedürfnisse erfolgt in der Haupt-Applikation. 

Dieser aufgespaltete Zustand ist noch nicht erreicht. Der aktuelle Stand ist der Migrations-Matrix zu entnehmen, die unter der folgenden Adresse abgerufen werden kann:
https://docs.google.com/spreadsheet/ccc?key=0ApsXX8JdKfoOdFVOSXdoSWp6MkVxWmVCUXU2U0IteWc&pli=1#gid=0

#### Continuous Deployment

Der `master`-Branch wird nach einem Push automatisch auf wingolfsplattform.org bereitgestellt. 
**Mit großer Macht geht große Verantwortung einher!** :)

Den aktuellen Status kann man hier abfragen: http://wingolfsplattform.org:4567


