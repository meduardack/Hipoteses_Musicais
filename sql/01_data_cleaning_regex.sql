-- =============================================================================
-- PROJETO: Fatores de Sucesso no Mercado Musical (Spotify, Deezer, Apple & Shazam)
-- ETAPA 01: Auditoria de Qualidade, Deduplicação e Limpeza com Regex (BigQuery)
-- EQUIPE: Maria Eduarda Carvalho de Castro & Wellen Mariah Lisboa
-- =============================================================================

-- 1. Verificação de valores nulos
SELECT COUNT(*) AS nulos_track_id
FROM `projeto2lab-457400.projetohipoteses_lab2.tracktechnicalinfo`
WHERE track_id IS NULL;

SELECT COUNT(*) AS nulos_key
FROM `projeto2lab.projetohipoteses_lab2.tracktechnicalinfo`
WHERE key IS NULL;

-- 2. Detecção e investigação de duplicatas por nome da música e artista
WITH duplicados AS (
    SELECT
        track_name,
        artist_s__name
    FROM `projeto2lab.projetohipoteses_lab2.trackinspotifylike`
    GROUP BY track_name, artist_s__name
    HAVING COUNT(*) > 1
)
SELECT t.*
FROM `projeto2lab.projetohipoteses_lab2.trackinspotifylike` t
JOIN duplicados d
    ON t.track_name = d.track_name
   AND t.artist_s__name = d.artist_s__name;

-- 3. Auditoria de caracteres não-numéricos e corrupção de tipos com REGEXP_CONTAINS
SELECT in_spotify_charts
FROM `projeto2lab.projetohipoteses_lab2.trackinspotifylike`
WHERE REGEXP_CONTAINS(CAST(in_spotify_charts AS STRING), r'[^0-9 ]');

SELECT *
FROM `projeto2lab.projetohipoteses_lab2.trackincompetition`
WHERE REGEXP_CONTAINS(CAST(track_id AS STRING), r'[^0-9]');

-- 4. Consolidação das Views Limpas (removendo duplicatas e registro corrompido)
CREATE OR REPLACE VIEW `projeto2lab.projetohipoteses_lab2.trackinspotifylike_limpa` AS
WITH base_convertida AS (
    SELECT
        *,
        DATE(released_year, released_month, released_day) AS data_lacamento
    FROM `projeto2lab.projetohipoteses_lab2.trackinspotifylike`
)
SELECT
    REGEXP_REPLACE(track_id, r'0:00', '0000000') AS track_id,
    REGEXP_REPLACE(track_name, r'', ' ') AS track_name,
    REGEXP_REPLACE(artist_s__name, r'', ' ') AS artist_s__name,
    artist_count,
    in_spotify_playlists,
    in_spotify_charts,
    data_lacamento,
    streams
FROM base_convertida
WHERE track_id NOT IN ('5080031', '3814670', '1119309', '8173823', '4061483');

CREATE OR REPLACE VIEW `projeto2lab.projetohipoteses_lab2.trackincompetition_limpo` AS
SELECT
    REGEXP_REPLACE(track_id, r'0:00', '0000000') AS track_id,
    in_apple_playlists,
    in_apple_charts,
    in_deezer_playlists,
    in_deezer_charts,
    in_shazam_charts
FROM `projeto2lab.projetohipoteses_lab2.trackincompetition`
WHERE track_id NOT IN ('5080031', '3814670', '1119309', '8173823', '4061483');

CREATE OR REPLACE VIEW `projeto2lab.projetohipoteses_lab2.tracktechnicalinfo_limpo` AS
SELECT
    REGEXP_REPLACE(track_id, r'0:00', '0000000') AS track_id,
    bpm,
    IFNULL(key, 'Não Informado') AS key,
    mode,
    `danceability_%`,
    `valence_%`,
    `energy_%`,
    `acousticness_%`,
    `instrumentalness_%`,
    `liveness_%`,
    `speechiness_%`
FROM `projeto2lab.projetohipoteses_lab2.tracktechnicalinfo`
WHERE track_id NOT IN ('5080031', '3814670', '1119309', '8173823', '4061483');
