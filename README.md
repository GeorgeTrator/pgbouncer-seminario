# PgBouncer: connection pooling e escalabilidade de conexões

Seminario de BANCO DE DADOS II (UDESC), professor Fabiano Baldo.

Integrantes: George Henrique dos Santos e Mateus Pereira Nepomuceno.

Demonstra o custo do modelo processo-por-conexao do PostgreSQL e como o PgBouncer mitiga isso.

## Requisitos
- Docker com Docker Compose (testado em WSL2/Ubuntu, PostgreSQL 16, PgBouncer 1.26)

## Como rodar
```bash
git clone https://github.com/GeorgeTrator/pgbouncer-seminario.git
cd pgbouncer-seminario
docker compose up -d
./01_custo_conexoes.sh
./02_modos_pooling.sh
./03_limitacoes.sh
./04_benchmark.sh   # opcional, leva alguns minutos
```
Credenciais de teste: usuario `app`, senha `app123`, banco `bench`. Em producao, nunca versionar senhas.

## Arquivos
| Arquivo | O que demonstra |
|---|---|
| `docker-compose.yml` | Postgres 16 (max_connections=100) e PgBouncer |
| `pgbouncer.ini` | pool_mode, max_client_conn, default_pool_size, auth_type |
| `01_custo_conexoes.sh` | 110 clientes direto (10 recusados) vs 300 via PgBouncer (~20 conexoes reais) |
| `02_modos_pooling.sh` | session, transaction e statement com pool de 1 conexao |
| `03_limitacoes.sh` | `SET` vaza em transaction mode; `SET LOCAL` nao vaza |
| `04_benchmark.sh` | pgbench direto vs PgBouncer |
| `resultados.md` | numeros do benchmark |
| `set_cfg.sh` | auxiliar: altera o pgbouncer.ini e reinicia o PgBouncer |

## Resultados resumidos
- Direto com 110 clientes: 100 aceitos, 10 recusados (`too many clients already`).
- Via PgBouncer com 300 clientes: todos atendidos com ~20 conexoes reais.
- Modo session: segundo cliente esperou ~18 s. Transaction: atendido na hora. Statement: `BEGIN` recusado.
- Prepared statements: com `max_prepared_statements = 0`, erro `prepared statement "P_0" already exists`; com 200 (padrao na 1.26), funciona.
- Benchmark: com conexoes persistentes o PgBouncer foi mais lento (~5x); com conexoes curtas (`-C`) foi ~4x mais rapido.

## Limitacoes e ressalvas
- Benchmark rodou num notebook, dentro do WSL2, com o pgbench no mesmo container do Postgres. Valores absolutos nao valem para producao; vale a comparacao entre cenarios.
- Cada numero vem de poucas execucoes. Com `-C` e muitas repeticoes, as portas do SO esgotam (`Cannot assign requested address`).
- Direto com 90 clientes e `-C` fica no limite de 100 conexoes e pode falhar.
- LISTEN e cursores WITH HOLD, e o pgpool-II, sao discutidos so nos slides.
