import pandas as pd
import numpy as np

# Cargar el dataset
df = pd.read_csv("ds_salaries.csv")

print("--- EJERCICIO 1: Indicadores Estadísticos ---")
# Promedio, Desviación Estándar, Mínimo, Máximo
base_stats = df['salary_in_usd'].describe()
# Quintiles (20%, 40%, 60%, 80%)
quintiles = df['salary_in_usd'].quantile([0.2, 0.4, 0.6, 0.8])
# Rango
salary_range = df['salary_in_usd'].max() - df['salary_in_usd'].min()

print(f"Promedio: {base_stats['mean']:.2f}")
print(f"Desviación Estándar: {base_stats['std']:.2f}")
print(f"Quintiles:\n{quintiles}")
print(f"Rango: {salary_range}")

print("\n--- EJERCICIO 2: Comparación por Categorías ---")
categories = ['experience_level', 'company_size', 'employment_type']

for cat in categories:
    print(f"\nEstadísticas para {cat}:")
    stats = df.groupby(cat)['salary_in_usd'].agg(['mean', 'median', 'std', 'count'])
    # Coeficiente de variación (CV) para evaluar representatividad
    stats['cv'] = stats['std'] / stats['mean']
    print(stats)

print("\n--- EJERCICIO 3: Interpretación ---")
interpretation = """
Interpretación General:
- El salario promedio general es de $137,570.39 USD con una desviación estándar de $63,055.63.
- El rango es de $444,868, lo que muestra una dispersión absoluta muy alta entre el salario mínimo ($5,132) y el máximo ($450,000).
- El 20% de los profesionales (primer quintil) gana menos de ~$84,000, mientras que el 20% superior supera los ~$185,900.

Análisis de Representatividad por Categoría:

1. Experience Level:
   - Más Representativa: 'EX' (Executive). Tienen el CV más bajo (0.36) y la media ($194k) está muy cerca de la mediana ($196k), indicando un grupo homogéneo.
   - Menos Representativa: 'EN' (Entry-level). El CV es de 0.66, lo que indica que los salarios iniciales varían mucho más proporcionalmente.

2. Company Size:
   - Más Representativa: 'M' (Medium). CV de 0.41 y mediana cercana a la media. Es el grupo con más datos (3153), lo que da robustez al promedio.
   - Menos Representativa: 'S' (Small). CV de 0.79, lo que sugiere una alta volatilidad en los sueldos de empresas pequeñas.

3. Employment Type:
   - Más Representativa: 'FT' (Full-time). CV de 0.45.
   - Menos Representativa: 'CT' (Contract) y 'PT' (Part-time). Tienen CVs > 0.9 y muy pocos registros (10 y 17 respectivamente). En estos casos, el promedio NO es representativo debido a la bajísima muestra y la alta dispersión.
"""
print(interpretation)
