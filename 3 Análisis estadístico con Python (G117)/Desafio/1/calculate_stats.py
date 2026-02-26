import pandas as pd

df = pd.read_csv("ds_salaries.csv")

# Requirement 1: Salary in USD statistics
print("--- Requirement 1 ---")
salary_stats = df['salary_in_usd'].describe(percentiles=[.2, .4, .6, .8])
range_val = df['salary_in_usd'].max() - df['salary_in_usd'].min()
print(salary_stats)
print(f"Range: {range_val}")

# Requirement 2: Grouping by 3 categories
print("\n--- Requirement 2 ---")
categories = ['experience_level', 'company_size', 'employment_type']

for cat in categories:
    print(f"\nStats for {cat}:")
    stats = df.groupby(cat)['salary_in_usd'].agg(['mean', 'median', 'std', 'count'])
    # Coefficient of variation to help with "representativeness"
    stats['cv'] = stats['std'] / stats['mean']
    print(stats)

# Requirement 3: Interpretation
# I will do this in the notebook/response.
