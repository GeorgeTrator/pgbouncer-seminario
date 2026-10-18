#!/bin/bash
# Demo 1: custo do modelo processo-por-conexao do PostgreSQL

run() { docker compose exec -T postgres bash -c "export PGPASSWORD=app123; $1"; }

echo "=== 1) DIRETO no Postgres: 110 clientes (limite max_connections=100) ==="
run 'for i in $(seq 1 110); do psql -h postgres -p 5432 -U app bench -c "SELECT pg_sleep(10);" > /dev/null & done; sleep 4; echo "Conexoes abertas (processos):"; ps aux | grep -c "[p]ostgres: app bench"; wait'

echo
echo "=== 2) VIA PGBOUNCER: 300 clientes ==="
run 'for i in $(seq 1 300); do psql -h pgbouncer -p 6432 -U app bench -c "SELECT pg_sleep(2);" > /dev/null 2>&1 & done; sleep 3; echo "Conexoes reais no Postgres:"; ps aux | grep -c "[p]ostgres: app bench"; wait; echo "Todos os 300 clientes foram atendidos"'
