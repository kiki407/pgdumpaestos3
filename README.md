Backup file is compressed with gzip
Backup file is encrypted with aes-512-cbc symetric key
sha512 sum file of the backup file and of the encryped file are in the .sha512 file
Backup is uploaded to S3

* The encrypted backup is stored locally on the volume in /tmp because the stream upload to s3 doesn't seem to work for me.

Env file example
POSTGRES_DATABASE=kiki407
POSTGRES_HOST=ahostinyournetwork
POSTGRES_USER=kiki407
POSTGRES_PASSWORD=kiki407
S3_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
S3_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
S3_BUCKET=thisisnotapublicbucket
ENCRYPTION_KEY=whateversuitsyoubutneedstobesuperlongbecauseitsanunsecureworldoutthere0

example:
docker run --name pg_dump_to_s3 --env-file envfiletest kiki407/pg_dump_to_s3
