# Spotify Analytics Pipeline

**End-to-end Data Engineering** pipeline to collect, store, process and serve data from the Spotify API.

The project automates the ingestion of the user's account information, stores the data in a PostgreSQL database, runs scheduled collections with Apache Airflow and serves analytical indicators through a FastAPI API and a web dashboard.

Beyond data collection, the pipeline keeps a time-based history of rankings, library and plays, enabling analysis of listening habits over time.

---

# Architecture

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

# Key Features

- OAuth2 authentication with Spotify.
- Automatic collection of the user's account data.
- Relational data model stored in PostgreSQL.
- History of recent plays.
- Synchronization of saved tracks and albums.
- Historical record of artist and track rankings.
- Track popularity history.
- SQL views built for analytics.
- REST API built with FastAPI.
- Web dashboard consuming the API.
- Full orchestration with Apache Airflow.
- Fully containerized environment with Docker Compose.

---

# Stack

| Category | Technologies |
|-----------|-------------|
| Language | Python |
| Database | PostgreSQL |
| Orchestration | Apache Airflow |
| API | FastAPI |
| Spotify | Spotipy |
| Containerization | Docker Compose |
| Front-end | HTML, CSS and JavaScript |

---

# Collected Data

The pipeline collects and keeps a history of the following datasets.

## Profile

- Name
- Country
- Email
- Followers
- Photo
- Collection date

## Artists

- Name
- Popularity
- Image
- Popularity history

## Albums

- Name
- Release date
- Number of tracks
- Cover

## Tracks

- Name
- Album
- Duration
- Popularity
- Explicit content
- Preview
- Spotify URL

## Library

- Liked songs
- Saved albums
- Date added

## History

- Recently played tracks
- Play time

## Rankings

Snapshots of:

- Top Tracks
- Top Artists

for the periods:

- Short Term
- Medium Term
- Long Term

---

# Available Metrics

The project generates several analytical metrics through SQL views.

## Overview

- Total plays
- Total liked songs
- Total saved albums
- Unique tracks
- Unique artists
- Average popularity

## History

- Monthly evolution of plays
- Evolution of unique artists
- Evolution of unique tracks
- Evolution of unique albums
- Plays per day
- Plays per hour
- Distribution by day of the week
- Track repetition trend

## Rankings

- Top artists
- Top tracks
- Top albums

## Library

- Library evolution
- Most frequent artists
- Full list of liked songs

## Trends

- Monthly artist growth
- Track popularity history
- History of collected rankings

---

# Dashboard

The dashboard is split into five modules.

## Overview

General account indicators.

- Total plays
- Liked songs
- Saved albums
- Average popularity
- Unique artists
- Unique tracks

## History

Time-based visualizations.

- Monthly evolution
- Distribution by hour
- Plays per day
- Top artists
- Top albums

## Library

- Saved tracks
- Most frequent artists

## Rankings

Rankings view for:

- Short Term
- Medium Term
- Long Term

## Account

Screen for configuring Spotify authentication.

> If the API is not available yet or no data has been collected, the dashboard falls back to local data to keep the whole interface functional.

---

# Orchestration with Airflow

The project has four independent DAGs.

| DAG | Frequency | Purpose |
|------|-----------|----------|
| `spotify_quick_collection` | Every 30 minutes | Profile + recent history |
| `spotify_library_collection` | Daily at 03:00 | Library |
| `spotify_rankings_collection` | Daily at 04:00 | Rankings |
| `spotify_full_collection` | Manual | Runs all collectors |

The DAGs are created paused by default.

---

# Project Structure

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

# How to Run

Clone the repository.

```bash
git clone <repository>

cd spotify-analytics
```

Create the `.env` file.

```bash
cp .env.example .env
```

Set the environment variables.

```env
POSTGRES_DB=spotify_analytics
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret
SPOTIFY_REDIRECT_URI=http://127.0.0.1:8888/callback
```

Start the whole infrastructure.

```bash
docker compose up --build
```

Once started, the services will be available at:

| Service | URL |
|----------|-----|
| Dashboard | http://localhost:8000 |
| API | http://localhost:8000 |
| Airflow | http://localhost:8080 |

Default Airflow credentials:

```text
Username: admin
Password: admin
```

---

# Manual Execution

You can also run the collectors directly, without Airflow.

```bash
python src/main.py --mode quick

python src/main.py --mode library

python src/main.py --mode rankings

python src/main.py --mode full
```

## Available modes

| Mode | Description |
|------|-----------|
| `quick` | Collects profile and recent history |
| `library` | Updates the library |
| `rankings` | Updates rankings |
| `full` | Runs all collections |

---

# API

Main available endpoints.

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

## Done

- [x] OAuth2 authentication
- [x] Profile collection
- [x] Recent history collection
- [x] Track library
- [x] Album library
- [x] Rankings by period
- [x] PostgreSQL
- [x] Analytical views
- [x] FastAPI
- [x] Web Dashboard
- [x] Docker Compose
- [x] Apache Airflow

## Future Improvements

- Automated tests
- Monitoring and logging
- Query caching
- Report export
- CI/CD with GitHub Actions
