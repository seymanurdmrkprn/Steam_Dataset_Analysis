df = pd.read_csv('../../data/processed/indie_vs_aaa_data.csv')
successful = df[
    (df['positive_rate'] >= 80) & 
    (df['total_reviews'] >= 500) &
    (df['Price'] > 0)
].copy()
    total = len(df[df['StudioType'] == st])
    success = len(successful[successful['StudioType'] == st])
    print(f"  {st:10s}: {success:3d}/{total:3d} successful ({success/total*100:.1f}%)")
    'Price': ['count', 'mean', 'median', 'std', 'min', 'max']
}).round(2)
    'positive_rate': ['mean', 'median', 'std'],
    'total_reviews': ['mean', 'median', 'max'],
    'Median playtime forever': ['mean', 'median']
}).round(2)
    'DLC count': ['mean', 'median', 'max'],
    'Achievements': ['mean', 'median', 'max']
}).round(2)
    studio_games = successful[successful['StudioType'] == st]
    total = len(studio_games)
    if total > 0:
        win_pct = (studio_games['Windows'].sum() / total * 100)
        mac_pct = (studio_games['Mac'].sum() / total * 100)
        linux_pct = (studio_games['Linux'].sum() / total * 100)
        multi = ((studio_games['Windows'] + studio_games['Mac'] + studio_games['Linux']) >= 2).sum()
        multi_pct = multi / total * 100
        print(f"\n{st} ({total} games):")
        print(f"  Windows: {win_pct:.1f}%")
        print(f"  Mac: {mac_pct:.1f}%")
        print(f"  Linux: {linux_pct:.1f}%")
        print(f"  Multi-platform (2+): {multi_pct:.1f}%")
    print(f"\n🏆 Top 5 {st} Games:")
    top = successful[successful['StudioType'] == st].nlargest(5, 'total_reviews')[
        ['Name', 'Main_Developer', 'Price', 'positive_rate', 'total_reviews', 'Median playtime forever']
    ]
    for idx, row in top.iterrows():
        print(f"  {row['Name'][:40]:40s} | ${row['Price']:6.2f} | {row['positive_rate']:5.1f}% | {row['total_reviews']:7,.0f} reviews | {row['Median playtime forever']:5.0f}h")
successful['price_tier'] = pd.cut(
    successful['Price'],
    bins=[0, 10, 20, 30, 50, 1000],
    labels=['Budget ($0-10)', 'Standard ($10-20)', 'Premium ($20-30)', 'Deluxe ($30-50)', 'Ultra ($50+)']
)
price_dist = pd.crosstab(successful['StudioType'], successful['price_tier'], normalize='index') * 100
    studio = successful[successful['StudioType'] == st]
    if len(studio) > 0:
        print(f"\n{st}:")
        print(f"  • Avg Price: ${studio['Price'].mean():.2f}")
        print(f"  • Avg Rating: {studio['positive_rate'].mean():.1f}%")
        print(f"  • Avg Playtime: {studio['Median playtime forever'].mean():.0f} hours")
        print(f"  • Avg Reviews: {studio['total_reviews'].mean():,.0f}")
        print(f"  • Multi-platform: {((studio['Windows'] + studio['Mac'] + studio['Linux']) >= 2).sum() / len(studio) * 100:.1f}%")

import pandas as pd
import numpy as np

# Load dataset
df = pd.read_csv('../../data/processed/indie_vs_aaa_data.csv')

print("="*70)
print("SUCCESSFUL GAMES COMPARISON: INDIE vs AAA vs MID-TIER")
print("="*70)

# Success criteria:
# 1. Rating >= 80% (positive rate)
# 2. At least 500 reviews (visibility + credibility)
# 3. Paid game (free games have different dynamics)

print("\nSUCCESS CRITERIA:")
print("  - Rating ≥ 80%")
print("  - Minimum 500 reviews")
print("  - Paid game (Price > $0)")

# Filter successful games
successful = df[
    (df['positive_rate'] >= 80) & 
    (df['total_reviews'] >= 500) &
    (df['Price'] > 0)
].copy()

print(f"\nSUCCESSFUL GAMES COUNT:")
print(f"  Total in dataset: {len(df)}")
print(f"  Meeting success criteria: {len(successful)} ({len(successful)/len(df)*100:.1f}%)")
print()

# Studio type breakdown
for st in ['Indie', 'Mid-tier', 'AAA']:
    total = len(df[df['StudioType'] == st])
    success = len(successful[successful['StudioType'] == st])
    print(f"  {st:10s}: {success:3d}/{total:3d} successful ({success/total*100:.1f}%)")

print("\n" + "="*70)
print("PRICING COMPARISON (Successful Games Only)")
print("="*70)
pricing = successful.groupby('StudioType').agg({
    'Price': ['count', 'mean', 'median', 'std', 'min', 'max']
}).round(2)
print(pricing)

print("\n" + "="*70)
print("QUALITY METRICS (Successful Games Only)")
print("="*70)
quality = successful.groupby('StudioType').agg({
    'positive_rate': ['mean', 'median', 'std'],
    'total_reviews': ['mean', 'median', 'max'],
    'Median playtime forever': ['mean', 'median']
}).round(2)
print(quality)

print("\n" + "="*70)
print("CONTENT & FEATURES (Successful Games Only)")
print("="*70)
content = successful.groupby('StudioType').agg({
    'DLC count': ['mean', 'median', 'max'],
    'Achievements': ['mean', 'median', 'max']
}).round(2)
print(content)

print("\n" + "="*70)
print("PLATFORM SUPPORT (Successful Games Only)")
print("="*70)
for st in ['Indie', 'Mid-tier', 'AAA']:
    studio_games = successful[successful['StudioType'] == st]
    total = len(studio_games)
    if total > 0:
        win_pct = (studio_games['Windows'].sum() / total * 100)
        mac_pct = (studio_games['Mac'].sum() / total * 100)
        linux_pct = (studio_games['Linux'].sum() / total * 100)
        multi = ((studio_games['Windows'] + studio_games['Mac'] + studio_games['Linux']) >= 2).sum()
        multi_pct = multi / total * 100
        print(f"\n{st} ({total} games):")
        print(f"  Windows: {win_pct:.1f}%")
        print(f"  Mac: {mac_pct:.1f}%")
        print(f"  Linux: {linux_pct:.1f}%")
        print(f"  Multi-platform (2+): {multi_pct:.1f}%")

print("\n" + "="*70)
print("TOP PERFORMERS BY REVIEW COUNT")
print("="*70)
for st in ['Indie', 'Mid-tier', 'AAA']:
    print(f"\nTop 5 {st} Games:")
    top = successful[successful['StudioType'] == st].nlargest(5, 'total_reviews')[
        ['Name', 'Main_Developer', 'Price', 'positive_rate', 'total_reviews', 'Median playtime forever']
    ]
    for idx, row in top.iterrows():
        print(f"  {row['Name'][:40]:40s} | ${row['Price']:6.2f} | {row['positive_rate']:5.1f}% | {row['total_reviews']:7,.0f} reviews | {row['Median playtime forever']:5.0f}h")

print("\n" + "="*70)
print("PRICE TIER DISTRIBUTION (Successful Games)")
print("="*70)
successful['price_tier'] = pd.cut(
    successful['Price'],
    bins=[0, 10, 20, 30, 50, 1000],
    labels=['Budget ($0-10)', 'Standard ($10-20)', 'Premium ($20-30)', 'Deluxe ($30-50)', 'Ultra ($50+)']
)
price_dist = pd.crosstab(successful['StudioType'], successful['price_tier'], normalize='index') * 100
print(price_dist.round(1))

print("\n" + "="*70)
print("KEY INSIGHTS")
print("="*70)

# Print key insights for each studio type
for st in ['Indie', 'Mid-tier', 'AAA']:
    studio = successful[successful['StudioType'] == st]
    if len(studio) > 0:
        print(f"\n{st}:")
        print(f"  - Avg Price: ${studio['Price'].mean():.2f}")
        print(f"  - Avg Rating: {studio['positive_rate'].mean():.1f}%")
        print(f"  - Avg Playtime: {studio['Median playtime forever'].mean():.0f} hours")
        print(f"  - Avg Reviews: {studio['total_reviews'].mean():,.0f}")
        print(f"  - Multi-platform: {((studio['Windows'] + studio['Mac'] + studio['Linux']) >= 2).sum() / len(studio) * 100:.1f}%")

# Save successful games data to CSV
output_path = "../../data/processed/successful_games_comparison.csv"
successful.to_csv(output_path, index=False)
print(f"\nSaved: {output_path} ({len(successful)} games)")
