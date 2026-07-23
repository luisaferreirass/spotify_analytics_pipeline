from decimal import Decimal
from pathlib import Path
from urllib.parse import urlencode

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from config.settings import SPOTIFY_CLIENT_ID, SPOTIFY_REDIRECT_URI
from database.connection import get_connection


app = FastAPI(title="Spotify Dashboard API")
PROJECT_ROOT = Path(__file__).resolve().parents[1]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class AuthConfig(BaseModel):
    client_id: str
    redirect_uri: str
    scopes: str


def serialize_value(value):
    if isinstance(value, Decimal):
        return float(value)

    if hasattr(value, "isoformat"):
        return value.isoformat()

    return value


def query_rows(query, params=None):
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(query, params or ())
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()

        return [
            {
                column: serialize_value(value)
                for column, value in zip(columns, row)
            }
            for row in rows
        ]
    finally:
        connection.close()


def query_one(query, params=None):
    rows = query_rows(query, params)
    return rows[0] if rows else {}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/auth/status")
def auth_status():
    return {
        "connected": False,
        "has_credentials": bool(SPOTIFY_CLIENT_ID and SPOTIFY_REDIRECT_URI),
    }


@app.post("/auth/config")
def save_auth_config(config: AuthConfig):
    return {
        "saved": True,
        "client_id": config.client_id,
        "redirect_uri": config.redirect_uri,
        "scopes": config.scopes,
    }


@app.post("/auth/login-url")
def build_login_url(config: AuthConfig):
    params = urlencode({
        "client_id": config.client_id,
        "response_type": "code",
        "redirect_uri": config.redirect_uri,
        "scope": config.scopes,
    })

    return {
        "url": f"https://accounts.spotify.com/authorize?{params}"
    }


@app.get("/dashboard/overview")
def dashboard_overview():
    return query_one("SELECT * FROM vw_api_overview_stats;")


@app.get("/dashboard/monthly-evolution")
def monthly_evolution():
    return query_rows("SELECT * FROM vw_api_monthly_evolution;")


@app.get("/dashboard/plays-by-day")
def plays_by_day():
    return query_rows("SELECT * FROM vw_api_plays_by_day;")


@app.get("/dashboard/plays-by-hour")
def plays_by_hour():
    return query_one("SELECT * FROM vw_api_plays_by_hour;").get("plays_by_hour", [])


@app.get("/dashboard/top-artists")
def top_artists():
    return query_rows("SELECT * FROM vw_api_top_artists;")


@app.get("/dashboard/top-albums")
def top_albums():
    return query_rows("SELECT * FROM vw_api_top_albums;")


@app.get("/dashboard/library/saved-tracks")
def saved_tracks():
    return query_rows("SELECT * FROM vw_api_saved_tracks;")


@app.get("/dashboard/library/top-artists")
def library_top_artists():
    return query_rows("SELECT * FROM vw_api_library_top_artists;")


@app.get("/dashboard/rankings/{time_range}")
def rankings(time_range: str):
    if time_range not in {"short_term", "medium_term", "long_term"}:
        raise HTTPException(status_code=400, detail="time_range invalido")

    tracks = query_rows("""
        SELECT name, value, meta
        FROM vw_api_latest_top_tracks
        WHERE time_range = %s
        ORDER BY value
        LIMIT 50;
    """, (time_range,))

    artists = query_rows("""
        SELECT name, value, meta
        FROM vw_api_latest_top_artists
        WHERE time_range = %s
        ORDER BY value
        LIMIT 50;
    """, (time_range,))

    return {
        "tracks": tracks,
        "artists": artists,
    }


@app.get("/dashboard/trends/artist-growth")
def artist_growth():
    return query_rows("SELECT * FROM vw_api_artist_growth;")


app.mount(
    "/",
    StaticFiles(directory=PROJECT_ROOT / "dashboards", html=True),
    name="dashboard",
)