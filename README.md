
# Steam Games Analytics

Bu proje, Steam oyunları üzerinde analiz ve görselleştirme sunar. Python (Streamlit) ile etkileşimli bir dashboard ve Octave ile statik, yüksek kaliteli grafikler içerir.

## Kısaca Proje

- Oyun verileriyle istatistiksel analiz ve görselleştirme
- Streamlit ile kolayca web arayüzü üzerinden inceleme
- Octave ile profesyonel görseller
- Kod ve görseller GitHub’da, veri dosyaları hariç tutulmuştur

## Hızlı Başlangıç

**Dashboard’ı başlatmak için:**
```bash
streamlit run steam_dashboard.py
```

**Octave demo için:**
```octave
cd octave/main
octave_gui_demo_v3
```

## Klasörler

- `steam_dashboard.py`: Ana Streamlit uygulaması
- `octave/`: Octave demo ve panel dosyaları
- `scripts/`: Veri hazırlama ve yardımcı Python scriptleri
- `outputs/images/`: Panel görselleri
- `docs/`: Proje dokümantasyonu
- `data/`: (GitHub’a eklenmez, veri dosyaları burada tutulur)

## Katkı & İletişim

Bu proje akademik amaçlıdır. Soruların veya önerilerin için dokümantasyon klasörüne göz atabilirsin.

---

**Son güncelleme:** Aralık 2025

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
