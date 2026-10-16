"""
Testes de Hipóteses Estatísticas e Modelagem de Regressão — Mercado Musical
Autoras: Maria Eduarda Carvalho de Castro & Wellen Mariah Lisboa
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm
from scipy import stats
from scipy.stats import kruskal, mannwhitneyu, shapiro
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from statsmodels.stats.outliers_influence import variance_inflation_factor


def testar_normalidade_shapiro(df: pd.DataFrame, colunas: list[str]) -> dict[str, tuple[float, float]]:
    """Executa o teste de Shapiro-Wilk para avaliar normalidade das distribuições."""
    resultados = {}
    for col in colunas:
        serie = df[col].dropna()
        stat, p_val = shapiro(serie)
        resultados[col] = (stat, p_val)
        status = "Distribuição NORMAL" if p_val > 0.05 else "NÃO segue distribuição normal"
        print(f"[Shapiro-Wilk] {col}: W={stat:.4f}, p-valor={p_val:.4f} -> {status}")
    return resultados


def regressao_linear_simples(df: pd.DataFrame, col_x: str, col_y: str, valor_exemplo: float):
    """Ajusta Regressão Linear Simples (OLS) e retorna intercepto, coeficiente e R²."""
    X = df[[col_x]].dropna()
    y = df.loc[X.index, col_y]

    modelo = LinearRegression()
    modelo.fit(X, y)

    intercepto = float(modelo.intercept_)
    coeficiente = float(modelo.coef_[0])
    r2 = float(modelo.score(X, y))
    previsao = float(modelo.predict(pd.DataFrame({col_x: [valor_exemplo]}))[0])

    print(f"\n--- Regressão Linear Simples: {col_x} -> {col_y} ---")
    print(f"Intercepto: {intercepto:,.2f}")
    print(f"Coeficiente: {coeficiente:,.2f}")
    print(f"R²: {r2:.6f} ({r2 * 100:.2f}%)")
    print(f"Previsão para {col_x}={valor_exemplo}: {previsao:,.2f}")
    return modelo


def testes_nao_parametricos_tonalidade(df: pd.DataFrame):
    """
    Hipótese 5 (Variáveis Categóricas):
    - Mann-Whitney U para Mode (Minor vs Major)
    - Kruskal-Wallis para Key (Tonalidades musicais)
    """
    minor = df[df["mode"] == "Minor"]["streams"].dropna()
    major = df[df["mode"] == "Major"]["streams"].dropna()
    stat_mw, p_mw = mannwhitneyu(minor, major)
    print(f"\n[Mann-Whitney] Mode (Minor x Major): U={stat_mw:.4f}, p-valor={p_mw:.4f}")

    grupos_key = [df[df["key"] == k]["streams"].dropna() for k in df["key"].dropna().unique()]
    stat_kw, p_kw = kruskal(*grupos_key)
    print(f"[Kruskal-Wallis] Key (Notas musicais): H={stat_kw:.4f}, p-valor={p_kw:.4f}")


def regressao_multipla_e_vif(df: pd.DataFrame):
    """
    Hipótese 5 (Variáveis Numéricas Acústicas):
    Ajusta Regressão Linear Múltipla via Statsmodels OLS e calcula o VIF (Variance Inflation Factor).
    """
    features = [
        "bpm",
        "danceability_%",
        "valence_%",
        "energy_%",
        "acousticness_%",
        "instrumentalness_%",
        "liveness_%",
        "speechiness_%",
    ]
    sub = df[features + ["streams"]].dropna()
    X = sub[features]
    y = sub["streams"]

    X_const = sm.add_constant(X)
    modelo = sm.OLS(y, X_const).fit()
    print("\n--- Regressão Linear Múltipla (OLS) ---")
    print(modelo.summary())

    vif_data = pd.DataFrame()
    vif_data["variavel"] = X.columns
    vif_data["VIF"] = [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]
    print("\n--- Diagnóstico de Multicolinearidade (VIF) ---")
    print(vif_data.to_string(index=False))
    return modelo, vif_data


if __name__ == "__main__":
    print("Módulo de testes estatísticos carregado. Importe as funções ou forneça 'tabela_completa_limpa.csv'.")
