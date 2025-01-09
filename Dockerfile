FROM ruby:3.1.4

ARG IDEURL=https://download.jetbrains.com/ruby/RubyMine-2024.3.1.1.tar.gz

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  vim && \
  rm -rf /var/lib/apt/lists/*

ENV EDITOR=vim

WORKDIR /root/app

RUN curl -fsSL -o ide.tar.gz $IDEURL && \
mkdir ide && \
tar xfz ide.tar.gz --strip-components=1 -C ide && \
rm ide.tar.gz

CMD yes '' | ide/bin/remote-dev-server.sh run $APP_ROOT --listenOn 0.0.0.0 --port 5995

EXPOSE 5995