#!/bin/bash
# Demo 2: modos de pooling (pool com 1 conexao real)
PGB='docker compose exec -e PGPASSWORD=app123 postgres psql -h pgbouncer -p 6432 -U app bench'
./set_cfg.sh default_pool_size 1

for modo in transaction session; do
  echo "=== MODO $modo ==="
  ./set_cfg.sh pool_mode $modo
  docker compose exec -d -e PGPASSWORD=app123 postgres psql -h pgbouncer -p 6432 -U app bench -c "SELECT 'cliente 1 conectado';" -c "\! sleep 20"
  sleep 2
  echo "Cliente 2 tentando consultar enquanto o cliente 1 esta parado..."
  time $PGB -c "SELECT 'cliente 2 atendido' AS resultado;"
  echo
done

echo "=== MODO statement: bloco de transacao deve ser recusado ==="
./set_cfg.sh pool_mode statement
$PGB -c "BEGIN;" -c "SELECT 1;" -c "SELECT 2;" -c "COMMIT;"

./set_cfg.sh pool_mode transaction
./set_cfg.sh default_pool_size 20
echo "Configuracao restaurada (transaction, pool 20)."
