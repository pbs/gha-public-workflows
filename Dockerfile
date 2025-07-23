FROM alpine:latest
RUN apk update && \
    apk add vim \ 
    apk add --no-cache curl
CMD ["which", "vim"]