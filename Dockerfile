FROM swift:4.1

ARG SLACK_BOT_TOKEN
ARG MEMBER_ID

ENV SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN}
ENV MEMBER_ID=${MEMBER_ID}

USER root
COPY ./Sources /SwiftBot/Sources
COPY ./Package.swift ./Package.resolved /SwiftBot/

WORKDIR /SwiftBot
RUN swift build

CMD ["./.build/debug/SwiftBot"]