#!/bin/bash
# Benchmark pgbench: direto (5432) vs PgBouncer (6432). Requer: pgbench -i -s 10 ja executado.
# Obs.: com -C e muitas repeticoes, as portas do SO podem esgotar ("Cannot assign requested address").
PGB='docker compose exec -e PGPASSWORD=app123 postgres pgbench -S -j 4 -T 15 -U app bench'
F='tps|latency|failed'
docker compose exec -e PGPASSWORD=app123 postgres pgbench -i -s 10 -h postgres -p 5432 -U app bench > /dev/null 2>&1

echo "--- Conexoes persistentes, 50 clientes ---"
echo "[direto]";    $PGB -c 50 -h postgres  -p 5432 | grep -E "$F"
echo "[pgbouncer]"; $PGB -c 50 -h pgbouncer -p 6432 | grep -E "$F"
echo "--- Conexoes curtas (-C), 50 clientes ---"
echo "[direto]";    $PGB -C -c 50 -h postgres  -p 5432 | grep -E "$F"
echo "[pgbouncer]"; $PGB -C -c 50 -h pgbouncer -p 6432 | grep -E "$F"
echo "--- Conexoes curtas (-C), 300 clientes (so PgBouncer; direto passa do limite de 100) ---"
echo "[pgbouncer]"; $PGB -C -c 300 -h pgbouncer -p 6432 | grep -E "$F"
