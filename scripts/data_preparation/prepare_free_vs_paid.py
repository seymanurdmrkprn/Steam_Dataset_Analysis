"""
FREE VS PAID GAMES DATA PREPARATION
Compares free and paid games on various metrics
"""

import pandas as pd
import numpy as np

print("=" * 60)
print("FREE VS PAID GAMES DATA PREPARATION")
print("=" * 60)

# Load data
df = pd.read_csv('steam_games.csv')
print(f"\n📊 Loaded {len(df):,} games")

# Filter games with at least 50 reviews for reliability
df = df[(df['Positive'] + df['Negative']) >= 50].copy()
print(f"✓ With 50+ reviews: {len(df):,} games")

# Calculate metrics
df['total_reviews'] = df['Positive'] + df['Negative']
df['positive_rate'] = (df['Positive'] / df['total_reviews'] * 100)

# Categorize by price
df['is_free'] = df['Price'] == 0
df['price_category'] = df['is_free'].map({True: 'Free', False: 'Paid'})

# Remove extreme outliers in playtime (keep 0-2000 hours)
df = df[df['Median playtime forever'] <= 2000].copy()

print(f"\n📈 Free vs Paid Breakdown:")
print(f"  • Free games: {df['is_free'].sum():,} ({df['is_free'].sum()/len(df)*100:.1f}%)")
print(f"  • Paid games: {(~df['is_free']).sum():,} ({(~df['is_free']).sum()/len(df)*100:.1f}%)")

# === PANEL 1: SCORE COMPARISON ===
print("\n⭐ Panel 1: Score Comparison (Violin Plot Data)")

# Sample data for violin plot (take max 500 from each to keep manageable)
free_scores = df[df['is_free']]['positive_rate'].dropna().sample(min(500, df['is_free'].sum()), random_state=42)
paid_scores = df[~df['is_free']]['positive_rate'].dropna().sample(min(500, (~df['is_free']).sum()), random_state=42)

# Combine and save
violin_data = pd.DataFrame({
    'score': pd.concat([free_scores, paid_scores]),
    'category': ['Free']*len(free_scores) + ['Paid']*len(paid_scores)
})
violin_data.to_csv('free_vs_paid_scores.csv', index=False)
print(f"  ✓ Saved: {len(violin_data):,} samples")
print(f"  • Free avg: {free_scores.mean():.1f}%")
print(f"  • Paid avg: {paid_scores.mean():.1f}%")

# === PANEL 2: PLAYTIME COMPARISON ===
print("\n⏱️  Panel 2: Playtime Comparison")

# Sample playtime data
free_playtime = df[df['is_free']]['Median playtime forever'].dropna()
free_playtime = free_playtime[free_playtime > 0].sample(min(500, len(free_playtime)), random_state=42)

paid_playtime = df[~df['is_free']]['Median playtime forever'].dropna()
paid_playtime = paid_playtime[paid_playtime > 0].sample(min(500, len(paid_playtime)), random_state=42)

playtime_data = pd.DataFrame({
    'playtime': pd.concat([free_playtime, paid_playtime]),
    'category': ['Free']*len(free_playtime) + ['Paid']*len(paid_playtime)
})
playtime_data.to_csv('free_vs_paid_playtime.csv', index=False)
print(f"  ✓ Saved: {len(playtime_data):,} samples")
print(f"  • Free median: {free_playtime.median():.0f} hours")
print(f"  • Paid median: {paid_playtime.median():.0f} hours")

# === SUMMARY STATISTICS ===
print("\n📊 Summary Statistics")

summary = df.groupby('price_category').agg({
    'Name': 'count',
    'positive_rate': ['mean', 'median'],
    'Median playtime forever': ['mean', 'median'],
    'total_reviews': ['mean', 'median']
}).round(2)

summary.to_csv('free_vs_paid_summary.csv')
print(summary)

print("\n" + "=" * 60)
print("✅ FREE VS PAID DATA PREPARATION COMPLETE")
print("=" * 60)
print("\nGenerated files:")
print("  1. free_vs_paid_scores.csv - Score distribution data")
print("  2. free_vs_paid_playtime.csv - Playtime distribution data")
print("  3. free_vs_paid_summary.csv - Summary statistics")
print("\n🎨 Ready for Octave visualization!")
