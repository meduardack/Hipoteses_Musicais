-- =============================================================================
-- PROJETO: Fatores de Sucesso no Mercado Musical (Spotify, Deezer, Apple & Shazam)
-- ETAPA 02: Camada Unificada, Quartis, Correlações e Recorte Top Hits (BigQuery)
-- EQUIPE: Maria Eduarda Carvalho de Castro & Wellen Mariah Lisboa
-- =============================================================================

-- 1. Construção da Tabela Analítica Unificada (948 faixas, 644 artistas)
WITH tracks_charts_sp AS (
    SELECT artist_s__name, COUNT(*) AS total_tracks_charts_artist_sp
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
    WHERE in_spotify_charts > 0
    GROUP BY artist_s__name
),
tracks_charts_ap AS (
    SELECT artist_s__name, COUNT(*) AS total_track_charts_artist_ap
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
    WHERE in_apple_charts > 0
    GROUP BY artist_s__name
),
tracks_charts_dz AS (
    SELECT artist_s__name, COUNT(*) AS total_tracks_charts_artist_dz
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
    WHERE in_deezer_charts > 0
    GROUP BY artist_s__name
),
tracks_charts_sz AS (
    SELECT artist_s__name, COUNT(*) AS total_tracks_charts_artist_sz
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
    WHERE in_shazam_charts > 0
    GROUP BY artist_s__name
),
soma_playlists AS (
    SELECT
        track_id,
        (in_spotify_playlists + in_apple_playlists + in_deezer_playlists) AS soma_playlists
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
),
media_playlists AS (
    SELECT
        track_id,
        CAST(ROUND((in_spotify_playlists + in_apple_playlists + in_deezer_playlists) / 3) AS INT64) AS media_playlists
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
),
media_charts AS (
    SELECT
        track_id,
        CAST(ROUND(SAFE_DIVIDE(in_spotify_charts + in_apple_charts + in_deezer_charts + IFNULL(in_shazam_charts, 0), 4)) AS INT64) AS media_charts
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
),
quartil_streams AS (
    SELECT
        track_id,
        CAST(streams AS INT64) AS streams,
        NTILE(4) OVER (ORDER BY CAST(streams AS INT64)) AS quartil_streams
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
    WHERE SAFE_CAST(streams AS INT64) IS NOT NULL
)
SELECT
    s.track_id,
    s.track_name,
    s.artist_s__name,
    s.artist_count,
    s.data_lacamento,
    s.in_spotify_charts,
    s.in_spotify_playlists,
    c.in_apple_charts,
    c.in_apple_playlists,
    c.in_deezer_charts,
    c.in_deezer_playlists,
    c.in_shazam_charts,
    CAST(s.streams AS INT64) AS streams,
    qs.quartil_streams,
    CASE
        WHEN qs.quartil_streams = 4 THEN 'Alto'
        WHEN qs.quartil_streams = 3 THEN 'Médio'
        WHEN qs.quartil_streams = 2 THEN 'Baixo'
        WHEN qs.quartil_streams = 1 THEN 'Muito baixo'
    END AS classificacao_streams,
    IFNULL(sp.total_tracks_charts_artist_sp, 0) AS total_tracks_charts_artist_sp,
    IFNULL(ap.total_track_charts_artist_ap, 0) AS total_track_charts_artist_ap,
    IFNULL(dz.total_tracks_charts_artist_dz, 0) AS total_tracks_charts_artist_dz,
    IFNULL(sz.total_tracks_charts_artist_sz, 0) AS total_tracks_charts_artist_sz,
    pl.soma_playlists,
    ROUND(mp.media_playlists, 2) AS media_playlists,
    m.media_charts,
    i.bpm,
    i.key,
    i.mode,
    i.`danceability_%`,
    i.`valence_%`,
    i.`energy_%`,
    i.`acousticness_%`,
    i.`instrumentalness_%`,
    i.`liveness_%`,
    i.`speechiness_%`
FROM `projeto2lab.projetohipoteses_lab2.trackinspotifylike_limpa` AS s
JOIN `projeto2lab.projetohipoteses_lab2.trackincompetition_limpo` AS c ON s.track_id = c.track_id
JOIN `projeto2lab.projetohipoteses_lab2.tracktechnicalinfo_limpo` AS i ON s.track_id = i.track_id
LEFT JOIN tracks_charts_sp AS sp ON s.artist_s__name = sp.artist_s__name
LEFT JOIN tracks_charts_ap AS ap ON s.artist_s__name = ap.artist_s__name
LEFT JOIN tracks_charts_dz AS dz ON s.artist_s__name = dz.artist_s__name
LEFT JOIN tracks_charts_sz AS sz ON s.artist_s__name = sz.artist_s__name
LEFT JOIN soma_playlists AS pl ON s.track_id = pl.track_id
LEFT JOIN media_playlists AS mp ON s.track_id = mp.track_id
LEFT JOIN media_charts AS m ON s.track_id = m.track_id
LEFT JOIN quartil_streams AS qs ON s.track_id = qs.track_id;

-- 2. Cálculo de Correlações para as Hipóteses 1, 2, 3, 4 e 5
WITH correlacao_bpm AS (
    SELECT CORR(bpm, streams) AS correlacao_bpm
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
),
correlacao_playlists_streams AS (
    SELECT CORR(soma_playlists, streams) AS correlacao_playlists_streams
    FROM `projeto2lab.projetohipoteses_lab2.tabela_completa_limpa`
),
correlacao_streams_tracks AS (
    SELECT CORR(total_tracks, total_streams) AS correlacao_streams_tracks_sp
    FROM `projeto2lab.projetohipoteses_lab2.artists_streams_spotify`
)
SELECT
    cb.correlacao_bpm,
    cps.correlacao_playlists_streams,
    cst.correlacao_streams_tracks_sp
FROM correlacao_bpm AS cb
CROSS JOIN correlacao_playlists_streams AS cps
CROSS JOIN correlacao_streams_tracks AS cst;

-- 3. Isolamento do Nicho "Top Hits" (>= 1 Bilhão de Streams -> 152 faixas)
SELECT *
FROM `projeto2lab-457400.projetohipoteses_rv02.limpos_agrupados`
WHERE streams >= 1000000000;
