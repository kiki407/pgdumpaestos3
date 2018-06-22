Dump Postgresql database and upload to s3 encrypted
===================================================

* Backup file is compressed with gzip
* Backup file is encrypted with aes-256-cbc symetric key
* sha512 sum file of the backup file and of the encryped file are in the .sha512 file
* Backup is uploaded to S3

_The encrypted backup is stored locally on the volume in /tmp because the stream upload to s3 doesn't seem to work for me._

#### Env file example
```
POSTGRES_DATABASE=kiki407
POSTGRES_HOST=ahostinyournetwork
POSTGRES_USER=kiki407
POSTGRES_PASSWORD=kiki407
S3_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
S3_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
S3_BUCKET=thisisnotapublicbucket
ENCRYPTION_KEY=whateversuitsyoubutneedstobesuperlongbecauseitsanunsecureworldoutthere0
```

#### example:
```
docker run --name pgdumpaestos3 --env-file envfiletest kiki407/pgdumpaestos3
```

#### To restore (example):
```
openssl aes-256-cbc -d -k 'whateversuitsyoubutneedstobesuperlongbecauseitsanunsecureworldoutthere0' -in mybackup.dmp.gz.enc | gzip -c -d | pg_restore ...
```
Check the checksum files before restoring file.
