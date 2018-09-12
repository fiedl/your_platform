FROM ruby:2.3.3

ENV RAILS_ENV=development

# Install requirements for ruby gems.
RUN apt-get update && apt-get install -y aptitude
RUN aptitude install -y libssl-dev g++ libxml2 libxslt-dev libreadline-dev libicu-dev imagemagick libmagick-dev
RUN gem install bundler

# Install nodejs.
RUN aptitude install -y build-essential libssl-dev
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN aptitude install -y nodejs
RUN node --version
RUN npm i -g yarn

# Install helper packages.
RUN aptitude install -y pwgen

WORKDIR /app
CMD ["script/start"]