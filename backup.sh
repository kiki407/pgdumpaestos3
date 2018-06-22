#! /bin/bash

NAME_PREFIX=${POSTGRES_DATABASE}-backup
EXTENSION=${EXTENSION:-.dmp.gz.enc}
BASEFILE="${NAME_PREFIX}_`date +"%Y-%m-%d_%H-%M"`"
BACKUPFILE="${BASEFILE}${EXTENSION}"
SUMFILE="${BASEFILE}.sha512"

export AWS_DEFAULT_REGION=${S3_REGION:-eu-central-1}

set -e
set -o pipefail

if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${POSTGRES_DATABASE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ "${ENCRYPTION_KEY}" = "**None**" ]; then
  echo "You need to set the ENCRYPTION_KEY environment variable."
  exit 1
fi


export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-Fc -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER"

export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY


echo "Creating backup of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."
# pg_dump ${POSTGRES_HOST_OPTS} -v ${POSTGRES_DATABASE}
pg_dump ${POSTGRES_HOST_OPTS} ${POSTGRES_DATABASE} | tee >(sha512sum - >/tmp/${SUMFILE}) | gzip -c | openssl aes-256-cbc -e -out /tmp/${BACKUPFILE} -k "${ENCRYPTION_KEY}"

sed -ie "s/-/${BASEFILE}.dmp/" /tmp/${SUMFILE}
cd /tmp
sha512sum ${BACKUPFILE} >> /tmp/${SUMFILE}
# echo "uploading ${BACKUPFILE} to s3 bucket ${S3_BUCKET}"
aws s3 cp /tmp/${SUMFILE} s3://${S3_BUCKET}/
aws s3 cp /tmp/${BACKUPFILE} s3://${S3_BUCKET}/
