# YourPlatform

[![Join the chat at https://gitter.im/fiedl/your_platform](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fiedl/your_platform?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**TEMPORARY STATE –– DO NOT USE THIS RIGHT NOW**

We are currently extracting [the your_platform engine](https://github.com/fiedl/wingolfsplattform/tree/master/vendor/engines/your_platform) into this repository. 

Until the the export process is completed, the commit history might change in a non-linear way.

## Getting Started

[GETTING STARTED](https://github.com/fiedl/your_platform/wiki/GettingStarted) in the wiki.

## Installation

Add this line to your application's Gemfile:

```ruby
# Gemfile
# ...
gem 'your_platform'
```

And then execute:

```bash
# bash 
bundle install
```

### Database

```bash
bundle exec rake your_platform:install:migrations
bundle exec rake db:migrate
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors and License

**Copyright** (c) 2012-2015, Sebastian Fiedlschuster

**Contributors**: Jörg Reichardt, Manuel Zerpies, Joachim Back

**License**: The Source Code is released under the GNU Affero General Public License (AGPL). Explicitely excluded are the images and fonts.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see http://www.gnu.org/licenses/.
