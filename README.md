# 🎵 Fatores de Sucesso no Streaming Musical (Spotify, Deezer, Apple Music & Shazam)

![SQL BigQuery](https://img.shields.io/badge/SQL-Google_BigQuery-4285F4?logo=googlebigquery&logoColor=white)
![Python](https://img.shields.io/badge/Python-Statsmodels_%7C_SciPy_%7C_Scikit--Learn-3776AB?logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/BI-Power_BI-F2C811?logo=powerbi&logoColor=black)

> **Resumo Executivo:** Uma gravadora levantou **5 hipóteses de negócio** sobre o que faz uma faixa musical alcançar o topo dos rankings de streaming para orientar o lançamento de um novo artista. Este estudo integrou dados de **948 faixas e 644 artistas** (Spotify, Apple Music, Deezer e Shazam) no Google BigQuery e Python, aplicando testes de normalidade (Shapiro-Wilk), testes não-paramétricos (Mann-Whitney e Kruskal-Wallis), Regressão Linear Simples e Múltipla (OLS com diagnóstico de multicolinearidade VIF) e análise de nicho das **152 faixas "Top Hits" ($\ge 1$ bilhão de streams)**.

🔗 **Links Rápidos:**
- 📓 [Notebook Completo no Google Colab (Testes Estatísticos e Regressões em Python)](https://colab.research.google.com/drive/1quOxk92ReWGKQInZWJTejArk3STQUP76?usp=sharing)
- 📊 [Apresentação Executiva (Google Slides)](https://docs.google.com/presentation/d/1YaAlAVo6Mgmx3_J5_hPPOMxjTDW1e4HEAwfG4YMLL7s/edit?usp=sharing)
- 📄 [Ficha Técnica Completa com Gráficos (PDF)](./reports/FICHA_TECNICA_PROJETO_2_HIPOTESES.pdf)

---

## 1. As 5 Hipóteses de Negócio & Veredito Estatístico

| # | Hipótese Levantada pela Gravadora | Teste / Modelo Aplicado | Resultado Estatístico | Veredito |
| :-: | :--- | :--- | :--- | :---: |
| **H1** | Músicas com **BPM mais alto** fazem mais sucesso em streams no Spotify. | Correlação de Pearson + Shapiro-Wilk + Regressão Linear OLS | $r = -0.0023$ \| $R^2 = 0.000005$ (Coef.: $-46\text{k}$ streams/BPM) | ❌ **Refutada** |
| **H2** | Músicas populares no ranking do **Spotify** têm desempenho semelhante na **Deezer, Apple Music e Shazam**. | Correlação Cross-Plataforma + Regressão Linear Simples | Spotify $\times$ Deezer ($r = 0.60, R^2 = 36\%$) \| Apple ($r = 0.55, R^2 = 30\%$) \| Shazam ($r = 0.61, R^2 = 37\%$) | ⚠️ **Parcialmente Confirmada** |
| **H3** | A presença em um **maior número de playlists** está associada a mais streams. | Correlação + Regressão Linear Simples (`soma_playlists` $\rightarrow$ `streams`) | **$r = 0.78$** \| **$R^2 = 61\%$** (Intercepto: $231\text{M}$; $+49,8\text{k}$ streams por playlist) | ✅ **Confirmada** *(associação, não causalidade)* |
| **H4** | Artistas com **maior número de músicas** no catálogo acumulam mais streams totais. | Agregação por Artista + Regressão Linear (`total_tracks` $\rightarrow$ `total_streams`) | **$r = 0.78$** \| **$R^2 = 61\%$** ($+501\text{M}$ streams por faixa adicional na amostra top) | ✅ **Confirmada** *(com ressalva de viés de seleção)* |
| **H5** | As **características acústicas da música** (`danceability`, `energy`, `valence`, `key`, `mode`, etc.) explicam o volume de streams. | Mann-Whitney (`mode`), Kruskal-Wallis (`key`), Regressão Múltipla OLS + VIF | Mann-Whitney $p = 0.1088$ \| Kruskal-Wallis $p = 0.9195$ \| **OLS Múltipla $R^2 = 2.9\%$** | ❌ **Refutada** |

---

## 2. Engenharia e Limpeza de Dados (SQL / BigQuery)

A base bruta continha anomalias severas de codificação e tipagem em 3 tabelas (`trackinspotifylike`, `trackincompetition`, `tracktechnicalinfo`):
- **Remoção de Duplicatas de Catálogo:** Identificação via `CTE` + `GROUP BY track_name, artist_s__name HAVING COUNT(*) > 1` (ex: duplicidade em *"About Damn Time"* da Lizzo e faixas com metadados conflitantes), consolidando **948 faixas únicas** de **644 artistas** (887 solos e 67 colaborações).
- **Auditoria e Sanitização com Expressões Regulares (`REGEXP_CONTAINS` e `REGEXP_REPLACE`):**
  - Detecção de strings corrompidas concatenadas dentro da coluna numérica `streams` (`r'[^0-9 ]'`), como `'BPM110KeyAModeMajor...'`.
  - Limpeza de caracteres de substituição Unicode (``) em nomes de faixas e artistas.
  - Conversão segura de tipos (`SAFE_CAST(streams AS INT64)`), construção de datas (`DATE(released_year, released_month, released_day)`) e segmentação em quartis via `NTILE(4)`.

---

## 3. Análise de Nicho: Anatomia dos "Top Hits" ($\ge 1$ Bilhão de Streams)

Embora atributos acústicos isolados não expliquem linearmente o volume global de streams ($R^2 = 2.9\%$), o recorte das **152 faixas que ultrapassaram 1 bilhão de reproduções** (113 artistas) revelou um perfil estético claro — batizado de **Mid-Upbeat**:

- **BPM Moderado:** Concentração entre **100 e 120 BPM** (maximizando apelo global sem extremos de lentidão ou aceleração).
- **Energia e Dançabilidade Equilibradas:** `energy` concentrada entre **60–80%** e `danceability` entre **55–70%**.
- **Foco Total em Estúdio e Vocais Cantados:** `instrumentalness` próximo de **0%**, `speechiness` baixo (**1–10%**) e `liveness` baixo (**5–15%**).
- **Tonalidade Luminosa:** **63% dos hits bilionários estão em modo Major** (contra 37% em Minor), com destaque para as tonalidades **C# (14%)**, **G# (11%)** e **B (9%)**.

---

## 4. Estrutura do Repositório

```text
music-streaming-success-factors/
├── README.md                                        # Documentação executiva e síntese das 5 hipóteses
├── sql/
│   ├── 01_data_cleaning_regex.sql                   # Deduplicação e limpeza com REGEXP no BigQuery
│   └── 02_unified_dataset_and_correlations.sql      # Tabela unificada, quartis, correlações e recorte Top Hits
├── src/
│   └── statistical_hypothesis_tests.py              # Shapiro-Wilk, OLS Simples/Múltipla, VIF, Mann-Whitney e Kruskal-Wallis
└── reports/
    └── FICHA_TECNICA_PROJETO_2_HIPOTESES.pdf        # Relatório completo com gráficos e saídas estatísticas
```
