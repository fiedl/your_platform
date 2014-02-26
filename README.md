## Wingolfsplattform

[![GitHub version](https://badge.fury.io/gh/fiedl%2Fwingolfsplattform.png)](http://badge.fury.io/gh/fiedl%2Fwingolfsplattform)
[![Build Status on production](https://travis-ci.org/fiedl/wingolfsplattform.png?branch=production "production")](https://travis-ci.org/fiedl/wingolfsplattform)
[![Build Status on master](https://travis-ci.org/fiedl/wingolfsplattform.png?branch=master "master")](https://travis-ci.org/fiedl/wingolfsplattform)
[![Dependency Status](https://gemnasium.com/fiedl/wingolfsplattform.png)](https://gemnasium.com/fiedl/wingolfsplattform)

Dies ist der Quellcode der entstehenden neuen Plattform von Wingolfsbund und VAW, der sog. **Wingolfsplattform**. Die Plattform soll vier Hauptaufgaben erfüllen: Hilfestellung bei der Verwaltung der Mitglieder des Wingolfs, Netzwerk der Mitglieder, Austausch von Informationen und Dokumenten, Präsentation nach außen. 
Nähere Informationen zum Anforderungsspektrum unter http://wingolf.org/ak-internet.

**Ansprechpartner**:
Sebastian Fiedlschuster  E 06  (B-xx)

### Status

**Hinweis:** Die Anzeigen "Coverage" und "Code Climate" beziehen sich derzeit nur auf den wingolf-spezifischen Konkretisierungs-Teil, nicht aber auf den Großteil des Codes, der unter `your_platform` abgelegt ist. Ferner werden die von Natur aus unschönen Import-Skripte miteinbezogen. Bis auch `your_platform` erfasst werden kann, sind diese Anzeigen daher nicht als repräsentativ zu betrachten.

Status                                                                                                                                                            | Beschreibung
----------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------
[![GitHub version](https://badge.fury.io/gh/fiedl%2Fwingolfsplattform.png)](http://badge.fury.io/)                                    | Wingolfsplattform Version
[![Build Status on production](https://travis-ci.org/fiedl/wingolfsplattform.png?branch=production "production")](https://travis-ci.org/fiedl/wingolfsplattform)  | Build Status on `production`
[![Build Status on master](https://travis-ci.org/fiedl/wingolfsplattform.png?branch=master "master")](https://travis-ci.org/fiedl/wingolfsplattform)              | Build Status on `master`
[![Coverage Status](https://coveralls.io/repos/fiedl/wingolfsplattform/badge.png)](https://coveralls.io/r/fiedl/wingolfsplattform)                                | Test Coverage on `master`
[![Code Climate](https://codeclimate.com/github/fiedl/wingolfsplattform.png)](https://codeclimate.com/github/fiedl/wingolfsplattform)                             | Code Climate (4=good, 1=bad)
[![Dependency Status](https://gemnasium.com/fiedl/wingolfsplattform.png)](https://gemnasium.com/fiedl/wingolfsplattform)                                          | Gemnasium Gem Dependency Monitor


### Production

Die laufende Seite ist erreichbar unter http://wingolfsplattform.org.

**Continuous Deployment**: Der `production`-Branch wird nach einem Push automatisch auf wingolfsplattform.org bereitgestellt.
Den aktuell bereitgestellten Commit kann man hier abfragen: http://wingolfsplattform.org:4567


### Contribution

Als Server-Side-Framework verwenden wir [Ruby on Rails](http://rubyonrails.org/) 3.2 mit Ruby 2.0 und als Client-Side-JS-Framework [AngularJS](http://angularjs.org/). Wir empfehlen die Verwendung von [rbenv](https://github.com/sstephenson/rbenv/).

**[GETTING STARTED](https://github.com/fiedl/wingolfsplattform/wiki/Getting-Started)** -- von der Installation der Entwicklungsumgebung bis zum Durchführen der automatisierten Tests.

Für **kleinere Korrekturen** bitte einfach unkompliziert einen Pull-Request eintragen. Bei **Interesse an einer längerfristigen Mitarbeit** wendet euch bitte an den Arbeitskreis Internet: `ak-internet at do not spam me wingolf dot org`.

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


### Code Documentation

* [Code-Dokumentation auf rubydoc.info](http://rubydoc.info/github/fiedl/wingolfsplattform/master/frames)
* Lokal kann die Dokumentation mit dem Kommando `yardoc` erzeugt werden.


### Links

* [Trello Board "AK Internet: Entwicklung"](https://trello.com/board/ak-internet-entwicklung/50006d110ad48e941e8496d2)
* http://wingolf.org/ak-internet


### Urheber, Mitarbeiter und Lizenz

Copyright (c) 2012-2013, Sebastian Fiedlschuster

Mitarbeiter: Jörg Reichardt, Manuel Zerpies, Joachim Back

Der Quellcode ist unter den Lizenzbestimmungen der [GNU Affero General Public License (AGPL)](AGPL.txt) veröffentlicht. Hiervon sind explizit ausgenommen die Grafiken und Schriftarten in den Verzeichnissen [app/assets/images](app/assets/images) und [app/assets/fonts](app/assets/fonts), die lediglich dem Betrieb der laufenden Primärinstanz dienen.

The Source Code is released under the [GNU Affero General Public License (AGPL)](AGPL.txt). Explicitely excluded are the images and fonts in the directories [app/assets/images](app/assets/images) and [app/assets/fonts](app/assets/fonts), which are only to be used by Wingolf for production.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
[GNU Affero General Public License](AGPL.txt) for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.