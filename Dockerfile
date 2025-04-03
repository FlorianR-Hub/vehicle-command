FROM golang:1.20.12-bookworm
# Set environment variables
ENV TESLA_HTTP_PROXY_TLS_CERT $TESLA_HTTP_PROXY_TLS_CERT
ENV TESLA_HTTP_PROXY_TLS_KEY $TESLA_HTTP_PROXY_TLS_KEY
ENV TESLA_KEY_FILE $TESLA_KEY_FILE
ENV REPO_URL https://github.com/FlorianR-Hub/vehicle-command.git
RUN mkdir /TeslaProxy
WORKDIR /vehicle-command
# Run as root user
USER root
# Clone the repository
RUN git clone ${REPO_URL} .
# Install dependencies, build and install the project
RUN go get ./...
RUN go build ./...
RUN go install ./...
# Set the entrypoint and command
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/go/bin/tesla-http-proxy -tls-key $TESLA_HTTP_PROXY_TLS_KEY -cert $TESLA_HTTP_PROXY_TLS_CERT -key-file $TESLA_KEY_FILE -port 8080 -host 0.0.0.0 -verbose"]
