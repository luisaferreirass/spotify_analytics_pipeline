from abc import ABC, abstractmethod
from auth.spotify_auth import get_spotify_client
from database.repository import Repository


class Collector(ABC):
    def __init__(self):
        self.client = get_spotify_client()
        self.repository = Repository()
        self._processed_artist_ids = set()
        self._track_details_cache = {}

    def save_artist_with_details(self, artist):
        artist_id = artist.get("id") if artist else None

        if not artist_id:
            return

        if artist_id in self._processed_artist_ids:
            return

        if artist and artist.get("name"):
            self.repository.save_artist(artist)

        self._processed_artist_ids.add(artist_id)

    def save_track_with_details(self, track):
        track_id = track.get("id") if track else None

        if not track_id:
            return track

        has_details = self._track_has_dashboard_fields(track)

        if not has_details:
            needs_details = self.repository.track_needs_details(track_id)

            if needs_details:
                track = self._track_details_cache.get(track_id)

                if not track:
                    track = self.client.track(track_id)
                    self._track_details_cache[track_id] = track

                has_details = self._track_has_dashboard_fields(track)

        album = track.get("album") if track else None
        artists = track.get("artists", []) if track else []

        if album:
            self.repository.save_album(album)

        for artist in artists:
            self.save_artist_with_details(artist)

        if track and track.get("name"):
            self.repository.save_track(track)

        if has_details:
            self.repository.save_track_popularity_snapshot(
                track_id,
                track.get("popularity")
            )

        for artist in artists:
            self.repository.save_track_artist(
                track_id,
                artist.get("id")
            )

        return track

    def _track_has_dashboard_fields(self, track):
        external_urls = track.get("external_urls") if track else None
        album = track.get("album") if track else None

        return (
            bool(track)
            and track.get("name") is not None
            and album is not None
            and album.get("id") is not None
            and track.get("duration_ms") is not None
            and track.get("popularity") is not None
            and track.get("explicit") is not None
            and external_urls is not None
            and external_urls.get("spotify") is not None
        )

    @abstractmethod
    def collect(self):
        pass
