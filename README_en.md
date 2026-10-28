# 🎵 Success Factors in Music Streaming (Spotify, Deezer, Apple Music & Shazam)

> 🌐 **Language / Idioma:** **English** • [Português](README.md)

![SQL BigQuery](https://img.shields.io/badge/SQL-Google_BigQuery-4285F4?logo=googlebigquery&logoColor=white)
![Python](https://img.shields.io/badge/Python-Statsmodels_%7C_SciPy_%7C_Scikit--Learn-3776AB?logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/BI-Power_BI-F2C811?logo=powerbi&logoColor=black)

> **Executive Summary:** A record label formulated **5 strategic business hypotheses** regarding the attributes that drive musical tracks to top streaming charts, aiming to inform the launch strategy for a newly signed artist. This project integrated and harmonized multi-platform datasets covering **948 unique tracks and 644 artists** across Spotify, Apple Music, Deezer, and Shazam using Google BigQuery and Python. Analytical methodologies included normality testing (Shapiro-Wilk), non-parametric hypothesis tests (Mann-Whitney U and Kruskal-Wallis), Simple and Multiple Linear Regression (OLS with Variance Inflation Factor / VIF diagnostics), and an in-depth aesthetic analysis of **152 "Top Hits" ($\ge 1$ billion streams)**.

🔗 **Quick Links:**
- 📓 [Complete Project Documentation on Notion](https://app.notion.com/p/FICHA-T-CNICA_-PROJETO-2-HIP-TESES-200b5d322028808ba872c03248cce5ac?source=copy_link)
- 📓 [Interactive Python Notebook on Google Colab (Statistical Tests & Regressions)](https://colab.research.google.com/drive/1quOxk92ReWGKQInZWJTejArk3STQUP76?usp=sharing)
- 📊 [Executive Slide Deck (Google Slides)](https://docs.google.com/presentation/d/1YaAlAVo6Mgmx3_J5_hPPOMxjTDW1e4HEAwfG4YMLL7s/edit?usp=sharing)

---

## 1. Core Business Hypotheses & Statistical Verdicts

| # | Business Hypothesis | Statistical Test / Applied Model | Quantitative Results | Verdict |
| :-: | :--- | :--- | :--- | :---: |
| **H1** | Songs with **higher BPM** achieve more streams on Spotify. | Pearson Correlation + Shapiro-Wilk + Simple OLS Regression | $r = -0.0023$ \| $R^2 = 0.000005$ (Coef.: $-46\text{k}$ streams/BPM) | ❌ **Refuted** |
| **H2** | Popular tracks on **Spotify** exhibit consistent performance across **Deezer, Apple Music, and Shazam**. | Cross-Platform Correlation + Simple Linear Regression | Spotify $\times$ Deezer ($r = 0.60, R^2 = 36\%$) \| Apple ($r = 0.55, R^2 = 30\%$) \| Shazam ($r = 0.61, R^2 = 37\%$) | ⚠️ **Partially Confirmed** |
| **H3** | Placement in a **higher number of playlists** correlates with higher total stream counts. | Pearson Correlation + Simple OLS (`total_playlists` $\rightarrow$ `streams`) | **$r = 0.78$** \| **$R^2 = 61\%$** (Intercept: $231\text{M}$; $+49.8\text{k}$ streams per playlist) | ✅ **Confirmed** *(Association, not direct causality)* |
| **H4** | Artists with **larger active catalogs** accumulate higher aggregate streams. | Artist Aggregation + Linear Regression (`total_tracks` $\rightarrow$ `total_streams`) | **$r = 0.78$** \| **$R^2 = 61\%$** ($+501\text{M}$ streams per additional top catalog track) | ✅ **Confirmed** *(Subject to survivor/selection bias)* |
| **H5** | **Acoustic audio features** (`danceability`, `energy`, `valence`, `key`, `mode`, etc.) explain total stream volume. | Mann-Whitney U (`mode`), Kruskal-Wallis (`key`), Multiple OLS Regression + VIF | Mann-Whitney $p = 0.1088$ \| Kruskal-Wallis $p = 0.9195$ \| **Multiple OLS $R^2 = 2.9\%$** | ❌ **Refuted** |

---

## 2. Data Engineering & Cleansing (SQL / Google BigQuery)

The raw transactional tables contained significant formatting, encoding, and data-type inconsistencies across three relational tables (`trackinspotifylike`, `trackincompetition`, `tracktechnicalinfo`):
- **Catalog Deduplication:** Identified duplicate releases using `CTEs` and `GROUP BY track_name, artist_s__name HAVING COUNT(*) > 1` (e.g., duplicate entries for Lizzo's *"About Damn Time"* with divergent timestamps), isolating **948 unique tracks** from **644 artists** (887 solo acts and 67 collaborative releases).
- **Sanitization via Regular Expressions (`REGEXP_CONTAINS` and `REGEXP_REPLACE`):**
  - Removed corrupted string concatenations embedded in numeric stream columns (`r'[^0-9 ]'`), such as `'BPM110KeyAModeMajor...'`.
  - Filtered broken Unicode replacement symbols (``) across track and artist name strings.
  - Applied robust type conversions (`SAFE_CAST(streams AS INT64)`), generated standard calendar dates (`DATE(released_year, released_month, released_day)`), and segmented stream volumes into analytical quartiles via `NTILE(4)`.

---

## 3. Niche Analysis: Anatomy of "Top Hits" ($\ge 1$ Billion Streams)

Although individual acoustic attributes do not linearly predict streaming volume across the broad catalog ($R^2 = 2.9\%$), isolating the **152 tracks that exceeded 1 billion streams** (113 unique artists) revealed a distinct, globally consistent aesthetic profile—characterized as **Mid-Upbeat**:

- **Moderate Tempo:** Concentrated between **100 and 120 BPM** (maximizing global danceability and radio-friendly pacing without extreme tempos).
- **Balanced Energy & Danceability:** `energy` index concentrated between **60–80%** and `danceability` between **55–70%**.
- **Vocal & Studio Dominance:** `instrumentalness` near **0%**, low `speechiness` (**1–10%**), and low `liveness` (**5–15%**), confirming studio production dominance.
- **Tonal Preference:** **63% of billion-stream hits are composed in Major mode** (versus 37% Minor), with strong modal clustering in **C# (14%)**, **G# (11%)**, and **B (9%)**.

---

## 4. Repository Structure

```text
music-streaming-success-factors/
├── README.md                                        # Executive Documentation (Português)
├── README_en.md                                     # Executive Documentation (English)
├── sql/
│   ├── 01_data_cleaning_regex.sql                   # Deduplication and BigQuery REGEXP cleaning
│   └── 02_unified_dataset_and_correlations.sql      # Unified analytical table, quartiles & Top Hits slice
└── src/
    └── statistical_hypothesis_tests.py              # Shapiro-Wilk, Simple/Multiple OLS, VIF, Mann-Whitney & Kruskal-Wallis
```
