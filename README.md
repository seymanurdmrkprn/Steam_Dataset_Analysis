

# Steam Games Analytics

This project offers analysis and visualization of Steam games. It includes an interactive dashboard with Python (Streamlit) and high-quality static graphics with Octave.

## About the Project

- Statistical analysis and visualization of game data
- Easy-to-use web interface via Streamlit for exploration
- Professional visualizations with Octave
- Code and graphics are on GitHub; data files are excluded

## Quick Start

### Prerequisites
- Python 3.10+ with pip
- GNU Octave 9.2.0+ (for panels)

### Installation
Clone the repository:

```bash
git clone <https://github.com/seymanurdmrkprn/Steam_Dataset_Analysis>
cd steam-games-analytics
```

Install Python dependencies:

```bash
pip install streamlit pandas plotly
```

### Running the Streamlit Dashboard

```bash
streamlit run steam_dashboard.py
```
Open your browser to the URL shown in the terminal (usually http://localhost:8501).

### Running the Octave Demo

```bash
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
- Image zoom for detailed viewing
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

**Note:** The `data/` folder contains raw and processed data files, but is excluded from GitHub for size and privacy reasons.

## Documentation & Demo Comparison

See `docs/OCTAVE_vs_STREAMLIT_COMPARISON.md` for a detailed comparison of Streamlit and Octave demos, their features, and use cases.
Other documentation files in `docs/` explain project structure and usage tips.

## Contributing

This is an academic project. For questions or improvements, see documentation in `docs/`.

## License

Academic project for Scientific Computing course.

---

**Last Updated**: December 2025
**Version**: 3.0 (Organized Structure)
