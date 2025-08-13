FROM alpine:3.22

# Environment variables
ENV TZ=Etc/UTC
ENV ROTATION_TZ=Etc/UTC

# Install essential packages, common utilities, and set up timezone
RUN apk add --no-cache \
  ca-certificates tini && \
  update-ca-certificates && \
  ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
  echo "${TZ}" > /etc/timezone

# Copy the Go binary 
COPY @@PROJECT_NAME@@ /usr/local/bin/@@PROJECT_NAME@@

# Set executable permission
RUN chmod +x /usr/local/bin/@@PROJECT_NAME@@

# Entrypoint 
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/@@PROJECT_NAME@@"]
