#!/usr/bin/env python3
"""
Create NEW advanced visualization panels for Steam Games Analysis
- Scatter plots
- Box plots  
- Line charts
- Stacked bar charts
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from scipy import stats

# Set style
sns.set_style("whitegrid")
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['figure.figsize'] = (16, 11)

print("Loading demo dataset...")
df = pd.read_csv('demo_data.csv')

# Calculate rating
df['rating'] = 100 * df['Positive'] / (df['Positive'] + df['Negative'])
df['total_reviews'] = df['Positive'] + df['Negative']
df = df[df['total_reviews'] > 0]

print(f"Loaded {len(df)} games\n")

# ============================================================
# SCATTER PLOT PANEL: Price vs Rating
# ============================================================
print("Creating Scatter Plot Panel: Price vs Rating...")

fig, axes = plt.subplots(2, 2, figsize=(16, 11))
fig.suptitle('Price vs Rating Analysis - Scatter Plots', fontsize=20, fontweight='bold', y=0.98)

# Filter for better visualization
df_viz = df[df['total_reviews'] >= 10].copy()

# Panel 1: Basic scatter
ax = axes[0, 0]
scatter = ax.scatter(df_viz['Price'], df_viz['rating'], 
                     c=df_viz['rating'], cmap='RdYlGn', 
                     s=50, alpha=0.6, edgecolors='black', linewidth=0.5)
ax.set_xlabel('Price ($)', fontsize=12, fontweight='bold')
ax.set_ylabel('Rating (%)', fontsize=12, fontweight='bold')
ax.set_title('Price vs Rating (Color = Rating)', fontsize=14, fontweight='bold')
ax.set_ylim(0, 100)
ax.grid(True, alpha=0.3)
plt.colorbar(scatter, ax=ax, label='Rating (%)')

# Add trend line
z = np.polyfit(df_viz['Price'], df_viz['rating'], 1)
p = np.poly1d(z)
ax.plot(df_viz['Price'].sort_values(), p(df_viz['Price'].sort_values()), 
        "r--", linewidth=2, label=f'Trend: y={z[0]:.3f}x+{z[1]:.1f}')
ax.legend()

# Panel 2: Bubble plot (size = review count)
ax = axes[0, 1]
sizes = np.log10(df_viz['total_reviews'] + 1) * 20
scatter = ax.scatter(df_viz['Price'], df_viz['rating'], 
                     s=sizes, c=df_viz['rating'], cmap='viridis',
                     alpha=0.5, edgecolors='black', linewidth=0.5)
ax.set_xlabel('Price ($)', fontsize=12, fontweight='bold')
ax.set_ylabel('Rating (%)', fontsize=12, fontweight='bold')
ax.set_title('Bubble Plot (Size = Review Count)', fontsize=14, fontweight='bold')
ax.set_ylim(0, 100)
ax.grid(True, alpha=0.3)
plt.colorbar(scatter, ax=ax, label='Rating (%)')

# Panel 3: Hexbin density
ax = axes[1, 0]
hexbin = ax.hexbin(df_viz['Price'], df_viz['rating'], 
                   gridsize=30, cmap='YlOrRd', mincnt=1)
ax.set_xlabel('Price ($)', fontsize=12, fontweight='bold')
ax.set_ylabel('Rating (%)', fontsize=12, fontweight='bold')
ax.set_title('Hexbin Density Plot', fontsize=14, fontweight='bold')
ax.set_ylim(0, 100)
plt.colorbar(hexbin, ax=ax, label='Count')

# Panel 4: Correlation stats
ax = axes[1, 1]
ax.axis('off')

# Calculate correlations for different price ranges
price_ranges = [
    ('All Games', df_viz),
    ('$0-10', df_viz[df_viz['Price'] <= 10]),
    ('$10-30', df_viz[(df_viz['Price'] > 10) & (df_viz['Price'] <= 30)]),
    ('$30-60', df_viz[(df_viz['Price'] > 30) & (df_viz['Price'] <= 60)]),
    ('$60+', df_viz[df_viz['Price'] > 60])
]

stats_text = "CORRELATION STATISTICS\n" + "="*50 + "\n\n"
for name, subset in price_ranges:
    if len(subset) > 1:
        corr = subset['Price'].corr(subset['rating'])
        stats_text += f"{name:12} | Corr: {corr:6.3f} | n={len(subset):5}\n"

stats_text += "\n" + "="*50 + "\n\n"
stats_text += f"Overall Statistics:\n"
stats_text += f"  Total Games: {len(df_viz)}\n"
stats_text += f"  Avg Price: ${df_viz['Price'].mean():.2f}\n"
stats_text += f"  Avg Rating: {df_viz['rating'].mean():.1f}%\n"
stats_text += f"  Median Price: ${df_viz['Price'].median():.2f}\n"
stats_text += f"  Median Rating: {df_viz['rating'].median():.1f}%\n"

ax.text(0.1, 0.9, stats_text, transform=ax.transAxes, 
        fontsize=11, verticalalignment='top', fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('scatter_panel_price_vs_rating.png', bbox_inches='tight')
print("✓ Saved: scatter_panel_price_vs_rating.png\n")
plt.close()

# ============================================================
# BOX PLOT PANEL: Review Distribution
# ============================================================
print("Creating Box Plot Panel: Review Distribution...")

fig, axes = plt.subplots(2, 2, figsize=(16, 11))
fig.suptitle('Review Count Distribution - Box Plots', fontsize=20, fontweight='bold', y=0.98)

# Panel 1: Box plot by price category
ax = axes[0, 0]
df_viz['price_cat'] = pd.cut(df_viz['Price'], 
                               bins=[0, 10, 20, 30, 50, 1000],
                               labels=['$0-10', '$10-20', '$20-30', '$30-50', '$50+'])
df_viz['log_reviews'] = np.log10(df_viz['total_reviews'] + 1)

sns.boxplot(data=df_viz, x='price_cat', y='log_reviews', ax=ax, palette='Set2')
ax.set_xlabel('Price Category', fontsize=12, fontweight='bold')
ax.set_ylabel('Log10(Review Count)', fontsize=12, fontweight='bold')
ax.set_title('Review Distribution by Price Category', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

# Panel 2: Box plot by rating category
ax = axes[0, 1]
df_viz['rating_cat'] = pd.cut(df_viz['rating'], 
                                bins=[0, 50, 70, 80, 90, 100],
                                labels=['<50%', '50-70%', '70-80%', '80-90%', '90+%'])

sns.boxplot(data=df_viz, x='rating_cat', y='log_reviews', ax=ax, palette='RdYlGn')
ax.set_xlabel('Rating Category', fontsize=12, fontweight='bold')
ax.set_ylabel('Log10(Review Count)', fontsize=12, fontweight='bold')
ax.set_title('Review Distribution by Rating', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')
ax.tick_params(axis='x', rotation=45)

# Panel 3: Violin plot
ax = axes[1, 0]
sns.violinplot(data=df_viz, x='price_cat', y='log_reviews', ax=ax, palette='muted')
ax.set_xlabel('Price Category', fontsize=12, fontweight='bold')
ax.set_ylabel('Log10(Review Count)', fontsize=12, fontweight='bold')
ax.set_title('Review Distribution (Violin Plot)', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

# Panel 4: Strip plot with box
ax = axes[1, 1]
sns.boxplot(data=df_viz, x='price_cat', y='log_reviews', ax=ax, color='lightblue')
sns.stripplot(data=df_viz, x='price_cat', y='log_reviews', ax=ax, 
              size=2, color='red', alpha=0.3)
ax.set_xlabel('Price Category', fontsize=12, fontweight='bold')
ax.set_ylabel('Log10(Review Count)', fontsize=12, fontweight='bold')
ax.set_title('Box Plot with Strip Plot Overlay', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('boxplot_panel_review_distribution.png', bbox_inches='tight')
print("✓ Saved: boxplot_panel_review_distribution.png\n")
plt.close()

# ============================================================
# LINE CHART PANEL: Yearly Trends (Simulated)
# ============================================================
print("Creating Line Chart Panel: Yearly Trends...")

fig, axes = plt.subplots(2, 2, figsize=(16, 11))
fig.suptitle('Yearly Trends Analysis - Line Charts', fontsize=20, fontweight='bold', y=0.98)

# Simulate years based on demo_score (higher score = newer game)
df_sorted = df_viz.sort_values('demo_score', ascending=False).copy()
games_per_year = len(df_sorted) // 15
year_offset = np.minimum((df_sorted.reset_index(drop=True).index // games_per_year), 14)
df_sorted['year'] = 2024 - year_offset

# Panel 1: Games released per year
ax = axes[0, 0]
year_counts = df_sorted.groupby('year').size()
ax.plot(year_counts.index, year_counts.values, marker='o', linewidth=3, 
        markersize=8, color='#2E86AB', markerfacecolor='#2E86AB')
ax.fill_between(year_counts.index, year_counts.values, alpha=0.3, color='#2E86AB')
ax.set_xlabel('Year', fontsize=12, fontweight='bold')
ax.set_ylabel('Number of Games Released', fontsize=12, fontweight='bold')
ax.set_title('Games Released Per Year (Simulated)', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel 2: Average price trend
ax = axes[0, 1]
year_price = df_sorted.groupby('year')['Price'].mean()
ax.plot(year_price.index, year_price.values, marker='s', linewidth=3,
        markersize=8, color='#A23B72', markerfacecolor='#A23B72')
ax.fill_between(year_price.index, year_price.values, alpha=0.3, color='#A23B72')
ax.set_xlabel('Year', fontsize=12, fontweight='bold')
ax.set_ylabel('Average Price ($)', fontsize=12, fontweight='bold')
ax.set_title('Average Game Price Over Time', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel 3: Average rating trend
ax = axes[1, 0]
year_rating = df_sorted.groupby('year')['rating'].mean()
ax.plot(year_rating.index, year_rating.values, marker='d', linewidth=3,
        markersize=8, color='#18A558', markerfacecolor='#18A558')
ax.fill_between(year_rating.index, year_rating.values, alpha=0.3, color='#18A558')
ax.set_xlabel('Year', fontsize=12, fontweight='bold')
ax.set_ylabel('Average Rating (%)', fontsize=12, fontweight='bold')
ax.set_title('Average Rating Over Time', fontsize=14, fontweight='bold')
ax.set_ylim(0, 100)
ax.grid(True, alpha=0.3)

# Panel 4: Multiple metrics combined
ax = axes[1, 1]
ax2 = ax.twinx()
ax3 = ax.twinx()
ax3.spines['right'].set_position(('outward', 60))

l1 = ax.plot(year_counts.index, year_counts.values, marker='o', linewidth=2,
             label='Game Count', color='#2E86AB')
l2 = ax2.plot(year_price.index, year_price.values, marker='s', linewidth=2,
              label='Avg Price', color='#A23B72')
l3 = ax3.plot(year_rating.index, year_rating.values, marker='d', linewidth=2,
              label='Avg Rating', color='#18A558')

ax.set_xlabel('Year', fontsize=12, fontweight='bold')
ax.set_ylabel('Game Count', fontsize=10, fontweight='bold', color='#2E86AB')
ax2.set_ylabel('Avg Price ($)', fontsize=10, fontweight='bold', color='#A23B72')
ax3.set_ylabel('Avg Rating (%)', fontsize=10, fontweight='bold', color='#18A558')
ax.set_title('Combined Trends (Triple Y-Axis)', fontsize=14, fontweight='bold')

lines = l1 + l2 + l3
labels = [l.get_label() for l in lines]
ax.legend(lines, labels, loc='upper left')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('linechart_panel_yearly_trends.png', bbox_inches='tight')
print("✓ Saved: linechart_panel_yearly_trends.png\n")
plt.close()

# ============================================================
# STACKED BAR CHART PANEL: Platform Analysis (Simulated)
# ============================================================
print("Creating Stacked Bar Panel: Platform Analysis...")

fig, axes = plt.subplots(2, 2, figsize=(16, 11))
fig.suptitle('Platform Support Analysis - Stacked Bar Charts', fontsize=20, fontweight='bold', y=0.98)

# Simulate platform support
np.random.seed(42)
n = len(df_viz)
df_viz['windows'] = True  # All games on Windows
df_viz['mac'] = np.random.rand(n) < 0.6  # 60% Mac
df_viz['linux'] = np.random.rand(n) < 0.4  # 40% Linux

# Expensive games have more platform support
expensive_idx = df_viz['Price'] > 30
df_viz.loc[expensive_idx, 'mac'] = np.random.rand(expensive_idx.sum()) < 0.8
df_viz.loc[expensive_idx, 'linux'] = np.random.rand(expensive_idx.sum()) < 0.6

# Create platform categories
df_viz['platform_cat'] = 'Windows Only'
df_viz.loc[df_viz['mac'] & ~df_viz['linux'], 'platform_cat'] = 'Win + Mac'
df_viz.loc[~df_viz['mac'] & df_viz['linux'], 'platform_cat'] = 'Win + Linux'
df_viz.loc[df_viz['mac'] & df_viz['linux'], 'platform_cat'] = 'All Platforms'

# Panel 1: Platform distribution by price
ax = axes[0, 0]
platform_price = pd.crosstab(df_viz['price_cat'], df_viz['platform_cat'])
platform_price.plot(kind='bar', stacked=True, ax=ax, 
                    color=['#E63946', '#F1FAEE', '#A8DADC', '#457B9D'])
ax.set_xlabel('Price Category', fontsize=12, fontweight='bold')
ax.set_ylabel('Number of Games', fontsize=12, fontweight='bold')
ax.set_title('Platform Support by Price (Stacked)', fontsize=14, fontweight='bold')
ax.legend(title='Platform', loc='upper left')
ax.grid(True, alpha=0.3, axis='y')
plt.setp(ax.xaxis.get_majorticklabels(), rotation=45, ha='right')

# Panel 2: Percentage stacked
ax = axes[0, 1]
platform_price_pct = platform_price.div(platform_price.sum(axis=1), axis=0) * 100
platform_price_pct.plot(kind='bar', stacked=True, ax=ax,
                        color=['#E63946', '#F1FAEE', '#A8DADC', '#457B9D'])
ax.set_xlabel('Price Category', fontsize=12, fontweight='bold')
ax.set_ylabel('Percentage (%)', fontsize=12, fontweight='bold')
ax.set_title('Platform Support % by Price', fontsize=14, fontweight='bold')
ax.legend(title='Platform', loc='upper right')
ax.grid(True, alpha=0.3, axis='y')
plt.setp(ax.xaxis.get_majorticklabels(), rotation=45, ha='right')

# Panel 3: Total platform support
ax = axes[1, 0]
platform_totals = pd.Series({
    'Windows': df_viz['windows'].sum(),
    'Mac': df_viz['mac'].sum(),
    'Linux': df_viz['linux'].sum()
})
colors_platform = ['#0077B6', '#90E0EF', '#F77F00']
bars = ax.bar(platform_totals.index, platform_totals.values, color=colors_platform, 
              edgecolor='black', linewidth=2)
ax.set_ylabel('Number of Games', fontsize=12, fontweight='bold')
ax.set_title('Total Platform Support', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

# Add value labels
for bar in bars:
    height = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2., height,
            f'{int(height)}',
            ha='center', va='bottom', fontweight='bold')

# Panel 4: Platform combinations
ax = axes[1, 1]
platform_combo_counts = df_viz['platform_cat'].value_counts()
colors_combo = ['#06D6A0', '#118AB2', '#073B4C', '#EF476F']
explode = [0.05 if i == platform_combo_counts.argmax() else 0 
           for i in range(len(platform_combo_counts))]
ax.pie(platform_combo_counts.values, labels=platform_combo_counts.index,
       autopct='%1.1f%%', startangle=90, colors=colors_combo,
       explode=explode, shadow=True, textprops={'fontsize': 11, 'fontweight': 'bold'})
ax.set_title('Platform Combination Distribution', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('stackedbar_panel_platform_analysis.png', bbox_inches='tight')
print("✓ Saved: stackedbar_panel_platform_analysis.png\n")
plt.close()

print("="*60)
print("ALL NEW PANELS CREATED SUCCESSFULLY!")
print("="*60)
print("\nCreated 4 new advanced panel types:")
print("  1. scatter_panel_price_vs_rating.png")
print("  2. boxplot_panel_review_distribution.png")
print("  3. linechart_panel_yearly_trends.png")
print("  4. stackedbar_panel_platform_analysis.png")
print("\nTotal panels in workspace: 24 (20 old + 4 new)")
