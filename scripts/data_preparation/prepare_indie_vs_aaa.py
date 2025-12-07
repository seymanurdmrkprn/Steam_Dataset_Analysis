"""
Indie vs AAA Studio Comparison
Uses manual studio classification based on known industry categorization
"""
import pandas as pd
import numpy as np

print("Loading full dataset...")
# Load main dataset
df = pd.read_csv("../../data/raw/steam_games.csv")
print(f"Total games in dataset: {len(df)}")

# Create Main_Developer column by extracting first developer
if 'Developers' in df.columns:
    df['Main_Developer'] = df['Developers'].str.split(',').str[0].str.strip()
    print(f"✓ Extracted Main_Developer from {df['Main_Developer'].notna().sum()} games")

# Calculate positive rate and total reviews
df['positive_rate'] = (df['Positive'] / (df['Positive'] + df['Negative']) * 100).fillna(0)
df['total_reviews'] = df['Positive'] + df['Negative']
print(f"✓ Calculated ratings and reviews")

# Load studio type mapping
studio_mapping = pd.read_csv("../../data/mappings/studio_types.csv")
print(f"\n📋 Studio mapping loaded: {len(studio_mapping)} studios")
print(f"  - AAA: {(studio_mapping['StudioType']=='AAA').sum()}")
print(f"  - Mid-tier: {(studio_mapping['StudioType']=='Mid-tier').sum()}")
print(f"  - Indie: {(studio_mapping['StudioType']=='Indie').sum()}")

# Merge with main dataset
df = df.merge(studio_mapping, left_on='Main_Developer', right_on='Developer', how='left')

# Count matched games
matched = df['StudioType'].notna()
print(f"\n✅ Matched games: {matched.sum():,} ({matched.sum()/len(df)*100:.1f}%)")
print(f"❌ Unmatched games: {(~matched).sum():,} ({(~matched).sum()/len(df)*100:.1f}%)")

# Filter to only matched games
df_matched = df[matched].copy()

print("\n" + "="*60)
print("STUDIO TYPE DISTRIBUTION")
print("="*60)
print(df_matched['StudioType'].value_counts())
print()
for stype in ['Indie', 'Mid-tier', 'AAA']:
    count = (df_matched['StudioType'] == stype).sum()
    pct = count / len(df_matched) * 100
    print(f"{stype:10s}: {count:5,d} games ({pct:5.1f}%)")

print("\n" + "="*60)
print("PRICING STRATEGY COMPARISON")
print("="*60)
pricing = df_matched.groupby('StudioType').agg({
    'Price': ['mean', 'median', 'std', 'min', 'max']
}).round(2)
print(pricing)

print("\n" + "="*60)
print("SUCCESS METRICS COMPARISON")
print("="*60)
success = df_matched.groupby('StudioType').agg({
    'positive_rate': ['mean', 'median', 'std'],
    'total_reviews': ['median', 'mean'],
    'Median playtime forever': ['mean', 'median']
}).round(2)
print(success)

print("\n" + "="*60)
print("CONTENT & FEATURES COMPARISON")
print("="*60)
features = df_matched.groupby('StudioType').agg({
    'DLC count': ['mean', 'median'],
    'Achievements': ['mean', 'median'],
    'Windows': 'sum',
    'Mac': 'sum',
    'Linux': 'sum'
}).round(2)
print(features)

# Calculate platform support percentage
print("\n" + "="*60)
print("PLATFORM SUPPORT")
print("="*60)
for stype in ['Indie', 'Mid-tier', 'AAA']:
    studio_games = df_matched[df_matched['StudioType'] == stype]
    total = len(studio_games)
    win_pct = (studio_games['Windows'].sum() / total * 100)
    mac_pct = (studio_games['Mac'].sum() / total * 100)
    linux_pct = (studio_games['Linux'].sum() / total * 100)
    print(f"\n{stype}:")
    print(f"  Windows: {win_pct:.1f}%")
    print(f"  Mac: {mac_pct:.1f}%")
    print(f"  Linux: {linux_pct:.1f}%")

print("\n" + "="*60)
print("SUCCESS RATE (Rating ≥ 80%)")
print("="*60)
for stype in ['Indie', 'Mid-tier', 'AAA']:
    studio_games = df_matched[df_matched['StudioType'] == stype]
    high_rated = (studio_games['positive_rate'] >= 80).sum()
    success_rate = high_rated / len(studio_games) * 100
    print(f"{stype:10s}: {success_rate:5.1f}% ({high_rated:,}/{len(studio_games):,} games)")

print("\n" + "="*60)
print("PRICE CATEGORIES")
print("="*60)
df_matched['price_category'] = pd.cut(
    df_matched['Price'],
    bins=[0, 10, 20, 40, 60, 1000],
    labels=['$0-10', '$10-20', '$20-40', '$40-60', '$60+']
)
price_dist = pd.crosstab(df_matched['StudioType'], df_matched['price_category'], normalize='index') * 100
print(price_dist.round(1))

# Save processed data
print("\n" + "="*60)
print("SAVING PROCESSED DATA")
print("="*60)

# Full matched dataset
output_path = "../../data/processed/indie_vs_aaa_data.csv"
df_matched.to_csv(output_path, index=False)
print(f"✅ Full data: {output_path} ({len(df_matched):,} games)")

# Summary statistics
summary = df_matched.groupby('StudioType').agg({
    'Name': 'count',
    'Price': ['mean', 'median', 'std'],
    'positive_rate': ['mean', 'std'],
    'total_reviews': ['median', 'mean'],
    'Median playtime forever': ['mean', 'median'],
    'DLC count': 'mean',
    'Achievements': 'mean'
}).round(2)
summary.columns = ['_'.join(col) for col in summary.columns]
summary.reset_index(inplace=True)

summary_path = "../../data/processed/indie_vs_aaa_summary.csv"
summary.to_csv(summary_path, index=False)
print(f"✅ Summary: {summary_path}")

print("\n" + "="*60)
print("🎉 ANALYSIS COMPLETE!")
print("="*60)
print(f"\n📊 Key Findings:")
print(f"  • Total games analyzed: {len(df_matched):,}")
print(f"  • AAA studios avg price: ${df_matched[df_matched['StudioType']=='AAA']['Price'].mean():.2f}")
print(f"  • Indie studios avg price: ${df_matched[df_matched['StudioType']=='Indie']['Price'].mean():.2f}")
print(f"  • AAA success rate: {(df_matched[df_matched['StudioType']=='AAA']['positive_rate'] >= 80).sum() / len(df_matched[df_matched['StudioType']=='AAA']) * 100:.1f}%")
print(f"  • Indie success rate: {(df_matched[df_matched['StudioType']=='Indie']['positive_rate'] >= 80).sum() / len(df_matched[df_matched['StudioType']=='Indie']) * 100:.1f}%")
