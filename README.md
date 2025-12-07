
# Steam Games Analytics

Bu proje, Steam oyunları üzerinde analiz ve görselleştirme sunar. Python (Streamlit) ile etkileşimli bir dashboard ve Octave ile statik, yüksek kaliteli grafikler içerir.

## Kısaca Proje

- Oyun verileriyle istatistiksel analiz ve görselleştirme
- Streamlit ile kolayca web arayüzü üzerinden inceleme
- Octave ile profesyonel görseller
- Kod ve görseller GitHub’da, veri dosyaları hariç tutulmuştur

## Hızlı Başlangıç


# Steam Games Analytics

An interactive dashboard and visualization tool for Steam games data analysis.

## Overview

This project provides two complementary approaches to analyzing Steam games data:

- **Streamlit Dashboard**: Interactive web interface for exploring games with filters, search, and comparisons
- **Octave Panels**: High-quality static visualizations and statistical analysis using GNU Octave

## Quick Start

### Prerequisites
- Python 3.10+ with pip
- GNU Octave 9.2.0+ (for panels)

### Installation
1. Clone the repository:
	```bash
	git clone <repository-url>
	cd steam-games-analytics
	```
2. Install Python dependencies:
	```bash
	pip install streamlit pandas plotly
	```

### Running the Streamlit Dashboard
```bash
streamlit run steam_dashboard.py
```
Open your browser to the URL shown in the terminal (usually http://localhost:8501).

### Running Octave Demo
```octave
cd octave/main
octave_gui_demo_v3
```

## Project Structure

```
├── steam_dashboard.py      # Main Streamlit application
├── octave/                 # Octave analysis and demo files
├── scripts/                # Data preparation scripts
├── outputs/images/         # Panel images (static visualizations)
├── docs/                   # Documentation & feature comparisons
└── ...
```

## Features

### Streamlit Dashboard
- Interactive filtering by price, rating, and platform
- Multi-game comparison
- Image zoom for detailed viewing (see outputs/images/)
- Search and navigation

### Octave Analysis
- 12 different visualization panels
- Statistical analysis and correlations
- Professional publication-quality plots
- Curated dataset focusing on popular games

## About the Data

The dataset includes Steam games with:
- Complete price and rating information
- Platform support (Windows, Mac, Linux)
- Genre and developer details
- All NaN values filtered for clean analysis

> **Note:** The `data/` folder contains raw and processed data files, but is excluded from GitHub for size and privacy reasons.

## Documentation & Demo Comparison

- See `docs/OCTAVE_vs_STREAMLIT_COMPARISON.md` for a detailed comparison of Streamlit and Octave demos, their features, and use cases.
- Other documentation files in `docs/` explain project structure and usage tips.

## License

Academic project for Scientific Computing course.

---

**Last Updated**: December 2025

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
