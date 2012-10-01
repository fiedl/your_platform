## Wingolfsplattform

Dies ist der Quellcode der entstehenden neuen Plattform von Wingolfsbund und VAW, der sog **Wingolfsplattform**. 
Nähere Informationen zum Anforderungsspektrum unter http://wingolf.org/ak-internet.

**Ansprechpartner**:
Sebastian Fiedlschuster  E 06  (B-xx)
<deleted-string>

### Host

Die laufende Seite ist erreichbar unter http://wingolfsplattform.org.

HTTP-Auth-Login: `aki`, Passwort: `deleted-string`

### Build Status 

[![Build Status](https://magnum.travis-ci.com/fiedl/wingolfsplattform.png?branch=master&token=EkwxFvobzUvAGcKu7AzB)](http://travis-ci.org/fiedl/wingolfsplattform) master

### Contribution & Continuous Deployment

#### Setup

```bash
cd ~/rails
git clone git@github.com:fiedl/wingolfsplattform.git
cd ~/rails/wingolfsplattform
bundle install
bundle exec rake db:create db:migrate
bundle exec rake bootstrap:all
bundle exec rake db:test:prepare
RAILS_ENV=test bundle exec rake bootstrap:all
bundle exec rake
```

#### Continuous Deployment

Der `master`-Branch wird nach einem Push automatisch auf wingolfsplattform.org bereitgestellt. 
**Mit großer Macht geht große Verantwortung einher!** :)

### Badges

<a href="http://love.travis-ci.org"><img src="http://wingolfsplattform.org/images/supporttravis.png"></a>

