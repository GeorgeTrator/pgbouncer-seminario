#!/bin/bash
# Uso: ./set_cfg.sh chave valor   (ex.: ./set_cfg.sh pool_mode session)
# Altera o pgbouncer.ini e reinicia o PgBouncer.
# Usa "cat >" para manter o mesmo arquivo montado no container.
sed "s/^$1 *=.*/$1 = $2/" pgbouncer.ini > /tmp/pgb.ini && cat /tmp/pgb.ini > pgbouncer.ini
docker compose restart pgbouncer > /dev/null 2>&1
sleep 3
