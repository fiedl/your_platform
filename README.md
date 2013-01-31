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

[![Build Status](https://magnum.travis-ci.com/fiedl/wingolfsplattform.png?branch=master&token=EkwxFvobzUvAGcKu7AzB)](http://travis-ci.org/fiedl/wingolfsplattform) master

### Contribution

#### Setup

```bash
cd ~/rails
git clone git@github.com:fiedl/wingolfsplattform.git
cd ~/rails/wingolfsplattform
bundle install
bundle exec rake db:create db:migrate
bundle exec rake bootstrap:all
bundle exec rake db:test:prepare
bundle exec rake
```

* Make sure, `/usr/sbin/sendmail` is installed on your development machine. The mailer won't raise an error if not. If you don't recaive email from your dev machine, check `/var/log/mail.err`.

#### your_platform

Der abstrakte Teil des Quellcodes, d.h. derjenige Teil, der auch von anderen Organisationen als dem Wingolf verwendet werden kann, ist in der `your_platform`-Engine unterzubringen. Die Konkretisierung und Anpassung auf die wingolfitischen Bedürfnisse erfolgt in der Haupt-Applikation. 

Dieser aufgespaltete Zustand ist noch nicht erreicht. Der aktuelle Stand ist der Migrations-Matrix zu entnehmen, die unter der folgenden Adresse abgerufen werden kann:
https://docs.google.com/spreadsheet/ccc?key=0ApsXX8JdKfoOdFVOSXdoSWp6MkVxWmVCUXU2U0IteWc&pli=1#gid=0

#### Continuous Deployment

Der `master`-Branch wird nach einem Push automatisch auf wingolfsplattform.org bereitgestellt. 
**Mit großer Macht geht große Verantwortung einher!** :)

Hierbei werden nach einem Push automatisch die Tests auf travis-ci.com ausgeführt. Handelt es sich um einen Push nach master und sind die Tests grün, wird der Deployment-Hook von wingolfsplattform.org ausgelöst, wodurch der aktuelle master-Branch auf wingolfsplattform.org installiert wird.

### Badges

<a href="http://love.travis-ci.org"><img src="http://wingolfsplattform.org/images/supporttravis.png"></a>

