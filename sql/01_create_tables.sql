CREATE TABLE IF NOT EXISTS spotify_users (
    id SERIAL PRIMARY KEY,
    spotify_user_id VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    country VARCHAR(10),
    email VARCHAR(255),
    followers INTEGER,
    image_url TEXT,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS artists (
    id SERIAL PRIMARY KEY,
    spotify_artist_id VARCHAR(255) UNIQUE NOT NULL,
    artist_name TEXT NOT NULL,
    genres TEXT,
    popularity INTEGER,
    followers INTEGER,
    image_url TEXT,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS albums (
    id SERIAL PRIMARY KEY,
    spotify_album_id VARCHAR(255) UNIQUE NOT NULL,
    album_name TEXT NOT NULL,
    release_date VARCHAR(50),
    total_tracks INTEGER,
    image_url TEXT,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tracks (
    id SERIAL PRIMARY KEY,
    spotify_track_id VARCHAR(255) UNIQUE NOT NULL,
    track_name TEXT NOT NULL,
    spotify_album_id VARCHAR(255),
    duration_ms INTEGER,
    popularity INTEGER,
    explicit BOOLEAN,
    preview_url TEXT,
    spotify_url TEXT,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tracks_album
        FOREIGN KEY (spotify_album_id)
        REFERENCES albums (spotify_album_id)
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS track_artists (
    id SERIAL PRIMARY KEY,
    spotify_track_id VARCHAR(255) NOT NULL,
    spotify_artist_id VARCHAR(255) NOT NULL,

    CONSTRAINT fk_track_artists_track
        FOREIGN KEY (spotify_track_id)
        REFERENCES tracks (spotify_track_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_track_artists_artist
        FOREIGN KEY (spotify_artist_id)
        REFERENCES artists (spotify_artist_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_track_artist
        UNIQUE (spotify_track_id, spotify_artist_id)
);

CREATE TABLE IF NOT EXISTS recently_played (
    id SERIAL PRIMARY KEY,
    spotify_track_id VARCHAR(255) NOT NULL,
    played_at TIMESTAMP NOT NULL,
    context_type VARCHAR(100),
    context_uri TEXT,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_recently_played_track
        FOREIGN KEY (spotify_track_id)
        REFERENCES tracks (spotify_track_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_recently_played
        UNIQUE (spotify_track_id, played_at)
);

CREATE TABLE IF NOT EXISTS saved_tracks (
    id SERIAL PRIMARY KEY,
    spotify_track_id VARCHAR(255) NOT NULL,
    added_at TIMESTAMP,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_saved_tracks_track
        FOREIGN KEY (spotify_track_id)
        REFERENCES tracks (spotify_track_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_saved_track
        UNIQUE (spotify_track_id)
);

CREATE TABLE IF NOT EXISTS saved_albums (
    id SERIAL PRIMARY KEY,
    spotify_album_id VARCHAR(255) NOT NULL,
    added_at TIMESTAMP,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_saved_albums_album
        FOREIGN KEY (spotify_album_id)
        REFERENCES albums (spotify_album_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_saved_album
        UNIQUE (spotify_album_id)
);

CREATE TABLE IF NOT EXISTS top_tracks_snapshots (
    id SERIAL PRIMARY KEY,
    spotify_track_id VARCHAR(255) NOT NULL,
    time_range VARCHAR(50) NOT NULL,
    ranking_position INTEGER NOT NULL,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_top_tracks_track
        FOREIGN KEY (spotify_track_id)
        REFERENCES tracks (spotify_track_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS top_artists_snapshots (
    id SERIAL PRIMARY KEY,
    spotify_artist_id VARCHAR(255) NOT NULL,
    time_range VARCHAR(50) NOT NULL,
    ranking_position INTEGER NOT NULL,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_top_artists_artist
        FOREIGN KEY (spotify_artist_id)
        REFERENCES artists (spotify_artist_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS track_popularity_snapshots (
    id SERIAL PRIMARY KEY,
    spotify_track_id VARCHAR(255) NOT NULL,
    popularity INTEGER NOT NULL,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_track_popularity_track
        FOREIGN KEY (spotify_track_id)
        REFERENCES tracks (spotify_track_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS artist_popularity_snapshots (
    id SERIAL PRIMARY KEY,
    spotify_artist_id VARCHAR(255) NOT NULL,
    popularity INTEGER NOT NULL,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_artist_popularity_artist
        FOREIGN KEY (spotify_artist_id)
        REFERENCES artists (spotify_artist_id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_recently_played_played_at
ON recently_played (played_at);

CREATE INDEX IF NOT EXISTS idx_recently_played_track
ON recently_played (spotify_track_id);

CREATE INDEX IF NOT EXISTS idx_tracks_album
ON tracks (spotify_album_id);

CREATE INDEX IF NOT EXISTS idx_track_artists_track
ON track_artists (spotify_track_id);

CREATE INDEX IF NOT EXISTS idx_track_artists_artist
ON track_artists (spotify_artist_id);

CREATE INDEX IF NOT EXISTS idx_saved_tracks_added_at
ON saved_tracks (added_at);

CREATE INDEX IF NOT EXISTS idx_saved_albums_added_at
ON saved_albums (added_at);

CREATE INDEX IF NOT EXISTS idx_top_tracks_time_range
ON top_tracks_snapshots (time_range);

CREATE INDEX IF NOT EXISTS idx_top_artists_time_range
ON top_artists_snapshots (time_range);

CREATE INDEX IF NOT EXISTS idx_track_popularity_snapshots_track
ON track_popularity_snapshots (spotify_track_id, collected_at);

CREATE INDEX IF NOT EXISTS idx_artist_popularity_snapshots_artist
ON artist_popularity_snapshots (spotify_artist_id, collected_at);
