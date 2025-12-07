import pandas as pd
import numpy as np

df = pd.read_csv('../../data/processed/indie_vs_aaa_data.csv')

print("="*70)
print("POTENTIAL BIAS ANALYSIS")
print("="*70)

print("\n1. REVIEW COUNT DISTRIBUTION")
print("-"*70)
for st in ['Indie', 'Mid-tier', 'AAA']:
    studio_df = df[df['StudioType'] == st]
    print(f"\n{st}:")
    print(f"  Median reviews: {studio_df['total_reviews'].median():,.0f}")
    print(f"  Mean reviews: {studio_df['total_reviews'].mean():,.0f}")
    print(f"  Games < 100 reviews: {(studio_df['total_reviews'] < 100).sum()}/{len(studio_df)} ({(studio_df['total_reviews'] < 100).sum()/len(studio_df)*100:.1f}%)")
    print(f"  Games < 500 reviews: {(studio_df['total_reviews'] < 500).sum()}/{len(studio_df)} ({(studio_df['total_reviews'] < 500).sum()/len(studio_df)*100:.1f}%)")
    print(f"  Games > 10,000 reviews: {(studio_df['total_reviews'] > 10000).sum()}/{len(studio_df)} ({(studio_df['total_reviews'] > 10000).sum()/len(studio_df)*100:.1f}%)")

print("\n2. SUCCESS RATE BY REVIEW COUNT THRESHOLD")
print("-"*70)
thresholds = [10, 50, 100, 500, 1000, 5000]
for threshold in thresholds:
    print(f"\n Minimum {threshold} reviews:")
    for st in ['Indie', 'Mid-tier', 'AAA']:
        studio_df = df[(df['StudioType'] == st) & (df['total_reviews'] >= threshold)]
        if len(studio_df) > 0:
            success_rate = (studio_df['positive_rate'] >= 80).sum() / len(studio_df) * 100
            print(f"  {st:10s}: {success_rate:5.1f}% ({len(studio_df):3d} games)")
        else:
            print(f"  {st:10s}: N/A (0 games)")

print("\n3. FREE vs PAID GAMES")
print("-"*70)
for st in ['Indie', 'Mid-tier', 'AAA']:
    studio_df = df[df['StudioType'] == st]
    free = (studio_df['Price'] == 0).sum()
    paid = (studio_df['Price'] > 0).sum()
    print(f"\n{st}:")
    print(f"  Free games: {free}/{len(studio_df)} ({free/len(studio_df)*100:.1f}%)")
    print(f"  Paid games: {paid}/{len(studio_df)} ({paid/len(studio_df)*100:.1f}%)")
    
    if free > 0:
        free_success = (studio_df[studio_df['Price'] == 0]['positive_rate'] >= 80).sum() / free * 100
        print(f"  Free games success rate: {free_success:.1f}%")
    if paid > 0:
        paid_success = (studio_df[studio_df['Price'] > 0]['positive_rate'] >= 80).sum() / paid * 100
        print(f"  Paid games success rate: {paid_success:.1f}%")

print("\n4. RATING DISTRIBUTION")
print("-"*70)
for st in ['Indie', 'Mid-tier', 'AAA']:
    studio_df = df[df['StudioType'] == st]
    print(f"\n{st}:")
    print(f"  Mean rating: {studio_df['positive_rate'].mean():.1f}%")
    print(f"  Median rating: {studio_df['positive_rate'].median():.1f}%")
    print(f"  Std dev: {studio_df['positive_rate'].std():.1f}")
    print(f"  Rating > 90%: {(studio_df['positive_rate'] >= 90).sum()}/{len(studio_df)} ({(studio_df['positive_rate'] >= 90).sum()/len(studio_df)*100:.1f}%)")
    print(f"  Rating 70-90%: {((studio_df['positive_rate'] >= 70) & (studio_df['positive_rate'] < 90)).sum()}/{len(studio_df)} ({((studio_df['positive_rate'] >= 70) & (studio_df['positive_rate'] < 90)).sum()/len(studio_df)*100:.1f}%)")
    print(f"  Rating < 70%: {(studio_df['positive_rate'] < 70).sum()}/{len(studio_df)} ({(studio_df['positive_rate'] < 70).sum()/len(studio_df)*100:.1f}%)")

print("\n5. SAMPLE SIZES")
print("-"*70)
print("AAA games might include more 'experimental' or franchise fatigue titles")
print("Indie selection bias: only successful indies get noticed in our mapping")
print("\nCurrent sample:")
for st in ['Indie', 'Mid-tier', 'AAA']:
    count = len(df[df['StudioType'] == st])
    print(f"  {st}: {count} games")
