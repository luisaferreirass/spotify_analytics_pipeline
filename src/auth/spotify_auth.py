import spotipy
from spotipy.oauth2 import SpotifyOAuth
import config.settings as st


def validate_envs(id, secret, uri):
    if not id:
        raise ValueError("SPOTIFY_CLIENT_ID não foi definido no .env")

    if not secret:
        raise ValueError("SPOTIFY_CLIENT_SECRET não foi definido no .env")

    if not uri:
        raise ValueError("SPOTIFY_REDIRECT_URI não foi definido no .env")

def get_spotify_client():
    validate_envs(st.SPOTIFY_CLIENT_ID, st.SPOTIFY_CLIENT_SECRET, st.SPOTIFY_REDIRECT_URI)
    
    auth_manager = SpotifyOAuth(
    client_id=st.SPOTIFY_CLIENT_ID,
    client_secret=st.SPOTIFY_CLIENT_SECRET,
    redirect_uri=st.SPOTIFY_REDIRECT_URI,
    scope=" ".join(st.SPOTIFY_SCOPES),
    cache_path=".spotify_cache"
    )

    spotify_client = spotipy.Spotify(auth_manager=auth_manager)

    return spotify_client