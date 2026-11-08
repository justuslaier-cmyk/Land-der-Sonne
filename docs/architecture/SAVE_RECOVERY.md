# Save durability policy

## Implemented prototype
The world save is written to a temporary file, validated, and promoted. A prior save is moved to a backup. Loading falls back to the backup when the primary is missing or invalid. CI exercises recovery after corrupting the primary.

## Known limitations
This is not a transactional database. A crash at certain rename boundaries may leave only the backup; a crash after moving the primary but before promoting the temporary file can be recovered through backup. The backup is currently replaced before the primary is promoted, so a failed write/rename may still reduce redundancy. Filesystem durability and concurrent writers are not guaranteed. The current schema is intentionally small and does not support migrations, checksums, entity data, compression or cloud sync.

## Production gate
Before persistent large-world saves: atomicity and crash-injection tests, recovery of temporary saves, version migrations, checksum validation, file locking, retention policy, corruption reporting and bounded chunk-delta storage.
