FROM alpine:latest
RUN apk update && \
    apk add vim
CMD which vim