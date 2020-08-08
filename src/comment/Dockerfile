FROM ruby:2.2

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME

RUN apt-get update -qq && apt-get install -y build-essential \
    && bundle install \
    && bundle clean --force && rm -rf ~/.bundle \
    && apt-get purge -y build-essential \
    && apt-get clean && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments
CMD ["puma"]
