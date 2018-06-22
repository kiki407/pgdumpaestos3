FROM postgres:alpine

COPY install.sh install.sh
RUN sh install.sh && rm install.sh

ENV POSTGRES_DATABASE **None**
ENV POSTGRES_HOST **None**
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER **None**
ENV POSTGRES_PASSWORD **None**
ENV ENCRYPTION_KEY **None**


ENV S3_BUCKET **None**
ENV S3_REGION us-west-1

RUN apk update && \
    apk add --no-cache --virtual=build-dependencies \
        bash \
        sed

COPY backup.sh backup.sh
RUN chmod +x backup.sh

CMD ["./backup.sh"]
