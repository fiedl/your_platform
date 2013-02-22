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

#### Setup

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


