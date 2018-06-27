#! /bin/bash

if [ "${NAME_PREFIX}" = "**None**" ]; then
  NAME_PREFIX=${POSTGRES_DATABASE}-backup
fi

if [ "${DATE_FORMAT}" = "**None**" ]; then
  DATE_FORMAT="_%Y-%m-%d_%H-%M"
fi

if [ "${FILE_CHECKSUM_ALGO}" = "**None**" ]; then
  FILE_CHECKSUM_ALGO=sha512
elif [ "${FILE_CHECKSUM_ALGO}" = "sha512" ]; then
  FILE_CHECKSUM_ALGO=sha512
elif [ "${FILE_CHECKSUM_ALGO}" = "sha256" ]; then
  FILE_CHECKSUM_ALGO=sha256
elif [ "${FILE_CHECKSUM_ALGO}" = "sha1" ]; then
  FILE_CHECKSUM_ALGO=sha1
elif [ "${FILE_CHECKSUM_ALGO}" = "md5" ]; then
  FILE_CHECKSUM_ALGO=md5
else
  echo "FILE_CHECKSUM_ALGO environment variable should be sha512, sha256, sha1 or md5"
  exit 1
fi

EXTENSION=${EXTENSION:-.dmp.gz.enc}
BASEFILE="${NAME_PREFIX}`date +${DATE_FORMAT}`"
BACKUPFILE="${BASEFILE}${EXTENSION}"
SUMFILE="${BASEFILE}.${FILE_CHECKSUM_ALGO}"

POSTGRES_PORT="${POSTGRES_PORT:-5432}"
S3_REGION="${S3_REGION:-us-west-1}"

export AWS_DEFAULT_REGION=${S3_REGION:-us-west-1}

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
pg_dump ${POSTGRES_HOST_OPTS} ${POSTGRES_DATABASE} | tee >(${FILE_CHECKSUM_ALGO}sum - >/tmp/${SUMFILE}) | gzip -c | openssl aes-256-cbc -e -out /tmp/${BACKUPFILE} -k "${ENCRYPTION_KEY}"

sed -ie "s/-/${BASEFILE}.dmp/" /tmp/${SUMFILE}
cd /tmp
${FILE_CHECKSUM_ALGO}sum ${BACKUPFILE} >> /tmp/${SUMFILE}
echo CHECKSUMS
cat  /tmp/${SUMFILE}
echo "uploading ${BACKUPFILE} to s3 bucket ${S3_BUCKET}"
aws s3 cp /tmp/${SUMFILE} s3://${S3_BUCKET}/
aws s3 cp /tmp/${BACKUPFILE} s3://${S3_BUCKET}/
