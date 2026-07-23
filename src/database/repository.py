from .connection import get_connection



class Repository:
    def __init__(self):
        self.connection = get_connection()
        self.cursor = self.connection.cursor()

    def save_user(self, user):

        image_url = None
        if user.get("images"):
            image_url = user["images"][0].get("url")

        self.cursor.execute("""
        INSERT INTO spotify_users (
            spotify_user_id,
            display_name,
            country,
            email,
            followers,
            image_url
        )
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT (spotify_user_id)
        DO UPDATE SET
            display_name = EXCLUDED.display_name,
            country = EXCLUDED.country,
            email = EXCLUDED.email,
            followers = EXCLUDED.followers,
            image_url = EXCLUDED.image_url,
            collected_at = CURRENT_TIMESTAMP;
    """, (
        user.get("id"),
        user.get("display_name"),
        user.get("country"),
        user.get("email"),
        user.get("followers", {}).get("total"),
        image_url
    ))        

    def save_artist(self, artist):
        if not artist or not artist.get("id") or not artist.get("name"):
            return

        image_url = None
        if artist.get("images"):
            image_url = artist["images"][0].get("url")

        self.cursor.execute("""
            INSERT INTO artists (
                spotify_artist_id,
                artist_name,
                image_url
            )
            VALUES (%s, %s, %s)
            ON CONFLICT (spotify_artist_id)
            DO UPDATE SET
                artist_name = COALESCE(EXCLUDED.artist_name, artists.artist_name),
                image_url = COALESCE(EXCLUDED.image_url, artists.image_url),
                collected_at = CURRENT_TIMESTAMP
            WHERE
                artists.artist_name IS DISTINCT FROM COALESCE(EXCLUDED.artist_name, artists.artist_name)
                OR artists.image_url IS DISTINCT FROM COALESCE(EXCLUDED.image_url, artists.image_url);
        """, (
            artist.get("id"),
            artist.get("name"),
            image_url
        ))

    def save_album(self, album):

        image_url = None
        if album.get("images"):
            image_url = album["images"][0].get("url")

        self.cursor.execute("""
            INSERT INTO albums (
                spotify_album_id,
                album_name,
                release_date,
                total_tracks,
                image_url
            )
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (spotify_album_id)
            DO UPDATE SET
                album_name = EXCLUDED.album_name,
                release_date = EXCLUDED.release_date,
                total_tracks = EXCLUDED.total_tracks,
                image_url = EXCLUDED.image_url,
                collected_at = CURRENT_TIMESTAMP;
        """, (
            album.get("id"),
            album.get("name"),
            album.get("release_date"),
            album.get("total_tracks"),
            image_url
        ))


    def save_track(self, track):
        if not track or not track.get("id") or not track.get("name"):
            return

        spotify_url = None
        if track.get("external_urls"):
            spotify_url = track["external_urls"].get("spotify")

        album = track.get("album", {})

        self.cursor.execute("""
            INSERT INTO tracks (
                spotify_track_id,
                track_name,
                spotify_album_id,
                duration_ms,
                popularity,
                explicit,
                preview_url,
                spotify_url
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (spotify_track_id)
            DO UPDATE SET
                track_name = COALESCE(EXCLUDED.track_name, tracks.track_name),
                spotify_album_id = COALESCE(EXCLUDED.spotify_album_id, tracks.spotify_album_id),
                duration_ms = COALESCE(EXCLUDED.duration_ms, tracks.duration_ms),
                popularity = COALESCE(EXCLUDED.popularity, tracks.popularity),
                explicit = COALESCE(EXCLUDED.explicit, tracks.explicit),
                preview_url = COALESCE(EXCLUDED.preview_url, tracks.preview_url),
                spotify_url = COALESCE(EXCLUDED.spotify_url, tracks.spotify_url),
                collected_at = CURRENT_TIMESTAMP
            WHERE
                tracks.track_name IS DISTINCT FROM COALESCE(EXCLUDED.track_name, tracks.track_name)
                OR tracks.spotify_album_id IS DISTINCT FROM COALESCE(EXCLUDED.spotify_album_id, tracks.spotify_album_id)
                OR tracks.duration_ms IS DISTINCT FROM COALESCE(EXCLUDED.duration_ms, tracks.duration_ms)
                OR tracks.popularity IS DISTINCT FROM COALESCE(EXCLUDED.popularity, tracks.popularity)
                OR tracks.explicit IS DISTINCT FROM COALESCE(EXCLUDED.explicit, tracks.explicit)
                OR tracks.preview_url IS DISTINCT FROM COALESCE(EXCLUDED.preview_url, tracks.preview_url)
                OR tracks.spotify_url IS DISTINCT FROM COALESCE(EXCLUDED.spotify_url, tracks.spotify_url);
        """, (
            track.get("id"),
            track.get("name"),
            album.get("id"),
            track.get("duration_ms"),
            track.get("popularity"),
            track.get("explicit"),
            track.get("preview_url"),
            spotify_url
        ))

    def track_needs_details(self, track_id):
        if not track_id:
            return False

        self.cursor.execute("""
            SELECT
                track_name,
                spotify_album_id,
                duration_ms,
                popularity,
                explicit,
                spotify_url
            FROM tracks
            WHERE spotify_track_id = %s;
        """, (
            track_id,
        ))

        track = self.cursor.fetchone()

        if not track:
            return True

        track_name, album_id, duration_ms, popularity, explicit, spotify_url = track
        return (
            track_name is None
            or album_id is None
            or duration_ms is None
            or popularity is None
            or explicit is None
            or spotify_url is None
        )

    def save_track_popularity_snapshot(self, track_id, popularity):
        if not track_id or popularity is None:
            return

        self.cursor.execute("""
            INSERT INTO track_popularity_snapshots (
                spotify_track_id,
                popularity
            )
            SELECT %s, %s
            WHERE (
                SELECT popularity
                FROM track_popularity_snapshots
                WHERE spotify_track_id = %s
                ORDER BY collected_at DESC, id DESC
                LIMIT 1
            ) IS DISTINCT FROM %s;
        """, (
            track_id,
            popularity,
            track_id,
            popularity
        ))


    def save_track_artist(self, track_id, artist_id):

        self.cursor.execute("""
            INSERT INTO track_artists (
                spotify_track_id,
                spotify_artist_id
            )
            VALUES (%s, %s)
            ON CONFLICT (spotify_track_id, spotify_artist_id)
            DO NOTHING;
        """, (
            track_id,
            artist_id
        ))



    def save_recently_played(self, track_id, played_at):

        self.cursor.execute("""
            INSERT INTO recently_played (
                spotify_track_id,
                played_at
            )
            VALUES (%s, %s)
            ON CONFLICT (spotify_track_id, played_at)
            DO NOTHING;
        """, (
            track_id,
            played_at
        ))




    def save_saved_track(self, track_id, added_at):

        self.cursor.execute("""
            INSERT INTO saved_tracks (
                spotify_track_id,
                added_at
            )
            VALUES (%s, %s)
            ON CONFLICT (spotify_track_id)
            DO UPDATE SET
                added_at = EXCLUDED.added_at,
                collected_at = CURRENT_TIMESTAMP;
        """, (
            track_id,
            added_at
        ))



    def save_saved_album(self, album_id, added_at):

        self.cursor.execute("""
            INSERT INTO saved_albums (
                spotify_album_id,
                added_at
            )
            VALUES (%s, %s)
            ON CONFLICT (spotify_album_id)
            DO UPDATE SET
                added_at = EXCLUDED.added_at,
                collected_at = CURRENT_TIMESTAMP
            WHERE
                saved_albums.added_at IS DISTINCT FROM EXCLUDED.added_at;
        """, (
            album_id,
            added_at
        ))



    def save_top_track_snapshot(self, track_id, time_range, ranking_position):

        self.cursor.execute("""
            INSERT INTO top_tracks_snapshots (
                spotify_track_id,
                time_range,
                ranking_position
            )
            VALUES (%s, %s, %s);
        """, (
            track_id,
            time_range,
            ranking_position
        ))




    def save_top_artist_snapshot(self, artist_id, time_range, ranking_position):

        self.cursor.execute("""
            INSERT INTO top_artists_snapshots (
                spotify_artist_id,
                time_range,
                ranking_position
            )
            VALUES (%s, %s, %s);
        """, (
            artist_id,
            time_range,
            ranking_position
        ))

    def close(self):
       self.connection.commit()
       self.cursor.close()
       self.connection.close()
