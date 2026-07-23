DROP VIEW IF EXISTS
    vw_api_artist_growth,
    vw_api_latest_top_artists,
    vw_api_latest_top_tracks,
    vw_api_library_top_artists,
    vw_api_saved_tracks,
    vw_api_top_albums,
    vw_api_top_artists,
    vw_api_plays_by_hour,
    vw_api_plays_by_day,
    vw_api_monthly_evolution,
    vw_api_overview_stats,
    vw_repeated_tracks_trend,
    vw_artist_growth,
    vw_artist_monthly_plays,
    vw_monthly_evolution,
    vw_top_artists_history,
    vw_top_tracks_history,
    vw_latest_top_artists,
    vw_latest_top_tracks,
    vw_library_top_artists,
    vw_saved_albums,
    vw_saved_albums_by_month,
    vw_saved_tracks_by_month,
    vw_saved_tracks,
    vw_top_albums_by_plays,
    vw_top_artists_by_plays,
    vw_top_tracks_by_plays,
    vw_plays_by_weekday_hour,
    vw_plays_by_hour,
    vw_plays_by_day,
    vw_recently_played_details,
    vw_user_profile,
    vw_overview_stats
CASCADE;

CREATE OR REPLACE VIEW vw_overview_stats AS
SELECT
    (SELECT COUNT(*) FROM recently_played) AS music_plays,
    (SELECT COUNT(*) FROM saved_tracks) AS saved_tracks,
    (SELECT COUNT(*) FROM saved_albums) AS saved_albums,
    (
        SELECT COUNT(DISTINCT rp.spotify_track_id)
        FROM recently_played rp
    ) AS unique_tracks_played,
    (
        SELECT COUNT(DISTINCT ta.spotify_artist_id)
        FROM recently_played rp
        JOIN track_artists ta
            ON ta.spotify_track_id = rp.spotify_track_id
    ) AS unique_artists_played,
    (
        SELECT ROUND(AVG(t.popularity), 2)
        FROM recently_played rp
        JOIN tracks t
            ON t.spotify_track_id = rp.spotify_track_id
        WHERE t.popularity IS NOT NULL
    ) AS avg_track_popularity;

CREATE OR REPLACE VIEW vw_user_profile AS
SELECT
    spotify_user_id,
    display_name,
    country,
    email,
    followers,
    image_url,
    collected_at
FROM spotify_users
ORDER BY collected_at DESC
LIMIT 1;

CREATE OR REPLACE VIEW vw_recently_played_details AS
SELECT
    rp.id AS recently_played_id,
    rp.played_at,
    t.spotify_track_id,
    t.track_name,
    al.spotify_album_id,
    al.album_name,
    STRING_AGG(DISTINCT ar.artist_name, ', ' ORDER BY ar.artist_name) AS artist_names,
    t.duration_ms,
    t.explicit,
    t.spotify_url
FROM recently_played rp
JOIN tracks t
    ON t.spotify_track_id = rp.spotify_track_id
LEFT JOIN albums al
    ON al.spotify_album_id = t.spotify_album_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = t.spotify_track_id
LEFT JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    rp.id,
    rp.played_at,
    t.spotify_track_id,
    t.track_name,
    al.spotify_album_id,
    al.album_name,
    t.duration_ms,
    t.explicit,
    t.spotify_url
ORDER BY rp.played_at DESC;

CREATE OR REPLACE VIEW vw_plays_by_day AS
SELECT
    played_at::date AS play_date,
    COUNT(*) AS play_count
FROM recently_played
GROUP BY played_at::date
ORDER BY play_date;

CREATE OR REPLACE VIEW vw_plays_by_hour AS
SELECT
    EXTRACT(HOUR FROM played_at)::integer AS play_hour,
    COUNT(*) AS play_count
FROM recently_played
GROUP BY EXTRACT(HOUR FROM played_at)
ORDER BY play_hour;

CREATE OR REPLACE VIEW vw_plays_by_weekday_hour AS
SELECT
    EXTRACT(DOW FROM played_at)::integer AS weekday_number,
    TO_CHAR(played_at, 'Day') AS weekday_name,
    EXTRACT(HOUR FROM played_at)::integer AS play_hour,
    COUNT(*) AS play_count
FROM recently_played
GROUP BY
    EXTRACT(DOW FROM played_at),
    TO_CHAR(played_at, 'Day'),
    EXTRACT(HOUR FROM played_at)
ORDER BY weekday_number, play_hour;

CREATE OR REPLACE VIEW vw_top_tracks_by_plays AS
SELECT
    t.spotify_track_id,
    t.track_name,
    al.album_name,
    STRING_AGG(DISTINCT ar.artist_name, ', ' ORDER BY ar.artist_name) AS artist_names,
    COUNT(rp.id) AS play_count,
    t.duration_ms,
    t.explicit,
    t.spotify_url
FROM recently_played rp
JOIN tracks t
    ON t.spotify_track_id = rp.spotify_track_id
LEFT JOIN albums al
    ON al.spotify_album_id = t.spotify_album_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = t.spotify_track_id
LEFT JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    t.spotify_track_id,
    t.track_name,
    al.album_name,
    t.duration_ms,
    t.explicit,
    t.spotify_url
ORDER BY play_count DESC, t.track_name;

CREATE OR REPLACE VIEW vw_top_artists_by_plays AS
SELECT
    ar.spotify_artist_id,
    ar.artist_name,
    COUNT(rp.id) AS play_count,
    ar.image_url
FROM recently_played rp
JOIN track_artists ta
    ON ta.spotify_track_id = rp.spotify_track_id
JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    ar.spotify_artist_id,
    ar.artist_name,
    ar.image_url
ORDER BY play_count DESC, ar.artist_name;

CREATE OR REPLACE VIEW vw_top_albums_by_plays AS
SELECT
    al.spotify_album_id,
    al.album_name,
    STRING_AGG(DISTINCT ar.artist_name, ', ' ORDER BY ar.artist_name) AS artist_names,
    COUNT(rp.id) AS play_count,
    al.release_date,
    al.total_tracks,
    al.image_url
FROM recently_played rp
JOIN tracks t
    ON t.spotify_track_id = rp.spotify_track_id
JOIN albums al
    ON al.spotify_album_id = t.spotify_album_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = t.spotify_track_id
LEFT JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    al.spotify_album_id,
    al.album_name,
    al.release_date,
    al.total_tracks,
    al.image_url
ORDER BY play_count DESC, al.album_name;

CREATE OR REPLACE VIEW vw_saved_tracks AS
SELECT
    st.id AS saved_track_id,
    st.added_at,
    t.spotify_track_id,
    t.track_name,
    al.spotify_album_id,
    al.album_name,
    STRING_AGG(DISTINCT ar.artist_name, ', ' ORDER BY ar.artist_name) AS artist_names,
    t.duration_ms,
    t.explicit,
    t.preview_url,
    t.spotify_url
FROM saved_tracks st
JOIN tracks t
    ON t.spotify_track_id = st.spotify_track_id
LEFT JOIN albums al
    ON al.spotify_album_id = t.spotify_album_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = t.spotify_track_id
LEFT JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    st.id,
    st.added_at,
    t.spotify_track_id,
    t.track_name,
    al.spotify_album_id,
    al.album_name,
    t.duration_ms,
    t.explicit,
    t.preview_url,
    t.spotify_url
ORDER BY st.added_at DESC NULLS LAST, t.track_name;

CREATE OR REPLACE VIEW vw_saved_tracks_by_month AS
SELECT
    DATE_TRUNC('month', added_at)::date AS saved_month,
    COUNT(*) AS saved_count
FROM saved_tracks
WHERE added_at IS NOT NULL
GROUP BY DATE_TRUNC('month', added_at)
ORDER BY saved_month;

CREATE OR REPLACE VIEW vw_saved_albums_by_month AS
SELECT
    DATE_TRUNC('month', added_at)::date AS saved_month,
    COUNT(*) AS saved_count
FROM saved_albums
WHERE added_at IS NOT NULL
GROUP BY DATE_TRUNC('month', added_at)
ORDER BY saved_month;

CREATE OR REPLACE VIEW vw_saved_albums AS
SELECT
    sa.id AS saved_album_id,
    sa.added_at,
    al.spotify_album_id,
    al.album_name,
    al.release_date,
    al.total_tracks,
    al.image_url
FROM saved_albums sa
JOIN albums al
    ON al.spotify_album_id = sa.spotify_album_id
ORDER BY sa.added_at DESC NULLS LAST, al.album_name;

CREATE OR REPLACE VIEW vw_library_top_artists AS
SELECT
    ar.spotify_artist_id,
    ar.artist_name,
    COUNT(DISTINCT st.spotify_track_id) AS saved_track_count,
    ar.image_url
FROM saved_tracks st
JOIN track_artists ta
    ON ta.spotify_track_id = st.spotify_track_id
JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    ar.spotify_artist_id,
    ar.artist_name,
    ar.image_url
ORDER BY saved_track_count DESC, ar.artist_name;


CREATE OR REPLACE VIEW vw_latest_top_tracks AS
WITH latest_snapshots AS (
    SELECT
        time_range,
        MAX(collected_at) AS latest_collected_at
    FROM top_tracks_snapshots
    GROUP BY time_range
)
SELECT
    tts.time_range,
    tts.ranking_position,
    tts.collected_at,
    tr.spotify_track_id,
    tr.track_name,
    al.album_name,
    STRING_AGG(DISTINCT ar.artist_name, ', ' ORDER BY ar.artist_name) AS artist_names,
    tr.duration_ms,
    tr.explicit,
    tr.spotify_url
FROM top_tracks_snapshots tts
JOIN latest_snapshots ls
    ON ls.time_range = tts.time_range
    AND ls.latest_collected_at = tts.collected_at
JOIN tracks tr
    ON tr.spotify_track_id = tts.spotify_track_id
LEFT JOIN albums al
    ON al.spotify_album_id = tr.spotify_album_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = tr.spotify_track_id
LEFT JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    tts.time_range,
    tts.ranking_position,
    tts.collected_at,
    tr.spotify_track_id,
    tr.track_name,
    al.album_name,
    tr.duration_ms,
    tr.explicit,
    tr.spotify_url
ORDER BY tts.time_range, tts.ranking_position;

CREATE OR REPLACE VIEW vw_latest_top_artists AS
WITH latest_snapshots AS (
    SELECT
        time_range,
        MAX(collected_at) AS latest_collected_at
    FROM top_artists_snapshots
    GROUP BY time_range
)
SELECT
    tas.time_range,
    tas.ranking_position,
    tas.collected_at,
    ar.spotify_artist_id,
    ar.artist_name,
    ar.image_url
FROM top_artists_snapshots tas
JOIN latest_snapshots ls
    ON ls.time_range = tas.time_range
    AND ls.latest_collected_at = tas.collected_at
JOIN artists ar
    ON ar.spotify_artist_id = tas.spotify_artist_id
ORDER BY tas.time_range, tas.ranking_position;

CREATE OR REPLACE VIEW vw_top_tracks_history AS
SELECT
    tts.time_range,
    tts.ranking_position,
    tts.collected_at,
    tr.spotify_track_id,
    tr.track_name,
    STRING_AGG(DISTINCT ar.artist_name, ', ' ORDER BY ar.artist_name) AS artist_names
FROM top_tracks_snapshots tts
JOIN tracks tr
    ON tr.spotify_track_id = tts.spotify_track_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = tr.spotify_track_id
LEFT JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    tts.time_range,
    tts.ranking_position,
    tts.collected_at,
    tr.spotify_track_id,
    tr.track_name
ORDER BY tts.collected_at DESC, tts.time_range, tts.ranking_position;

CREATE OR REPLACE VIEW vw_top_artists_history AS
SELECT
    tas.time_range,
    tas.ranking_position,
    tas.collected_at,
    ar.spotify_artist_id,
    ar.artist_name,
    ar.image_url
FROM top_artists_snapshots tas
JOIN artists ar
    ON ar.spotify_artist_id = tas.spotify_artist_id
ORDER BY tas.collected_at DESC, tas.time_range, tas.ranking_position;

CREATE OR REPLACE VIEW vw_monthly_evolution AS
SELECT
    DATE_TRUNC('month', rp.played_at)::date AS play_month,
    COUNT(*) AS play_count,
    COUNT(DISTINCT rp.spotify_track_id) AS unique_track_count,
    COUNT(DISTINCT ta.spotify_artist_id) AS unique_artist_count,
    COUNT(DISTINCT tr.spotify_album_id) AS unique_album_count,
    ROUND(AVG(tr.popularity), 2) AS avg_track_popularity
FROM recently_played rp
JOIN tracks tr
    ON tr.spotify_track_id = rp.spotify_track_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = rp.spotify_track_id
GROUP BY DATE_TRUNC('month', rp.played_at)
ORDER BY play_month;

CREATE OR REPLACE VIEW vw_artist_monthly_plays AS
SELECT
    DATE_TRUNC('month', rp.played_at)::date AS play_month,
    ar.spotify_artist_id,
    ar.artist_name,
    COUNT(*) AS play_count,
    ar.image_url
FROM recently_played rp
JOIN track_artists ta
    ON ta.spotify_track_id = rp.spotify_track_id
JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    DATE_TRUNC('month', rp.played_at),
    ar.spotify_artist_id,
    ar.artist_name,
    ar.image_url
ORDER BY play_month DESC, play_count DESC, ar.artist_name;

CREATE OR REPLACE VIEW vw_artist_growth AS
WITH artist_monthly AS (
    SELECT
        DATE_TRUNC('month', rp.played_at)::date AS play_month,
        ar.spotify_artist_id,
        ar.artist_name,
        ar.image_url,
        COUNT(*) AS play_count
    FROM recently_played rp
    JOIN track_artists ta
        ON ta.spotify_track_id = rp.spotify_track_id
    JOIN artists ar
        ON ar.spotify_artist_id = ta.spotify_artist_id
    GROUP BY
        DATE_TRUNC('month', rp.played_at),
        ar.spotify_artist_id,
        ar.artist_name,
        ar.image_url
),
artist_growth AS (
    SELECT
        play_month,
        spotify_artist_id,
        artist_name,
        image_url,
        play_count,
        LAG(play_count) OVER ( -- pega o valor de play_count da linha anterior para o mesmo artista
            PARTITION BY spotify_artist_id
            ORDER BY play_month
        ) AS previous_month_play_count
    FROM artist_monthly
)
SELECT
    play_month,
    spotify_artist_id,
    artist_name,
    image_url,
    play_count,
    COALESCE(previous_month_play_count, 0) AS previous_month_play_count,
    play_count - COALESCE(previous_month_play_count, 0) AS growth_count
FROM artist_growth
ORDER BY play_month DESC, growth_count DESC, play_count DESC, artist_name;

CREATE OR REPLACE VIEW vw_repeated_tracks_trend AS
SELECT
    DATE_TRUNC('month', rp.played_at)::date AS play_month,
    tr.spotify_track_id,
    tr.track_name,
    STRING_AGG(DISTINCT ar.artist_name, ', ' ORDER BY ar.artist_name) AS artist_names,
    COUNT(*) AS play_count
FROM recently_played rp
JOIN tracks tr
    ON tr.spotify_track_id = rp.spotify_track_id
LEFT JOIN track_artists ta
    ON ta.spotify_track_id = tr.spotify_track_id
LEFT JOIN artists ar
    ON ar.spotify_artist_id = ta.spotify_artist_id
GROUP BY
    DATE_TRUNC('month', rp.played_at),
    tr.spotify_track_id,
    tr.track_name
ORDER BY play_month DESC, play_count DESC, tr.track_name;

CREATE OR REPLACE VIEW vw_api_overview_stats AS
SELECT *
FROM vw_overview_stats;

CREATE OR REPLACE VIEW vw_api_monthly_evolution AS
SELECT
    TO_CHAR(play_month, 'Mon') AS label,
    play_count AS plays,
    unique_track_count,
    unique_artist_count,
    unique_album_count,
    avg_track_popularity
FROM vw_monthly_evolution
ORDER BY play_month;

CREATE OR REPLACE VIEW vw_api_plays_by_day AS
SELECT
    TO_CHAR(play_date, 'DD/MM') AS label,
    play_count AS plays
FROM vw_plays_by_day
ORDER BY play_date;

CREATE OR REPLACE VIEW vw_api_plays_by_hour AS
SELECT
    ARRAY_AGG(COALESCE(vph.play_count, 0) ORDER BY hours.play_hour) AS plays_by_hour
FROM GENERATE_SERIES(0, 23) AS hours(play_hour)
LEFT JOIN vw_plays_by_hour vph
    ON vph.play_hour = hours.play_hour;

CREATE OR REPLACE VIEW vw_api_top_artists AS
SELECT
    artist_name AS name,
    play_count AS value,
    'plays' AS meta
FROM vw_top_artists_by_plays
LIMIT 10;

CREATE OR REPLACE VIEW vw_api_top_albums AS
SELECT
    album_name AS name,
    play_count AS value,
    artist_names AS meta
FROM vw_top_albums_by_plays
LIMIT 10;

CREATE OR REPLACE VIEW vw_api_saved_tracks AS
SELECT
    track_name AS track,
    artist_names AS artist,
    album_name AS album,
    NULL::integer AS popularity,
    added_at
FROM vw_saved_tracks
LIMIT 50;

CREATE OR REPLACE VIEW vw_api_library_top_artists AS
SELECT
    artist_name AS name,
    saved_track_count AS value,
    'musicas curtidas' AS meta
FROM vw_library_top_artists
LIMIT 10;

CREATE OR REPLACE VIEW vw_api_latest_top_tracks AS
SELECT
    time_range,
    track_name AS name,
    ranking_position AS value,
    artist_names AS meta
FROM vw_latest_top_tracks
ORDER BY time_range, ranking_position;

CREATE OR REPLACE VIEW vw_api_latest_top_artists AS
SELECT
    time_range,
    artist_name AS name,
    ranking_position AS value,
    '' AS meta
FROM vw_latest_top_artists
ORDER BY time_range, ranking_position;

CREATE OR REPLACE VIEW vw_api_artist_growth AS
SELECT
    artist_name AS name,
    growth_count AS value,
    play_count || ' plays no mes' AS meta
FROM vw_artist_growth
LIMIT 10;
