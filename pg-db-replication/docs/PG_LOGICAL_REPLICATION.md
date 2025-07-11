## 🔄 PostgreSQL Logical Replication – Pub/Sub

This section documents common SQL commands for managing **logical replication** using **publications**, **subscriptions**, and **replication slots** in PostgreSQL.

---


### ⚙️ Prerequisites

* **PostgreSQL version:**
  - Logical replication requires PostgreSQL 10 or newer.

* **WAL level:**
  - The publisher must have `wal_level` set to `logical`.

* **Replication user privileges:**
  - The subscriber user must have the `REPLICATION` role and SELECT privileges on all published tables.

* **Schema compatibility:**
  - The subscriber tables must have a compatible schema with the publisher tables (matching columns, types, etc.).

* **Replication slots:**
  - Ensure enough replication slots and wal_senders are configured on the publisher to support your subscriptions.

* **AWS RDS**
  - Ensure `rds.logical_replication = 1` parameter is enabled. Use the `rds_replication` role for replication users.


### ⚠️ Caveats

* **WAL retention & disk usage**
  - Replication slots prevent removal of WAL segments until subscribers consume them. Lagging subscribers can cause disk bloat.

* **One slot per subscriber**
  - Do not share replication slots between subscriptions; each subscription needs its own slot to track progress.

* **Schema changes complexity**
  - Adding/removing columns or changing types requires careful coordination. Logical replication doesn’t auto-sync schema changes.

* **No support for DDL replication**
  - Logical replication only replicates data changes (DML), not schema changes (DDL).

* **Latency considerations**
  - Replication is asynchronous by default — expect slight delay between publisher and subscriber.


### ✅ Best Practices

* Use dedicated replication roles/users with minimal required privileges.
* Secure replication connections with SSL/TLS, especially over public networks.
* Keep PostgreSQL versions on publisher and subscriber closely aligned.
* Monitor disk space and WAL retention on the publisher regularly.
* Remove unused replication objects promptly to avoid resource leaks.

---

### ⚙️ Postgres Settings Verification


```sql
SELECT * FROM pg_settings 
WHERE name IN (
    'wal_level', -- must be logical
    'rds.logical_replication', -- 1 or on 
    'max_replication_slots' -- non-zero value 
);
```

---

### 🟢 Publisher Node

Publications define which tables and operations are available for logical replication.
They act as named change streams that subscribers can connect to.
Each publication can filter by table and by operation (e.g., only INSERT, or all DML).
Publications do not store data — they expose changes in WAL for subscribers to consume.

#### 📌 View Existing Publications

```sql
SELECT * FROM pg_publication;
SELECT * FROM pg_publication_tables;
SELECT * FROM pg_replication_slots WHERE slot_type = 'logical';
SELECT * FROM pg_stat_replication;
```

#### 🛠 Create a Publication

```sql
-- Basic publication for specific tables
CREATE PUBLICATION test_pub FOR TABLE table1, table2;

-- Publication with limited operations
CREATE PUBLICATION test_pub
FOR TABLE table1, table2
WITH (publish = 'insert, update');
```

#### ✏️ Modify Existing Publication

```sql
-- Add more tables
ALTER PUBLICATION test_pub ADD TABLE table1, table2;

-- Change published operations
ALTER PUBLICATION test_pub SET (publish = 'insert, delete, update, truncate');
```

#### ❌ Drop a Publication

```sql
DROP PUBLICATION test_pub;
```

#### ⚙️ Publication Options Reference

| Option                                  | Default                    | Description                                                                                                          |
|-----------------------------------------|----------------------------|----------------------------------------------------------------------------------------------------------------------|
| `publish`                               | `'insert, update, delete'` | Specifies which types of operations to replicate. Can include: `insert`, `update`, `delete`, `truncate`.             |
| `publish_via_partition_root`            | `false`                    | If `true`, changes to partitions are published as if they occurred on the root table. Useful for partitioned tables. |
| `publish_using_partition_root`          | `false` *(legacy/alias)*   | Synonym for `publish_via_partition_root` in older versions.                                                          |
| `publish_nulls` *(PostgreSQL 16+)*      | `true`                     | Controls whether `NULL` values are included in the replicated row. Advanced/rarely needed.                           |
| `publish_per_column` *(PostgreSQL 17+)* | `false`                    | Publishes only changed columns, not the full row. Useful for high-churn, wide tables.                                |


---

### 🟣 Subscriber Node

Subscriptions connect to publications and apply the changes locally.
A subscription creates a logical replication slot on the publisher to track progress.
It can optionally copy existing data (copy_data = true) or skip it (false).
Subscriptions are stateful and resume from where they left off, using WAL positions.

#### ✅ Create a Subscription

```sql
-- With initial data copy (default)
CREATE SUBSCRIPTION test_sub
CONNECTION 'host=pub_host port=5432 dbname=pub_db user=replicator password=secret'
PUBLICATION test_pub;

-- Without initial sync (copy_data = false)
-- Use only if tables are already in sync
CREATE SUBSCRIPTION test_sub
CONNECTION 'host=pub_host port=5432 dbname=pub_db user=replicator password=secret'
PUBLICATION test_pub
WITH (copy_data = false);
```

#### 📋 Check Subscriptions

```sql
SELECT * FROM pg_subscription;
SELECT * FROM pg_stat_subscription;
```

#### ❌ Drop a Subscription

```sql
DROP SUBSCRIPTION test_sub;
```

#### ⚙️ Subscription Options Reference

| Option               | Default | Description                                                                                                                                 |
|----------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `copy_data`          | `true`  | If `true`, an initial snapshot of the publication tables is copied to the subscriber. Set to `false` if data is already synced manually.    |
| `create_slot`        | `true`  | If `false`, prevents the subscription from creating a replication slot on the publisher. Use if you want to manage the slot manually.       |
| `enabled`            | `true`  | If `false`, the subscription is created but not started. Useful for staging setup before replication begins.                                |
| `slot_name`          | *auto*  | Specify the replication slot name explicitly. Useful when `create_slot = false` or when multiple subscriptions target the same publication. |
| `synchronous_commit` | `on`    | Controls whether subscriber acknowledges commits synchronously. `off` can reduce latency but risks data loss in failover.                   |
| `two_phase`          | `false` | Enables two-phase commit replication (PostgreSQL 15+). Only relevant if using prepared transactions.                                        |

---

### 📦 Replication Slots

Replication slots ensure that WAL (Write-Ahead Log) changes required for replication are retained until they are consumed by subscribers.

#### 📍 View Existing Replication Slots

```sql
SELECT * FROM pg_replication_slots;
```

#### 🧱 Create a Logical Replication Slot (optional/manual)

```sql

-- pgoutput is a default logical decoding plugin that process WAL changes
-- and convert them into a readable format for logical replication or other consumers.
SELECT pg_create_logical_replication_slot('my_slot', 'pgoutput');
```

> You usually don’t need to do this manually unless you want external control over the slot.

#### 🧹 Drop a Replication Slot

```sql
SELECT pg_drop_replication_slot('my_slot');
```

⚠️ Do not drop a replication slot if an active subscription is still using it.

#### 🔍 Monitor Slot Activity

```sql
SELECT slot_name, database, active, restart_lsn, confirmed_flush_lsn
FROM pg_replication_slots
WHERE slot_type = 'logical';
```

---

### ❌ Potential errors

> This error occurs in PostgreSQL logical replication when deleting rows from a published table that lacks a replica
> identity. Without it, PostgreSQL cannot identify which row to delete on the subscriber.

```sql
 -- Use entire row as identity (higher overhead, no PK required)
ALTER TABLE table_name REPLICA IDENTITY FULL;

-- Use primary key or unique index as identity (preferred)
ALTER TABLE table_name REPLICA IDENTITY USING INDEX your_primary_key_index_name;
```

---

### 🧠 Testing

```sql
CREATE TABLE replication_test
(
  id   INT PRIMARY KEY,
  data TEXT
);


CREATE OR REPLACE FUNCTION test_replication_activity() RETURNS void AS
$$
DECLARE
  -- unique ID from current time
  new_id INT := EXTRACT(EPOCH FROM clock_timestamp())::INT; 
BEGIN
  -- Insert
  INSERT INTO replication_test (id, data)
  VALUES (new_id, 'inserted at ' || now());

  -- Wait 2 seconds, then update
  PERFORM pg_sleep(2);
  UPDATE replication_test
  SET data = 'updated at ' || now()
  WHERE id = new_id;

  -- Wait 8 more seconds (10s total), then delete
  PERFORM pg_sleep(8);
  DELETE FROM replication_test WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;
```
