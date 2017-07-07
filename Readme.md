# PostgreSQL S3 Backup

This Docker container enables you to backup a PostgreSQL database to AWS S3. The
container dumps the database using `pg_dump`, creates a gzipped tarball of the
dump, and uploads the tarball to S3.

The container does not handle the scheduling of the backup. The actual backup
has to be invoked from an external service like `cron`, a `cron` Docker
container, Jenkins, etc.

# Usage

Credentials and connection details are required to be passed into the container
through environment variables. This enables you to create your derivant of the
image for your specific use case. The following environment variables are
expected:

* `PG_HOST` (optional, default `db`)
* `PG_PORT` (optional, default `5432`)
* `PG_USER` (optional, default `postgres`)
* `PG_PASS` (optional, no default value)
* `AWS_REGION`
* `AWS_ACCESS_KEY`
* `AWS_SECRET_ACCESS_KEY`

To run the backup for a locally deployed database, link the database
container into the backup container:

```
$> docker run --link db_container:db \
              -e AWS_REGION=eu-central-1 \
              -e AWS_ACCESS_KEY_ID=12345 \
              -e AWS_SECRET_ACCESS_KEY=qwertz \
              lawitschka/postgresql-s3-backup \
              s3_bucket/path/in/bucket example_db
```

This will dump the database `example_db` into an archive called
`example_db-XXXXXXXXXX.sql.tar.gz`. The `XXXXXXXXXX` will be
replaced with a UNIX epoch at the time of the backup. The backup script then
uploads the archive to a S3 bucket called `s3_bucket` and into the folder
`path/in/bucket`.

Alternatively, the database host can be defined through usage of the `PG_`
environment variables:

```
$> docker run -e AWS_REGION=eu-central-1 \
              -e AWS_ACCESS_KEY_ID=12345 \
              -e AWS_SECRET_ACCESS_KEY=qwertz \
              -e PG_HOST=db.example.com \
              -e PG_USER=nondefaultuser \
              lawitschka/postgresql-s3-backup \
              s3_bucket/path/in/bucket example_db
```
