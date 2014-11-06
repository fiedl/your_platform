## Wingolfsplattform
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/fiedl/wingolfsplattform?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[![GitHub version](https://badge.fury.io/gh/fiedl%2Fwingolfsplattform.png)](http://badge.fury.io/gh/fiedl%2Fwingolfsplattform)
[![Build Status on production](https://travis-ci.org/fiedl/wingolfsplattform.png?branch=production "production")](https://travis-ci.org/fiedl/wingolfsplattform)
[![Build Status on master](https://travis-ci.org/fiedl/wingolfsplattform.png?branch=master "master")](https://travis-ci.org/fiedl/wingolfsplattform)
[![Dependency Status](https://gemnasium.com/fiedl/wingolfsplattform.png)](https://gemnasium.com/fiedl/wingolfsplattform)

Dies ist der Quellcode der entstehenden neuen Plattform von Wingolfsbund und VAW, der sog. **Wingolfsplattform**. Die Plattform soll vier Hauptaufgaben erfüllen: Hilfestellung bei der Verwaltung der Mitglieder des Wingolfs, Netzwerk der Mitglieder, Austausch von Informationen und Dokumenten, Präsentation nach außen. 
Nähere Informationen zum Anforderungsspektrum unter http://wingolf.org/ak-internet.

**Ansprechpartner**:
Sebastian Fiedlschuster  E 06  (B-xx)


### Production

Die laufende Seite ist erreichbar unter http://wingolfsplattform.org.

**Continuous Deployment**: Der `production`-Branch wird nach einem Push automatisch auf wingolfsplattform.org bereitgestellt.
Den aktuell bereitgestellten Commit kann man hier abfragen: http://wingolfsplattform.org:4567


### Contribution

Als Server-Side-Framework verwenden wir [Ruby on Rails](http://rubyonrails.org/) 3.2 mit Ruby 2.1. Wir empfehlen die Verwendung von [rbenv](https://github.com/sstephenson/rbenv/).

**[GETTING STARTED](https://github.com/fiedl/wingolfsplattform/wiki/Getting-Started)** -- von der Installation der Entwicklungsumgebung bis zum Durchführen der automatisierten Tests.

Für **kleinere Korrekturen** bitte einfach unkompliziert einen Pull-Request eintragen. Bei **Interesse an einer längerfristigen Mitarbeit** wendet euch bitte an den Arbeitskreis Internet: `ak-internet at do not spam me wingolf dot org`.

#### Quick-Setup

```bash
cd ~/rails
git clone git@github.com:fiedl/wingolfsplattform.git
cd ~/rails/wingolfsplattform
bundle install
bundle exec rake db:create db:migrate
bundle exec rake db:test:prepare
bundle exec rake
bundle exec foreman start
bundle exec rails server
```


### your_platform

Der abstrakte Teil des Quellcodes, d.h. derjenige Teil, der auch von anderen Organisationen als dem Wingolf verwendet werden kann, ist in der [`your_platform`-Engine](vendor/engines/your_platform) unterzubringen. Die Konkretisierung und Anpassung auf die wingolfitischen Bedürfnisse erfolgt in der Haupt-Applikation. 

Dieser aufgespaltete Zustand ist noch nicht vollständig erreicht. Der aktuelle Stand ist der [Migrations-Matrix](https://docs.google.com/spreadsheet/ccc?key=0ApsXX8JdKfoOdFVOSXdoSWp6MkVxWmVCUXU2U0IteWc&pli=1#gid=0) zu entnehmen.


### Code Documentation

* [Code-Dokumentation auf rubydoc.info](http://rubydoc.info/github/fiedl/wingolfsplattform/master/frames)
* Lokal kann die Dokumentation mit dem Kommando `yardoc` erzeugt werden.


### Regelmäßige Sicherheits-Test

* Alle Entwickler möchten sich bitte mit den [Rails Security Guide](http://guides.rubyonrails.org/security.html) vertraut machen.
* Regelmäßig sollte [brakeman](https://github.com/presidentbeef/brakeman) ausgeführt werden, um nach gängigen Sicherheitslücken zu suchen.

  ```
  gem update brakeman
  cdw
  brakeman -o ~/Desktop/brakeman.html
  cdy
  brakeman -o ~/Desktop/your_platform.brakeman.html
  ```
  
* *brakeman* ist außerdem in unsere *guard*-Konfiguration eingebunden, sodass die guard-Ausgabe auch Brakeman-Sicherheitsmeldungen enthält.


### Links

* [Trello Board "AK Internet: Entwicklung"](https://trello.com/board/ak-internet-entwicklung/50006d110ad48e941e8496d2)
* http://wingolf.org/ak-internet

[![Travis-CI-Server](https://raw.githubusercontent.com/fiedl/wingolfsplattform/master/public/images/supporttravis.png)](http://travis-ci.org)  
[![UserVoice-Ticket-System](http://upload.wikimedia.org/wikipedia/en/d/d3/UserVoice_logo.png)](http://uservoice.com)


### Urheber, Mitarbeiter und Lizenz

Copyright (c) 2012-2014, Sebastian Fiedlschuster

Mitarbeiter: Jörg Reichardt, Manuel Zerpies, Joachim Back

Der Quellcode ist unter den Lizenzbestimmungen der [GNU Affero General Public License (AGPL)](AGPL.txt) veröffentlicht. Hiervon sind explizit ausgenommen die Grafiken und Schriftarten in den Verzeichnissen [app/assets/images](app/assets/images) und [app/assets/fonts](app/assets/fonts), die lediglich dem Betrieb der laufenden Primärinstanz dienen.

The Source Code is released under the [GNU Affero General Public License (AGPL)](AGPL.txt). Explicitely excluded are the images and fonts in the directories [app/assets/images](app/assets/images) and [app/assets/fonts](app/assets/fonts), which are only to be used by Wingolf for production.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
[GNU Affero General Public License](AGPL.txt) for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.