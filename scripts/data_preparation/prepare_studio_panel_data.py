import pandas as pd

# Load data
df = pd.read_csv('../../data/processed/successful_games_comparison.csv')

# Create simplified files for each panel
print("Creating simplified data files for Octave panels...")

# Panel 1: Pricing
pricing_data = df[['StudioType', 'Price']].copy()
pricing_data.to_csv('../../data/processed/studio_panel1_data.csv', index=False)
print(f"✓ Panel 1 data: {len(pricing_data)} rows")

# Panel 2: Quality
quality_data = df[['StudioType', 'positive_rate', 'total_reviews']].copy()
quality_data.to_csv('../../data/processed/studio_panel2_data.csv', index=False)
print(f"✓ Panel 2 data: {len(quality_data)} rows")

# Panel 3: Content
content_data = df[['StudioType', 'Median playtime forever', 'DLC count', 'Achievements']].copy()
content_data.to_csv('../../data/processed/studio_panel3_data.csv', index=False)
print(f"✓ Panel 3 data: {len(content_data)} rows")

# Panel 4: Platforms
platform_data = df[['StudioType', 'Windows', 'Mac', 'Linux']].copy()
# Convert boolean to int (1/0) for Octave
platform_data['Windows'] = platform_data['Windows'].astype(int)
platform_data['Mac'] = platform_data['Mac'].astype(int)
platform_data['Linux'] = platform_data['Linux'].astype(int)
platform_data.to_csv('../../data/processed/studio_panel4_data.csv', index=False)
print(f"✓ Panel 4 data: {len(platform_data)} rows")

print("\n✅ All simplified data files created!")
