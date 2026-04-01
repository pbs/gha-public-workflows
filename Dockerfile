FROM alpine:latest
ARG TESTING_BUILD_ARG1
ARG TESTING_BUILD_ARG2
RUN apk update && \
    apk add vim
RUN echo "Testing build args: TESTING_BUILD_ARG1=${TESTING_BUILD_ARG1}, TESTING_BUILD_ARG2=${TESTING_BUILD_ARG2}" > /build_args.txt
CMD ["which", "vim"]