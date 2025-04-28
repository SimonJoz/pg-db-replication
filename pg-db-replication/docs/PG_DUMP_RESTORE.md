## Schema / Table / Partition size:

```postgresql
SELECT child.relname                                                         AS partition_name,
       pg_size_pretty(pg_total_relation_size('reporting.' || child.relname)) AS total_size,
       pg_size_pretty(pg_relation_size('reporting.' || child.relname))       AS table_size
FROM pg_inherits
         JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
         JOIN pg_class child ON pg_inherits.inhrelid = child.oid
WHERE parent.relname = 'transactions'
  AND parent.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'reporting');
```

```postgresql
SELECT table_schema,
       pg_size_pretty(sum(pg_total_relation_size(table_schema || '.' || table_name))) AS total_size
FROM information_schema.tables
WHERE table_schema = 'md'
GROUP BY table_schema;
```

## DB DUMPING

1. Dump global server objects

```bash
pg_dumpall -h localhost -p 9000 -U master -g --no-role-passwords > globals.sql
```

2. Dump pre-data section of schema.

```bash
pg_dump -h localhost -p 5432 -U myuser -d mydb -v --schema-only --section=pre-data > pre-data-schema.sql
```

3. Dump post-data section of schema.

```bash
pg_dump -h localhost -p 5432 -U myuser -d mydb -v --schema-only --section=post-data > post-data-schema.sql
```

4. Dump only data (from given schema) - replace <your_schema_name> placeholder.

```bash
pg_dump -h localhost -p 5432 -U myuser -d mydb -n my_schema_name -v --section=data --data-only --file=dwprep2-qc-data-dump.sql
```

5. From one DB to another

```bash
pg_dump -v -a -t table_to_copy -h localhost -p 9000 -U myuser -d mydb --section=data --data-only | psql -h localhost -p 9007 -U myuser -d mydb -v ON_ERROR_STOP=1 -v ECHO=all > dump_and_restore_log.txt 2>&1
```

6. Monitoring:

```postgresql
SELECT pid, state, state_change, age(clock_timestamp(), query_start), usename, query
FROM pg_stat_activity
WHERE application_name in ('psql', 'pg_dump', 'pg_dumpall' 'pg_restore');
```

```postgresql
SELECT pid, state, age(clock_timestamp(), query_start), usename, query
FROM pg_stat_activity
WHERE query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start desc;
```

```postgresql
SELECT a.datname,
       l.relation::regclass,
       l.transactionid,
       l.mode,
       l.GRANTED,
       a.usename,
       a.query,
       a.query_start,
       age(now(), a.query_start) AS "age",
       a.pid
FROM pg_stat_activity a
         JOIN pg_locks l ON l.pid = a.pid
where query not like '%pg_stat_activity%'
ORDER BY a.query_start;
```

## Dump data from a specific partition of a partitioned table

```bash
pg_dump -h localhost -p 5432 -U myuser -d mydb --table your_partitioned_table -v --section=data --data-only --where "id >= 1000 AND id < 2000" -F c -f output_file.dump
```

- With compression:

```bash
pg_dump -h localhost -p 5432 -U myuser -d mydb --table your_partitioned_table -v --section=data --data-only --where "id >= 1000 AND id < 2000" -F c -Z 9 -f my_data_dump.sql.gz
```

### Restoring Data:

```bash
psql -h localhost -p 5432 -U myuser -d mydb -v ON_ERROR_STOP=1 -v ECHO=all -f data-dump.sql
```

After obtaining the dump file, create the target database and use `pg_restore` to restore the data:

```bash
pg_restore -h localhost -p 5432 -U myuser -d mydb -F c -v output_file.dump
```

- With decompression:

```bash
gunzip -c my_data_dump.sql.gz | pg_restore -h localhost -p 5432 -U myuser -d mydb -v
```

### Useful

```bash
psql -h localhost -U master -d dwprep \
-a -b -e -L session-log.txt -v ON_ERROR_STOP=1 -f dwprep2-post-data-schema.sql
```

**Explanation:**

- `-F c`: Specifies the custom format for the dump file.
- `-v`: Verbose mode.

## LOGICAL REPLICATION

1. Create a Publication:

```postgresql
CREATE PUBLICATION my_pub FOR TABLE your_table;
```

2. Create a Subscription (destination) database:

```postgresql
CREATE SUBSCRIPTION my_sub CONNECTION 'host=source_host dbname=source_db user=your_user password=your_password' PUBLICATION my_pub;
```

3. Verify and Monitor (destination) database:

Monitor the replication status and ensure that changes to the specified table are being replicated.

```postgresql
SELECT *
FROM pg_stat_subscription;
```


