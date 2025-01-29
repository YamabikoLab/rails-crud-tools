FROM ruby:3.1.4

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  vim && \
  rm -rf /var/lib/apt/lists/*

ENV EDITOR=vim

WORKDIR /root/app