#!/bin/bash
# Demo 3: SET vaza em transaction mode; SET LOCAL nao vaza (pool com 1 conexao real)
PGB='docker compose exec -e PGPASSWORD=app123 postgres psql -h pgbouncer -p 6432 -U app bench'
./set_cfg.sh pool_mode transaction
./set_cfg.sh default_pool_size 1

echo "=== 0) BASELINE: antes de qualquer SET ==="
$PGB -c "SHOW statement_timeout;" -c "SELECT pg_backend_pid();"
echo "=== 1) CLIENTE A faz SET ==="
$PGB -c "SET statement_timeout = '1234ms';" -c "SELECT pg_backend_pid();"
echo "=== 2) CLIENTE B (nao fez SET) ==="
$PGB -c "SHOW statement_timeout;" -c "SELECT pg_backend_pid();"
$PGB -c "RESET statement_timeout;" > /dev/null

echo "=== 3) SET LOCAL: vale so dentro da transacao ==="
$PGB -c "BEGIN; SET LOCAL statement_timeout = '1234ms'; SHOW statement_timeout; COMMIT;"
$PGB -c "SHOW statement_timeout;"

./set_cfg.sh default_pool_size 20
echo "Configuracao restaurada (pool 20)."
