Dump PostgreSQL database and upload to s3 encrypted
===================================================

* Backup file is compressed with gzip
* Backup file is encrypted with aes-256-cbc symetric key
* sha512 sum file of the backup file and of the encryped file are in the .sha512 file
* Backup is uploaded to S3
* Backup files are named as follow: ```[databasename]-backup_YYYY-mm-dd_HH-MM.dmp.gz.enc```

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

#### Example:
```
docker run --name pgdumpaestos3 --env-file envfiletest kiki407/pgdumpaestos3
```

#### To restore (example):
*This is just an exemple. Always check the checksum files before restoring file.*
```
openssl aes-256-cbc -d -k 'whateversuitsyoubutneedstobesuperlongbecauseitsanunsecureworldoutthere0' -in mybackup.dmp.gz.enc | gzip -c -d | pg_restore ...
```

#### Optional environment variables
* ```S3_REGION``` default = us-west-1
* ```POSTGRES_PORT``` default = 5432
* ```NAME_PREFIX``` default = [databasename]-backup
* ```FILE_CHECKSUM_ALGO``` default = sha512, should be one of:[sha512, sha256, sha1, md5] changes the extension of the sum file
* ```DATE_FORMAT``` default = '\_%Y-%m-%d\_%H-%M'
> date formatting (from date --help)
> *  %%   a literal %
> *  %a   locale's abbreviated weekday name (e.g., Sun)
> *  %A   locale's full weekday name (e.g., Sunday)
> *  %b   locale's abbreviated month name (e.g., Jan)
> *  %B   locale's full month name (e.g., January)
> *  %c   locale's date and time (e.g., Thu Mar  3 23:05:25 2005)
> *  %C   century; like %Y, except omit last two digits (e.g., 20)
> *  %d   day of month (e.g., 01)
> *  %D   date; same as %m/%d/%y
> *  %e   day of month, space padded; same as %_d
> *  %F   full date; same as %Y-%m-%d
> *  %g   last two digits of year of ISO week number (see %G)
> *  %G   year of ISO week number (see %V); normally useful only with %V
> *  %h   same as %b
> *  %H   hour (00..23)
> *  %I   hour (01..12)
> *  %j   day of year (001..366)
> *  %k   hour, space padded ( 0..23); same as %_H
> *  %l   hour, space padded ( 1..12); same as %_I
> *  %m   month (01..12)
> *  %M   minute (00..59)
> *  %n   a newline
> *  %N   nanoseconds (000000000..999999999)
> *  %p   locale's equivalent of either AM or PM; blank if not known
> *  %P   like %p, but lower case
> *  %r   locale's 12-hour clock time (e.g., 11:11:04 PM)
> *  %R   24-hour hour and minute; same as %H:%M
> *  %s   seconds since 1970-01-01 00:00:00 UTC
> *  %S   second (00..60)
> *  %t   a tab
> *  %T   time; same as %H:%M:%S
> *  %u   day of week (1..7); 1 is Monday
> *  %U   week number of year, with Sunday as first day of week (00..53)
> *  %V   ISO week number, with Monday as first day of week (01..53)
> *  %w   day of week (0..6); 0 is Sunday
> *  %W   week number of year, with Monday as first day of week (00..53)
> *  %x   locale's date representation (e.g., 12/31/99)
> *  %X   locale's time representation (e.g., 23:13:48)
> *  %y   last two digits of year (00..99)
> *  %Y   year
> *  %z   +hhmm numeric time zone (e.g., -0400)
> *  %:z  +hh:mm numeric time zone (e.g., -04:00)
> *  %::z  +hh:mm:ss numeric time zone (e.g., -04:00:00)
> *  %:::z  numeric time zone with : to necessary precision (e.g., -04, +05:30)
> *  %Z   alphabetic time zone abbreviation (e.g., EDT)