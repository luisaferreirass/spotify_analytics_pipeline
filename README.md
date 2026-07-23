# Spotify Analytics Pipeline

Pipeline **end-to-end de Engenharia de Dados** para coletar, armazenar, processar e disponibilizar dados da API do Spotify.

O projeto automatiza a ingestão de informações da conta do usuário, armazena os dados em um banco PostgreSQL, executa coletas agendadas com Apache Airflow e disponibiliza indicadores analíticos por meio de uma API FastAPI e um dashboard web.

Além da coleta de dados, o pipeline mantém histórico temporal de rankings, biblioteca e reproduções, permitindo análises sobre hábitos musicais ao longo do tempo.

---

# Arquitetura

```text
                Spotify API
                     │
                     ▼
          Python Data Collectors
                     │
                     ▼
              PostgreSQL Database
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
 SQL Analytics Views         Apache Airflow
        │                         │
        └────────────┬────────────┘
                     ▼
                 FastAPI
                     │
                     ▼
              Web Dashboard
```

---

# Principais Funcionalidades

- Autenticação OAuth2 com Spotify.
- Coleta automática de dados da conta do usuário.
- Armazenamento em modelo relacional no PostgreSQL.
- Histórico de reproduções recentes.
- Sincronização da biblioteca de músicas e álbuns salvos.
- Registro histórico dos rankings de artistas e músicas.
- Histórico da popularidade das músicas.
- Criação de views SQL voltadas para análise.
- API REST construída com FastAPI.
- Dashboard web consumindo a API.
- Orquestração completa utilizando Apache Airflow.
- Ambiente totalmente containerizado com Docker Compose.

---

# Stack

| Categoria | Tecnologias |
|-----------|-------------|
| Linguagem | Python |
| Banco de Dados | PostgreSQL |
| Orquestração | Apache Airflow |
| API | FastAPI |
| Spotify | Spotipy |
| Containerização | Docker Compose |
| Front-end | HTML, CSS e JavaScript |

---

# Dados Coletados

O pipeline coleta e mantém histórico dos seguintes conjuntos de dados.

## Perfil

- Nome
- País
- Email
- Seguidores
- Foto
- Data da coleta

## Artistas

- Nome
- Popularidade
- Imagem
- Histórico de popularidade

## Álbuns

- Nome
- Data de lançamento
- Número de faixas
- Capa

## Músicas

- Nome
- Álbum
- Duração
- Popularidade
- Conteúdo explícito
- Preview
- URL Spotify

## Biblioteca

- Músicas curtidas
- Álbuns salvos
- Data de adição

## Histórico

- Músicas reproduzidas recentemente
- Horário da reprodução

## Rankings

Snapshots de:

- Top Tracks
- Top Artists

nos períodos:

- Short Term
- Medium Term
- Long Term

---

# Métricas Disponíveis

O projeto gera diversas métricas analíticas por meio de views SQL.

## Overview

- Total de reproduções
- Total de músicas curtidas
- Total de álbuns salvos
- Músicas únicas
- Artistas únicos
- Popularidade média

## Histórico

- Evolução mensal de reproduções
- Evolução de artistas únicos
- Evolução de músicas únicas
- Evolução de álbuns únicos
- Plays por dia
- Plays por horário
- Distribuição por dia da semana
- Tendência de repetição de músicas

## Rankings

- Top artistas
- Top músicas
- Top álbuns

## Biblioteca

- Evolução da biblioteca
- Artistas mais presentes
- Lista completa das músicas curtidas

## Tendências

- Crescimento mensal de artistas
- Histórico de popularidade das músicas
- Histórico dos rankings coletados

---

# Dashboard

O dashboard é dividido em cinco módulos.

## Overview

Indicadores gerais da conta.

- Total de plays
- Músicas curtidas
- Álbuns salvos
- Popularidade média
- Artistas únicos
- Músicas únicas

## Histórico

Visualizações temporais.

- Evolução mensal
- Distribuição por horário
- Plays por dia
- Top artistas
- Top álbuns

## Biblioteca

- Músicas salvas
- Artistas mais presentes

## Rankings

Visualização dos rankings para:

- Short Term
- Medium Term
- Long Term

## Conta

Tela destinada à configuração da autenticação do Spotify.

> Caso a API ainda não esteja disponível ou não existam dados coletados, o dashboard utiliza dados locais para manter toda a interface funcional.

---

# Orquestração com Airflow

O projeto possui quatro DAGs independentes.

| DAG | Frequência | Objetivo |
|------|-----------|----------|
| `spotify_quick_collection` | A cada 30 minutos | Perfil + histórico recente |
| `spotify_library_collection` | Diariamente às 03:00 | Biblioteca |
| `spotify_rankings_collection` | Diariamente às 04:00 | Rankings |
| `spotify_full_collection` | Manual | Executa todos os coletores |

As DAGs são criadas pausadas por padrão.

---

# Estrutura do Projeto

```text
.
├── dags/
├── dashboards/
├── sql/
│   ├── schema.sql
│   └── views.sql
├── src/
│   ├── auth/
│   ├── collectors/
│   ├── config/
│   ├── database/
│   ├── services/
│   ├── api.py
│   └── main.py
├── docker-compose.yml
└── README.md
```

---

# Como Executar

Clone o repositório.

```bash
git clone <repositorio>

cd spotify-analytics
```

Crie o arquivo `.env`.

```bash
cp .env.example .env
```

Configure as variáveis de ambiente.

```env
POSTGRES_DB=spotify_analytics
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

SPOTIFY_CLIENT_ID=seu_client_id
SPOTIFY_CLIENT_SECRET=seu_client_secret
SPOTIFY_REDIRECT_URI=http://127.0.0.1:8888/callback
```

Suba toda a infraestrutura.

```bash
docker compose up --build
```

Após a inicialização, os serviços estarão disponíveis em:

| Serviço | URL |
|----------|-----|
| Dashboard | http://localhost:8000 |
| API | http://localhost:8000 |
| Airflow | http://localhost:8080 |

Credenciais padrão do Airflow:

```text
Usuário: admin
Senha: admin
```

---

# Execução Manual

Também é possível executar os coletores diretamente, sem utilizar o Airflow.

```bash
python src/main.py --mode quick

python src/main.py --mode library

python src/main.py --mode rankings

python src/main.py --mode full
```

## Modos disponíveis

| Modo | Descrição |
|------|-----------|
| `quick` | Coleta perfil e histórico recente |
| `library` | Atualiza biblioteca |
| `rankings` | Atualiza rankings |
| `full` | Executa todas as coletas |

---

# API

Principais endpoints disponíveis.

```http
GET /health

GET /dashboard/overview

GET /dashboard/monthly-evolution

GET /dashboard/plays-by-day

GET /dashboard/plays-by-hour

GET /dashboard/top-artists

GET /dashboard/top-albums

GET /dashboard/library/saved-tracks

GET /dashboard/library/top-artists

GET /dashboard/rankings/{time_range}

GET /dashboard/trends/artist-growth
```

---

# Roadmap

## Concluído

- [x] Autenticação OAuth2
- [x] Coleta de perfil
- [x] Coleta de histórico recente
- [x] Biblioteca de músicas
- [x] Biblioteca de álbuns
- [x] Rankings por período
- [x] PostgreSQL
- [x] Views analíticas
- [x] FastAPI
- [x] Dashboard Web
- [x] Docker Compose
- [x] Apache Airflow

## Melhorias Futuras

- Testes automatizados
- Monitoramento e logs
- Cache de consultas
- Exportação de relatórios
- CI/CD com GitHub Actions

