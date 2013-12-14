## Wingolfsplattform
 
Dies ist der Quellcode der entstehenden neuen Plattform von Wingolfsbund und VAW, der sog **Wingolfsplattform**. Die Plattform soll vier Hauptaufgaben erfüllen: Hilfestellung bei der Verwaltung der Mitglieder des Wingolfs, Netzwerk der Mitglieder, Austausch von Informationen und Dokumenten, Präsentation nach außen. 
Nähere Informationen zum Anforderungsspektrum unter http://wingolf.org/ak-internet.

**Ansprechpartner**:
Sebastian Fiedlschuster  E 06  (B-xx)
<deleted-string>


### Production

Die laufende Seite ist erreichbar unter http://wingolfsplattform.org.

**Continuous Deployment**: Der `master`-Branch wird nach einem Push automatisch auf wingolfsplattform.org bereitgestellt.
Den aktuell bereitgestellten Commit kann man hier abfragen: http://wingolfsplattform.org:4567


### Contribution

Als Server-Side-Framework verwenden wir [Ruby on Rails](http://rubyonrails.org/) 3.2 mit Ruby 2.0 und als Client-Side-JS-Framework [AngularJS](http://angularjs.org/). Wir empfehlen die Verwendung von [rbenv](https://github.com/sstephenson/rbenv/).

**[GETTING STARTED](https://github.com/fiedl/wingolfsplattform/wiki/Getting-Started)** -- von der Installation der Entwicklungsumgebung bis zum Durchführen der automatisierten Tests.

#### Quick-Setup

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

### your_platform

Der abstrakte Teil des Quellcodes, d.h. derjenige Teil, der auch von anderen Organisationen als dem Wingolf verwendet werden kann, ist in der [`your_platform`-Engine](vendor/engines/your_platform) unterzubringen. Die Konkretisierung und Anpassung auf die wingolfitischen Bedürfnisse erfolgt in der Haupt-Applikation. 

Dieser aufgespaltete Zustand ist noch nicht vollständig erreicht. Der aktuelle Stand ist der [Migrations-Matrix](https://docs.google.com/spreadsheet/ccc?key=0ApsXX8JdKfoOdFVOSXdoSWp6MkVxWmVCUXU2U0IteWc&pli=1#gid=0) zu entnehmen.


### Links

* [Trello Board "AK Internet: Entwicklung"](https://trello.com/board/ak-internet-entwicklung/50006d110ad48e941e8496d2)
* AK-Internet-FTP: [ftp://akiftp@wingolfsplattform.org](ftp://akiftp@wingolfsplattform.org), Passwort: deleted-string
* http://wingolf.org/ak-internet
