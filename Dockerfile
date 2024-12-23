FROM ruby:3.1.4

ARG USERNAME=ruby
ARG IDEURL=https://download.jetbrains.com/ruby/RubyMine-2024.3.1.tar.gz

RUN useradd -m $USERNAME && \
    mkdir -p /etc/sudoers.d && \
    usermod -aG sudo $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

ENV PROJDIR=/home/$USERNAME/app/

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  vim && \
  rm -rf /var/lib/apt/lists/*

USER $USERNAME
WORKDIR /home/$USERNAME

#COPY Gemfile ./

#RUN bundle install

ENV EDITOR=vim

RUN curl -fsSL -o ide.tar.gz $IDEURL && \
mkdir ide && \
tar xfz ide.tar.gz --strip-components=1 -C ide && \
rm ide.tar.gz

CMD yes '' | ide/bin/remote-dev-server.sh run $APP_ROOT --listenOn 0.0.0.0 --port 5995

EXPOSE 5995