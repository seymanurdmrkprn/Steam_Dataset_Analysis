# 🎮 Steam Games Analytics Project

> Comprehensive analysis of 83,560 Steam games using Octave and Python/Streamlit

## 📊 Project Overview

This project provides both **static high-quality visualizations** (Octave) and **interactive analysis** (Streamlit) for Steam games data.

### Key Statistics
- **Total Games**: 83,560
- **Demo Dataset**: 1,730 famous games
- **Analysis Panels**: 24 professional visualizations
- **Dashboard Pages**: 7 interactive pages
- **Octave Demo**: 12 menu options

## 🚀 Quick Start

### 1. Run Streamlit Dashboard
```bash
streamlit run steam_dashboard.py
```
Features:
- 🏠 Overview & statistics
- 🔍 Search & filter games
- ⚖️ Compare multiple games
- 📈 Interactive visualizations
- 🖼️ **24 static panels with zoom** (click "🔍 Büyüt" to enlarge)
- 📋 Sortable data table
- 💡 Key insights

### 2. Run Octave Interactive Demo
```octave
cd octave/main
octave_gui_demo_v3
```
12 Menu Options:
1. Top 10 Games
2. Price Analysis
3. Developer Rankings
4. Genre Distribution
5. Rating Analysis
6. **Price vs Rating** (redesigned 2×2 layout)
7. Review Distribution
8. Yearly Trends
9. Platform Analysis
10. Search Games
11. Find by Price Range
12. Statistics
13. Exit

## 📁 Project Structure

```
Scientific Computing/
├── data/
│   ├── raw/              # steam_games.csv (83,560 games)
│   ├── processed/        # demo_data.csv, panel CSVs
│   └── mappings/         # Translation files
├── scripts/
│   ├── data_preparation/ # Python preprocessing scripts
│   └── utilities/
├── octave/
│   ├── main/            # octave_gui_demo_v3.m
│   └── panels/          # 24 panel generation scripts
├── outputs/
│   └── images/          # 24 PNG panels (1600×1100, 300 DPI)
├── docs/
│   ├── PROJECT_STRUCTURE.md
│   ├── DEMO_GUIDE.md
│   └── OCTAVE_vs_STREAMLIT_COMPARISON.md
└── steam_dashboard.py   # Main Streamlit app
```

**See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for detailed structure**

## 🎨 Analysis Categories

### 24 Static Panels (Octave)
1. **Price Analysis (6 panels)**
   - Hexbin density, boxplot, distribution, heatmap, trends, genre comparison

2. **Playtime Analysis (4 panels)**
   - Density, boxplot, violin plot, genre facets

3. **Time Series (4 panels)**
   - Yearly trends, platform evolution, monthly patterns, genre trends

4. **Free vs Paid (2 panels)**
   - Score comparison, playtime comparison

5. **Performance Metrics (4 panels)**
   - Top 100 characteristics, success factors, developer analysis, top games

6. **Advanced Panels (4 panels)**
   - Scatter, boxplot, linechart, stacked bar

All panels:
- High quality: 1600×1100 pixels, 300 DPI
- Professional publication-ready
- Viewable in dashboard with zoom feature

## 🔧 Technical Details

### Technologies
- **Octave 9.2.0**: Static analysis & demo
- **Python 3.10+**: Data processing & dashboard
- **Streamlit**: Interactive web interface
- **Plotly**: Dynamic visualizations
- **Pandas**: Data manipulation

### Data Processing
- Raw data: `data/raw/steam_games.csv`
- Preprocessing: Python scripts in `scripts/data_preparation/`
- Fast loading: Preprocessed CSVs for Octave (2s vs 60s)
- Demo dataset: Famous games only (1,730 curated)

### Key Features
- ✅ All NaN values filtered
- ✅ Octave-compatible (no MATLAB-only functions)
- ✅ Professional aesthetics
- ✅ Image zoom in dashboard
- ✅ Search & filter functionality
- ✅ Price range finder
- ✅ Multi-game comparison

## 📖 Documentation

- **[PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** - Detailed directory structure
- **[DEMO_GUIDE.md](docs/DEMO_GUIDE.md)** - How to use Octave demo
- **[OCTAVE_vs_STREAMLIT_COMPARISON.md](docs/OCTAVE_vs_STREAMLIT_COMPARISON.md)** - Platform comparison

## 🐛 Recent Fixes

### Octave Demo (v3)
- ✅ Fixed bar chart overlapping (0.6 width)
- ✅ Fixed platform labels (XTick added)
- ✅ Fixed scatter plot (2×2 layout with density heatmap)
- ✅ Fixed review distribution (removed scientific notation)
- ✅ Fixed NaN developers (comprehensive filtering)
- ✅ All 12 menu options working

### Streamlit Dashboard
- ✅ Added image zoom feature ("🔍 Büyüt" buttons)
- ✅ Updated all file paths to new structure
- ✅ Fixed panel image loading

## 🎯 Usage Examples

### Generate Demo Dataset
```bash
cd scripts/data_preparation
python prepare_demo_data.py
```

### Run All Octave Panels
```octave
cd octave/panels
run_all_panels
```

### Update Advanced Panels
```bash
cd scripts/data_preparation
python prepare_advanced_panel_data.py
```

## 📊 Sample Insights

From our analysis:
- **Average Game Price**: $8.76
- **Average Rating**: 78.3%
- **Most Common Genre**: Action (15,234 games)
- **Platform Support**: 95% Windows, 25% Mac, 30% Linux
- **Free Games**: 22,891 (27.4%)
- **Correlation (Price-Rating)**: 0.087 (weak positive)

## 🤝 Contributing

This is an academic project. For questions or improvements, see documentation in `docs/`.

## 📄 License

Academic project - Scientific Computing course

---

**Last Updated**: December 2, 2025  
**Version**: 3.0 (Organized Structure)
