FROM postgres:alpine

COPY install.sh install.sh
RUN sh install.sh && rm install.sh

ENV POSTGRES_DATABASE **None**
ENV POSTGRES_HOST **None**
ENV NAME_PREFIX **None**
ENV FILE_CHECKSUM_ALGO **None**
ENV POSTGRES_USER **None**
ENV POSTGRES_PASSWORD **None**
ENV ENCRYPTION_KEY **None**
ENV S3_BUCKET **None**
ENV DATE_FORMAT **None**

COPY backup.sh backup.sh
RUN chmod +x backup.sh

CMD ["./backup.sh"]
