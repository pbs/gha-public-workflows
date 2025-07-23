FROM alpine:latest
RUN apk update && \
    apk add vim \ 
    apk add --no-cache curl
CMD ["sh", "-c", "which vim && curl --version"]