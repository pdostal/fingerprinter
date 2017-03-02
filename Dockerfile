FROM node:7-alpine
RUN apk update && apk add git gnupg
RUN npm install -g coffee-script

RUN mkdir /app
WORKDIR /app
