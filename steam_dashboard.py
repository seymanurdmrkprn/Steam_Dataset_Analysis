"""
🎮 STEAM GAMES ANALYTICS DASHBOARD
Interactive dashboard for exploring Steam games data
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np
from datetime import datetime
import os
from pathlib import Path

# Page configuration
st.set_page_config(
    page_title="Steam Games Analytics",
    page_icon="🎮",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
<style>
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        text-align: center;
        background: linear-gradient(90deg, #1b2838 0%, #2a475e 100%);
        color: white;
        padding: 2rem;
        border-radius: 10px;
        margin-bottom: 2rem;
    }
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 10px;
        color: white;
        text-align: center;
    }
    .stButton>button {
        width: 100%;
        background-color: #1b2838;
        color: white;
    }
</style>
""", unsafe_allow_html=True)

# Load data with caching
@st.cache_data
def load_data():
    """Load and prepare Steam games dataset"""
    df = pd.read_csv('data/raw/steam_games.csv')
    
    # Data preprocessing
    df['Release date'] = pd.to_datetime(df['Release date'], errors='coerce')
    df['Release_Year'] = df['Release date'].dt.year
    df['total_reviews'] = df['Positive'] + df['Negative']
    df['positive_rate'] = (df['Positive'] / df['total_reviews'] * 100).round(2)
    df['platform_count'] = df[['Windows', 'Mac', 'Linux']].sum(axis=1)
    
    # Clean genres
    df['Genres'] = df['Genres'].fillna('Unknown')
    df['genre_list'] = df['Genres'].str.split(',')
    
    # Developer cleanup
    df['Main_Developer'] = df['Developers'].str.split(',').str[0].str.strip()
    
    return df

# Sidebar - Navigation
with st.sidebar:
    st.image("https://store.cloudflare.steamstatic.com/public/shared/images/header/logo_steam.svg", width=200)
    st.markdown("<h3 style='text-align: center; color: #1b2838;'>Steam Analytics</h3>", unsafe_allow_html=True)
    st.markdown("---")
    
    st.markdown("### 📊 Navigation")
    st.caption("Select a page to explore")
    
    page = st.selectbox(
        "Select page:",
        ["🏠 Home", "🔍 Search Games", "⚖️ Compare", "📈 Interactive Analysis", 
         "🖼️ Static Panels", "📋 Data Table", "💡 Insights"],
        label_visibility="collapsed"
    )
    
    st.markdown("---")
    st.markdown("### 🎯 Quick Stats")
    
    # Load data
    df = load_data()
    
    st.metric("Total Games", f"{len(df):,}")
    st.metric("Avg Rating", f"{df['positive_rate'].mean():.1f}%")
    st.metric("Avg Price", f"${df['Price'].mean():.2f}")

# Main content based on page selection
if page == "🏠 Home":
    st.markdown('<div class="main-header">🎮 Steam Games Analytics Dashboard</div>', unsafe_allow_html=True)
    
    # Welcome message
    st.info("👋 **Welcome!** Analyze 83,000+ Steam games with this dashboard. Use the sidebar to navigate between pages and apply filters to explore the data.")
    
    # Quick guide in columns
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.markdown("""<div style='text-align: center; padding: 1rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 10px; color: white;'>
        <h3>🔍</h3>
        <p><b>Search Games</b></p>
        <small>Find your desired game</small>
        </div>""", unsafe_allow_html=True)
    with col2:
        st.markdown("""<div style='text-align: center; padding: 1rem; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: 10px; color: white;'>
        <h3>⚖️</h3>
        <p><b>Compare</b></p>
        <small>Compare games side by side</small>
        </div>""", unsafe_allow_html=True)
    with col3:
        st.markdown("""<div style='text-align: center; padding: 1rem; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); border-radius: 10px; color: white;'>
        <h3>📈</h3>
        <p><b>Analyze</b></p>
        <small>Create custom charts</small>
        </div>""", unsafe_allow_html=True)
    with col4:
        st.markdown("""<div style='text-align: center; padding: 1rem; background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); border-radius: 10px; color: white;'>
        <h3>🖼️</h3>
        <p><b>Static Panels</b></p>
        <small>View 24 ready analyses</small>
        </div>""", unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Filters in expander
    with st.expander("🔧 Advanced Filters – Slice the Data However You Like", expanded=True):
        st.caption("💡 Use the filters below to find exactly the games you're looking for.")
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.markdown("**💰 Price Range**")
            price_range = st.slider("Game price ($)", 0, 100, (0, 60), help="Set the minimum and maximum price range")
            st.markdown("**📊 Minimum Review Count**")
            min_reviews = st.number_input("Minimum number of reviews", 0, 100000, 0, step=100, help="Show only games that received at least this many reviews")
        
        with col2:
            st.markdown("**⭐ Minimum Rating**")
            rating_threshold = st.slider("Minimum positive rating (%)", 0, 100, 70, help="Show only games above this threshold")
            st.markdown("**📅 Release Year Range**")
            year_range = st.slider("Which years?", 1997, 2023, (2015, 2023), help="Filter games by release year")
        
        with col3:
            st.markdown("**💻 Platforms**")
            platforms = st.multiselect(
                "Which platforms should they support?",
                ["Windows", "Mac", "Linux"],
                default=["Windows"],
                help="Shows games that run on the selected platforms"
            )
        
        with col4:
            # Get all unique genres
            all_genres = set()
            for genres in df['genre_list'].dropna():
                all_genres.update([g.strip() for g in genres])
            all_genres = sorted(list(all_genres))
            
            st.markdown("**🎮 Game Genres**")
            selected_genres = st.multiselect(
                "Which genres would you like to include?",
                all_genres,
                default=[],
                help="Leave empty to include every genre"
            )
    
    # Apply filters
    filtered_df = df[
        (df['Price'] >= price_range[0]) & 
        (df['Price'] <= price_range[1]) &
        (df['total_reviews'] >= min_reviews) &
        (df['positive_rate'] >= rating_threshold) &
        (df['Release_Year'] >= year_range[0]) &
        (df['Release_Year'] <= year_range[1])
    ]
    
    # Platform filter
    if platforms:
        platform_filter = filtered_df[platforms].any(axis=1)
        filtered_df = filtered_df[platform_filter]
    
    # Genre filter
    if selected_genres:
        genre_filter = filtered_df['genre_list'].apply(
            lambda x: any(genre in selected_genres for genre in x) if isinstance(x, list) else False
        )
        filtered_df = filtered_df[genre_filter]
    
    if len(filtered_df) == 0:
        st.error("❌ No games found! Loosen the filters and try again.")
    else:
        st.success(f"✅ From **{len(df):,}** games, **{len(filtered_df):,}** match your filters")
    
    # Key Metrics
    st.markdown("### 📊 Summary Statistics")
    st.caption("Key metrics for the filtered games")
    col1, col2, col3, col4, col5 = st.columns(5)
    
    with col1:
        st.metric("Filtered Games", f"{len(filtered_df):,}")
    with col2:
        st.metric("Avg Price", f"${filtered_df['Price'].mean():.2f}")
    with col3:
        st.metric("Avg Rating", f"{filtered_df['positive_rate'].mean():.1f}%")
    with col4:
        st.metric("Total Reviews", f"{filtered_df['total_reviews'].sum():,}")
    with col5:
        st.metric("Avg Playtime", f"{filtered_df['Median playtime forever'].mean():.0f}h")
    
    st.markdown("---")
    
    # Interactive Charts
    st.markdown("### 📈 Interactive Charts")
    st.caption("💡 Hover over the charts for tooltips or use zoom controls for deeper insight")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("#### 💰 Price vs Rating Relationship")
        st.caption("Bubble size = review count | Color = rating")
        fig1 = px.scatter(
            filtered_df.sample(min(1000, len(filtered_df))),
            x='Price',
            y='positive_rate',
            size='total_reviews',
            color='positive_rate',
            hover_data=['Name', 'Main_Developer'],
            color_continuous_scale='RdYlGn',
            title="Price vs Rating (bubble size = reviews)"
        )
        fig1.update_layout(height=400)
        st.plotly_chart(fig1, width='stretch')
    
    with col2:
        st.markdown("#### 📅 Games Released Per Year")
        year_counts = filtered_df['Release_Year'].value_counts().sort_index()
        fig2 = px.bar(
            x=year_counts.index,
            y=year_counts.values,
            title="Number of Games Released by Year",
            labels={'x': 'Year', 'y': 'Number of Games'}
        )
        fig2.update_layout(height=400, showlegend=False)
        fig2.update_traces(marker_color='#1b2838')
        st.plotly_chart(fig2, width='stretch')
    
    # Top games
    st.markdown("### 🏆 Top 10 Games by Rating")
    st.caption("Games with the highest positive review share under the current filters")
    top_games = filtered_df.nlargest(10, 'positive_rate')[['Name', 'Main_Developer', 'Price', 'positive_rate', 'total_reviews', 'Median playtime forever']]
    st.dataframe(
        top_games.style.background_gradient(subset=['positive_rate'], cmap='RdYlGn'),
        width='stretch',
        hide_index=True
    )

elif page == "⚖️ Compare":
    st.markdown('<div class="main-header">⚖️ Game Comparison</div>', unsafe_allow_html=True)
    
    st.info("""💡 **How to use** 
    1. Select 2–5 games from the list below
    2. Review the comparison table, radar chart, and side-by-side bar charts
    3. See which game performs better on which metric""")
    
    st.caption("📊 The list shows the top 500 most-reviewed games. Use 'Search Games' for others.")
    
    # Multi-select for games
    game_options = df.nlargest(500, 'total_reviews')['Name'].tolist()
    selected_games = st.multiselect(
        "Select games to compare (choose 2-5):",
        game_options,
        default=[]
    )
    
    if len(selected_games) >= 2:
        compare_df = df[df['Name'].isin(selected_games)]
        
        # Comparison metrics table
        st.markdown("### 📊 Comparison Table")
        comparison_table = compare_df[[
            'Name', 'Main_Developer', 'Price', 'positive_rate', 
            'total_reviews', 'Median playtime forever', 'DLC count', 'Achievements'
        ]].copy()
        
        st.dataframe(
            comparison_table.style.background_gradient(subset=['positive_rate'], cmap='RdYlGn')
            .background_gradient(subset=['total_reviews'], cmap='Blues')
            .background_gradient(subset=['Median playtime forever'], cmap='Oranges'),
            width='stretch',
            hide_index=True
        )
        
        # Radar chart comparison
        if len(selected_games) <= 5:
            st.markdown("### 📡 Radar Chart Comparison")
            
            # Normalize metrics for radar chart (0-100 scale)
            radar_data = []
            categories = ['Rating', 'Price', 'Reviews', 'Playtime', 'DLC', 'Achievements']
            
            for _, game in compare_df.iterrows():
                # Normalize each metric to 0-100 scale
                normalized = [
                    game['positive_rate'],  # Already 0-100
                    min(game['Price'] / 60 * 100, 100),  # $60 = 100%
                    min(game['total_reviews'] / 100000 * 100, 100),  # 100K reviews = 100%
                    min(game['Median playtime forever'] / 1000 * 100, 100),  # 1000h = 100%
                    min(game['DLC count'] / 50 * 100, 100),  # 50 DLC = 100%
                    min(game['Achievements'] / 100 * 100, 100)  # 100 achievements = 100%
                ]
                radar_data.append({
                    'name': game['Name'],
                    'values': normalized
                })
            
            fig = go.Figure()
            
            for game in radar_data:
                fig.add_trace(go.Scatterpolar(
                    r=game['values'],
                    theta=categories,
                    fill='toself',
                    name=game['name']
                ))
            
            fig.update_layout(
                polar=dict(radialaxis=dict(visible=True, range=[0, 100])),
                showlegend=True,
                height=500
            )
            st.plotly_chart(fig, width='stretch')
        
        # Side-by-side bar charts
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("#### 💰 Price Comparison")
            fig1 = px.bar(
                compare_df,
                x='Name',
                y='Price',
                color='Price',
                color_continuous_scale='Viridis',
                text='Price'
            )
            fig1.update_traces(texttemplate='$%{text:.2f}', textposition='outside')
            fig1.update_layout(height=400, showlegend=False)
            st.plotly_chart(fig1, width='stretch')
        
        with col2:
            st.markdown("#### ⭐ Rating Comparison")
            fig2 = px.bar(
                compare_df,
                x='Name',
                y='positive_rate',
                color='positive_rate',
                color_continuous_scale='RdYlGn',
                text='positive_rate'
            )
            fig2.update_traces(texttemplate='%{text:.1f}%', textposition='outside')
            fig2.update_layout(height=400, showlegend=False)
            st.plotly_chart(fig2, width='stretch')
    
    if len(selected_games) >= 2 and len(selected_games) == 1:
        st.warning("⚠️ Please select at least 2 games to compare")
    else:
        st.info("👆 Select games from the dropdown above to start comparing")

elif page == "🔍 Search Games":
    st.markdown('<div class="main-header">🔍 Search & Details</div>', unsafe_allow_html=True)
    
    st.info("💡 **How it works:** Start typing a game name below. Matching games will appear and you can view their details.")
    
    # Search box
    search_term = st.text_input("🎮 Type a game name...", placeholder="e.g., Counter-Strike, GTA, Witcher...")
    
    if search_term:
        # Instant search
        search_results = df[df['Name'].str.contains(search_term, case=False, na=False)]
        
        st.write(f"Found **{len(search_results)}** games matching '{search_term}'")
        
        if len(search_results) > 0:
            # Select game
            selected_game = st.selectbox(
                "Select a game for details:",
                search_results['Name'].tolist()
            )
            
            if selected_game:
                game_data = search_results[search_results['Name'] == selected_game].iloc[0]
                
                # Game detail card
                col1, col2, col3 = st.columns([2, 1, 1])
                
                with col1:
                    st.markdown(f"## {game_data['Name']}")
                    st.markdown(f"**Developer:** {game_data['Developers']}")
                    st.markdown(f"**Release Date:** {game_data['Release date']}")
                
                with col2:
                    st.metric("Price", f"${game_data['Price']:.2f}")
                    st.metric("Rating", f"{game_data['positive_rate']:.1f}%")
                
                with col3:
                    st.metric("Reviews", f"{game_data['total_reviews']:,}")
                    st.metric("Playtime", f"{game_data['Median playtime forever']:.0f}h")
                
                st.markdown("---")
                
                # Detailed stats
                col1, col2 = st.columns(2)
                
                with col1:
                    st.markdown("#### 📊 Review Breakdown")
                    fig = go.Figure(data=[go.Pie(
                        labels=['Positive', 'Negative'],
                        values=[game_data['Positive'], game_data['Negative']],
                        hole=0.4,
                        marker_colors=['#5cb85c', '#d9534f']
                    )])
                    fig.update_layout(height=300)
                    st.plotly_chart(fig, width='stretch')
                
                with col2:
                    st.markdown("#### 🎮 Game Info")
                    st.write(f"**Genres:** {game_data['Genres']}")
                    st.write(f"**DLC Count:** {int(game_data['DLC count'])}")
                    
                    platforms = []
                    if game_data['Windows']: platforms.append("🪟 Windows")
                    if game_data['Mac']: platforms.append("🍎 Mac")
                    if game_data['Linux']: platforms.append("🐧 Linux")
                    st.write(f"**Platforms:** {', '.join(platforms)}")
                    
                    st.write(f"**Achievements:** {int(game_data['Achievements'])}")
                    st.write(f"**Estimated Owners:** {game_data['Estimated owners']}")

elif page == "📈 Interactive Analysis":
    st.markdown('<div class="main-header">📈 Interactive Analysis</div>', unsafe_allow_html=True)
    
    st.info("""💡 **How to use**
    1. Choose an analysis type below
    2. Configure chart type and metrics
    3. Narrow the data with filters
    4. Explore the generated visualization""")
    
    analysis_type = st.selectbox(
        "📊 Select Analysis Type",
        [
            "🎨 Custom Visualization Builder",
            "📊 Distribution Analysis",
            "🔥 Correlation Matrix",
            "📅 Time Series Analysis",
            "🎮 Genre Analysis",
            "🏢 Developer Analysis",
            "💻 Platform Comparison"
        ],
        help="Each analysis provides different insights. Pick one to explore!"
    )
    
    if analysis_type.startswith("🎨"):
        st.markdown("### 🎨 Custom Visualization Builder")
        
        with st.expander("❓ What is this section?", expanded=False):
            st.markdown("""
            Build your own charts from scratch:
            - Choose among **10 chart types**
            - Assign the **metrics** to X and Y axes
            - **Filter** the data to focus your view
            - Use advanced options like **color, size, grouping**
            
            💡 **Tip:** Try different combinations to uncover interesting patterns!
            """)
        
        # Chart type selection
        col1, col2 = st.columns([1, 3])
        
        with col1:
            chart_type = st.selectbox(
                "📊 Select Chart Type",
                ["Scatter Plot", "Line Chart", "Bar Chart", "Pie Chart", "Histogram", 
                 "Box Plot", "Violin Plot", "Heatmap", "Bubble Chart", "Area Chart"],
                help="Each chart suits a different analysis: Scatter=relationship, Bar=comparison, Pie=proportion"
            )
        
        numeric_cols = ['Price', 'positive_rate', 'total_reviews', 'Positive', 'Negative', 
                       'Median playtime forever', 'DLC count', 'Achievements', 'Release_Year', 'platform_count']
        categorical_cols = ['Main_Developer', 'Genres', 'Release_Year']
        
        with col2:
            # Dynamic options based on chart type
            if chart_type in ["Scatter Plot", "Bubble Chart"]:
                col_a, col_b, col_c = st.columns(3)
                with col_a:
                    x_axis = st.selectbox("X-Axis", numeric_cols, index=0)
                with col_b:
                    y_axis = st.selectbox("Y-Axis", numeric_cols, index=1)
                with col_c:
                    color_by = st.selectbox("Color By", numeric_cols, index=1)
                
                if chart_type == "Bubble Chart":
                    size_by = st.selectbox("Bubble Size", numeric_cols, index=2)
            
            elif chart_type in ["Line Chart", "Area Chart"]:
                col_a, col_b = st.columns(2)
                with col_a:
                    x_axis = st.selectbox("X-Axis (Time/Numeric)", numeric_cols, index=8)
                with col_b:
                    y_axis = st.selectbox("Y-Axis (Value)", numeric_cols, index=1)
                group_by = st.selectbox("Group By (Optional)", ["None"] + categorical_cols)
            
            elif chart_type == "Bar Chart":
                orientation = st.radio("Orientation", ["Vertical", "Horizontal"], horizontal=True)
                col_a, col_b = st.columns(2)
                with col_a:
                    category = st.selectbox("Category", categorical_cols + numeric_cols, index=0)
                with col_b:
                    value = st.selectbox("Value", numeric_cols, index=1)
                top_n = st.slider("Show Top N", 5, 50, 20)
            
            elif chart_type == "Pie Chart":
                category = st.selectbox("Category", categorical_cols, index=0)
                value = st.selectbox("Value to Sum", numeric_cols, index=2)
                top_n = st.slider("Show Top N", 5, 20, 10)
            
            elif chart_type == "Histogram":
                metric = st.selectbox("Metric", numeric_cols, index=0)
                bins = st.slider("Number of Bins", 10, 100, 30)
                show_kde = st.checkbox("Show KDE (Density Curve)", value=False)
            
            elif chart_type in ["Box Plot", "Violin Plot"]:
                col_a, col_b = st.columns(2)
                with col_a:
                    metric = st.selectbox("Metric", numeric_cols, index=1)
                with col_b:
                    group_by = st.selectbox("Group By", ["None"] + categorical_cols)
            
            elif chart_type == "Heatmap":
                st.write("Select metrics for correlation heatmap")
                selected_metrics = st.multiselect(
                    "Metrics",
                    numeric_cols,
                    default=numeric_cols[:6]
                )
        
        # Sample size control
        col1, col2 = st.columns([3, 1])
        with col1:
            sample_size = st.slider("Sample Size (for performance)", 100, 10000, 2000)
        with col2:
            use_log = st.checkbox("Log Scale", value=False)
        
        # Apply filters
        with st.expander("🔧 Additional Filters"):
            col1, col2, col3 = st.columns(3)
            with col1:
                price_filter = st.slider("Price Range", 0, 100, (0, 100))
            with col2:
                rating_filter = st.slider("Rating Range", 0, 100, (0, 100))
            with col3:
                year_filter = st.slider("Year Range", 1997, 2023, (1997, 2023))
        
        # Filter data
        plot_df = df[
            (df['Price'] >= price_filter[0]) & (df['Price'] <= price_filter[1]) &
            (df['positive_rate'] >= rating_filter[0]) & (df['positive_rate'] <= rating_filter[1]) &
            (df['Release_Year'] >= year_filter[0]) & (df['Release_Year'] <= year_filter[1])
        ].sample(min(sample_size, len(df)))
        
        st.markdown("---")
        
        # Generate chart based on selection
        try:
            if chart_type == "Scatter Plot":
                fig = px.scatter(
                    plot_df,
                    x=x_axis,
                    y=y_axis,
                    color=color_by,
                    size='total_reviews',
                    hover_data=['Name', 'Main_Developer'],
                    color_continuous_scale='Viridis',
                    title=f"{y_axis} vs {x_axis}",
                    log_x=use_log,
                    log_y=use_log
                )
            
            elif chart_type == "Bubble Chart":
                fig = px.scatter(
                    plot_df,
                    x=x_axis,
                    y=y_axis,
                    size=size_by,
                    color=color_by,
                    hover_data=['Name', 'Main_Developer'],
                    color_continuous_scale='Plasma',
                    title=f"Bubble Chart: {y_axis} vs {x_axis}",
                    log_x=use_log
                )
            
            elif chart_type == "Line Chart":
                if group_by != "None":
                    # Group by category and aggregate
                    line_data = plot_df.groupby([x_axis, group_by])[y_axis].mean().reset_index()
                    fig = px.line(
                        line_data,
                        x=x_axis,
                        y=y_axis,
                        color=group_by,
                        title=f"{y_axis} by {x_axis}",
                        markers=True
                    )
                else:
                    line_data = plot_df.groupby(x_axis)[y_axis].mean().reset_index()
                    fig = px.line(
                        line_data,
                        x=x_axis,
                        y=y_axis,
                        title=f"{y_axis} by {x_axis}",
                        markers=True
                    )
            
            elif chart_type == "Area Chart":
                if group_by != "None":
                    area_data = plot_df.groupby([x_axis, group_by])[y_axis].sum().reset_index()
                    fig = px.area(
                        area_data,
                        x=x_axis,
                        y=y_axis,
                        color=group_by,
                        title=f"{y_axis} by {x_axis}"
                    )
                else:
                    area_data = plot_df.groupby(x_axis)[y_axis].sum().reset_index()
                    fig = px.area(
                        area_data,
                        x=x_axis,
                        y=y_axis,
                        title=f"{y_axis} by {x_axis}"
                    )
            
            elif chart_type == "Bar Chart":
                if category in categorical_cols:
                    # Aggregate categorical data
                    bar_data = plot_df.groupby(category)[value].mean().nlargest(top_n).reset_index()
                    if orientation == "Horizontal":
                        fig = px.bar(bar_data, y=category, x=value, orientation='h',
                                   color=value, color_continuous_scale='Blues',
                                   title=f"Top {top_n} {category} by {value}")
                    else:
                        fig = px.bar(bar_data, x=category, y=value,
                                   color=value, color_continuous_scale='Blues',
                                   title=f"Top {top_n} {category} by {value}")
                else:
                    # Numeric binning
                    if orientation == "Horizontal":
                        fig = px.bar(plot_df.head(top_n), y=category, x=value, orientation='h',
                                   color=value, color_continuous_scale='Viridis')
                    else:
                        fig = px.bar(plot_df.head(top_n), x=category, y=value,
                                   color=value, color_continuous_scale='Viridis')
            
            elif chart_type == "Pie Chart":
                if category == "Genres":
                    # Explode genres
                    genre_data = plot_df.explode('genre_list')
                    pie_data = genre_data.groupby('genre_list')[value].sum().nlargest(top_n).reset_index()
                    pie_data.columns = ['Category', 'Value']
                elif category == "Main_Developer":
                    pie_data = plot_df.groupby(category)[value].sum().nlargest(top_n).reset_index()
                    pie_data.columns = ['Category', 'Value']
                else:
                    pie_data = plot_df.groupby(category)[value].sum().nlargest(top_n).reset_index()
                    pie_data.columns = ['Category', 'Value']
                
                fig = px.pie(
                    pie_data,
                    values='Value',
                    names='Category',
                    title=f"Top {top_n} {category} by {value}",
                    hole=0.3
                )
            
            elif chart_type == "Histogram":
                fig = px.histogram(
                    plot_df,
                    x=metric,
                    nbins=bins,
                    title=f"Distribution of {metric}",
                    color_discrete_sequence=['#1b2838'],
                    marginal="box" if show_kde else None
                )
            
            elif chart_type == "Box Plot":
                if group_by != "None":
                    # Sample groups for better visualization
                    if group_by == "Main_Developer":
                        top_devs = plot_df['Main_Developer'].value_counts().head(10).index
                        plot_df_filtered = plot_df[plot_df['Main_Developer'].isin(top_devs)]
                    else:
                        plot_df_filtered = plot_df
                    
                    fig = px.box(
                        plot_df_filtered,
                        x=group_by,
                        y=metric,
                        color=group_by,
                        title=f"{metric} Distribution by {group_by}"
                    )
                else:
                    fig = px.box(
                        plot_df,
                        y=metric,
                        title=f"{metric} Distribution",
                        color_discrete_sequence=['#667eea']
                    )
            
            elif chart_type == "Violin Plot":
                if group_by != "None":
                    if group_by == "Main_Developer":
                        top_devs = plot_df['Main_Developer'].value_counts().head(10).index
                        plot_df_filtered = plot_df[plot_df['Main_Developer'].isin(top_devs)]
                    else:
                        plot_df_filtered = plot_df
                    
                    fig = px.violin(
                        plot_df_filtered,
                        x=group_by,
                        y=metric,
                        color=group_by,
                        box=True,
                        title=f"{metric} Distribution by {group_by}"
                    )
                else:
                    fig = px.violin(
                        plot_df,
                        y=metric,
                        box=True,
                        title=f"{metric} Distribution",
                        color_discrete_sequence=['#764ba2']
                    )
            
            elif chart_type == "Heatmap":
                if len(selected_metrics) >= 2:
                    corr_matrix = plot_df[selected_metrics].corr()
                    fig = px.imshow(
                        corr_matrix,
                        text_auto='.2f',
                        aspect='auto',
                        color_continuous_scale='RdBu_r',
                        title='Correlation Heatmap'
                    )
                else:
                    st.warning("Please select at least 2 metrics for heatmap")
                    fig = None
            
            if fig:
                fig.update_layout(height=600)
                st.plotly_chart(fig, width='stretch')
                
                # Show statistics
                st.markdown("### 📊 Quick Statistics")
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Filtered Games", f"{len(plot_df):,}")
                with col2:
                    if chart_type in ["Scatter Plot", "Bubble Chart", "Line Chart", "Area Chart"]:
                        st.metric(f"Avg {y_axis}", f"{plot_df[y_axis].mean():.2f}")
                    elif chart_type in ["Bar Chart", "Pie Chart"]:
                        st.metric(f"Total {value}", f"{plot_df[value].sum():,.0f}")
                    elif chart_type in ["Histogram", "Box Plot", "Violin Plot"]:
                        st.metric(f"Avg {metric}", f"{plot_df[metric].mean():.2f}")
                with col3:
                    if chart_type in ["Scatter Plot", "Bubble Chart"]:
                        st.metric(f"Avg {x_axis}", f"{plot_df[x_axis].mean():.2f}")
                    elif chart_type in ["Histogram", "Box Plot", "Violin Plot"]:
                        st.metric(f"Median {metric}", f"{plot_df[metric].median():.2f}")
                with col4:
                    st.metric("Avg Rating", f"{plot_df['positive_rate'].mean():.1f}%")
        
        except Exception as e:
            st.error(f"Error generating chart: {str(e)}")
            st.info("Try adjusting your filters or selecting different metrics")
    
    elif analysis_type.startswith("📊"):
        st.markdown("### 📊 Distribution Analysis")
        st.caption("Visualize how a metric is distributed in the data")
        
        with st.expander("❓ What can I learn?", expanded=False):
            st.markdown("""
            - **Histogram:** Shows where values are concentrated
            - **Box Plot:** Shows median, quartiles, and outliers
            - **Statistics:** Mean, median, standard deviation and more
            """)
        
        metric = st.selectbox(
            "📏 Which metric would you like to analyze?",
            ['Price', 'positive_rate', 'total_reviews', 'Median playtime forever', 'DLC count', 'Achievements'],
            help="Pick a numeric variable to analyze"
        )
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown(f"#### Histogram - {metric}")
            fig1 = px.histogram(
                df,
                x=metric,
                nbins=50,
                title=f"Distribution of {metric}",
                color_discrete_sequence=['#1b2838']
            )
            fig1.update_layout(height=400)
            st.plotly_chart(fig1, width='stretch')
        
        with col2:
            st.markdown(f"#### Box Plot - {metric}")
            fig2 = px.box(
                df,
                y=metric,
                title=f"Box Plot of {metric}",
                color_discrete_sequence=['#667eea']
            )
            fig2.update_layout(height=400)
            st.plotly_chart(fig2, width='stretch')
        
        st.markdown(f"#### 📊 {metric} Statistics")
        col1, col2, col3, col4, col5 = st.columns(5)
        
        with col1:
            st.metric("Mean", f"{df[metric].mean():.2f}")
        with col2:
            st.metric("Median", f"{df[metric].median():.2f}")
        with col3:
            st.metric("Std Dev", f"{df[metric].std():.2f}")
        with col4:
            st.metric("Min", f"{df[metric].min():.2f}")
        with col5:
            st.metric("Max", f"{df[metric].max():.2f}")
    
    elif analysis_type.startswith("🔥"):
        st.markdown("### 🔥 Correlation Matrix")
        st.caption("Shows relationships between metrics")
        
        with st.expander("❓ How to interpret?", expanded=False):
            st.markdown("""
            - **Red (Positive):** Metrics increase together (e.g., Price ↑ DLC count ↑)
            - **Blue (Negative):** One increases while the other decreases
            - **White (Zero):** No relationship
            - **1.00 value:** Perfect positive correlation
            - **-1.00 value:** Perfect negative correlation
            """)
        
        numeric_cols = ['Price', 'positive_rate', 'total_reviews', 'Positive', 'Negative',
                       'Median playtime forever', 'DLC count', 'Achievements', 'platform_count']
        
        corr_matrix = df[numeric_cols].corr()
        
        fig = px.imshow(
            corr_matrix,
            text_auto='.2f',
            aspect='auto',
            color_continuous_scale='RdBu_r',
            title='Correlation Matrix'
        )
        fig.update_layout(height=700)
        st.plotly_chart(fig, width='stretch')
    
    elif analysis_type == "Time Series Analysis":
        st.markdown("### 📅 Time Series Analysis")
        
        # Games per year
        year_data = df.groupby('Release_Year').agg({
            'Name': 'count',
            'Price': 'mean',
            'positive_rate': 'mean',
            'total_reviews': 'sum'
        }).reset_index()
        year_data.columns = ['Year', 'Game_Count', 'Avg_Price', 'Avg_Rating', 'Total_Reviews']
        
        metric = st.selectbox(
            "Select Metric",
            ['Game_Count', 'Avg_Price', 'Avg_Rating', 'Total_Reviews']
        )
        
        fig = px.line(
            year_data,
            x='Year',
            y=metric,
            title=f"{metric} Over Time",
            markers=True
        )
        fig.update_traces(line_color='#1b2838', line_width=3)
        fig.update_layout(height=500)
        st.plotly_chart(fig, width='stretch')
        
        # Show data table
        st.dataframe(year_data, width='stretch', hide_index=True)
    
    elif analysis_type == "Developer Analysis":
        st.markdown("### 🏢 Developer Analysis")
        
        analysis_mode = st.radio(
            "Analysis Mode",
            ["Top Developers", "Developer Comparison", "Developer Portfolio"],
            horizontal=True
        )
        
        if analysis_mode == "Top Developers":
            metric = st.selectbox(
                "Rank By",
                ["Game Count", "Total Reviews", "Average Rating", "Total Revenue (Estimated)"]
            )
            top_n = st.slider("Show Top N Developers", 5, 30, 15)
            
            dev_stats = df.groupby('Main_Developer').agg({
                'Name': 'count',
                'total_reviews': 'sum',
                'positive_rate': 'mean',
                'Price': lambda x: (x * df.loc[x.index, 'total_reviews']).sum()
            }).reset_index()
            dev_stats.columns = ['Developer', 'Game_Count', 'Total_Reviews', 'Avg_Rating', 'Est_Revenue']
            
            if metric == "Game Count":
                dev_stats = dev_stats.nlargest(top_n, 'Game_Count')
                chart_col = 'Game_Count'
            elif metric == "Total Reviews":
                dev_stats = dev_stats.nlargest(top_n, 'Total_Reviews')
                chart_col = 'Total_Reviews'
            elif metric == "Average Rating":
                dev_stats = dev_stats[dev_stats['Game_Count'] >= 3].nlargest(top_n, 'Avg_Rating')
                chart_col = 'Avg_Rating'
            else:
                dev_stats = dev_stats.nlargest(top_n, 'Est_Revenue')
                chart_col = 'Est_Revenue'
            
            col1, col2 = st.columns(2)
            
            with col1:
                fig1 = px.bar(
                    dev_stats,
                    y='Developer',
                    x=chart_col,
                    orientation='h',
                    color=chart_col,
                    color_continuous_scale='Teal',
                    title=f"Top {top_n} Developers by {metric}"
                )
                fig1.update_layout(height=600)
                st.plotly_chart(fig1, width='stretch')
            
            with col2:
                fig2 = px.scatter(
                    dev_stats,
                    x='Total_Reviews',
                    y='Avg_Rating',
                    size='Game_Count',
                    color='Game_Count',
                    hover_data=['Developer'],
                    text='Developer',
                    title="Developer Quality vs Popularity",
                    log_x=True
                )
                fig2.update_traces(textposition='top center')
                fig2.update_layout(height=600)
                st.plotly_chart(fig2, width='stretch')

            st.dataframe(dev_stats, width='stretch', hide_index=True)
        
        elif analysis_mode == "Developer Comparison":
            # Select developers to compare
            top_devs = df['Main_Developer'].value_counts().head(50).index.tolist()
            selected_devs = st.multiselect(
                "Select Developers to Compare (2-5):",
                top_devs,
                default=top_devs[:3]
            )
            
            if len(selected_devs) >= 2:
                compare_data = df[df['Main_Developer'].isin(selected_devs)]
                
                col1, col2 = st.columns(2)
                
                with col1:
                    dev_metrics = compare_data.groupby('Main_Developer').agg({
                        'Name': 'count',
                        'positive_rate': 'mean',
                        'Price': 'mean',
                        'total_reviews': 'mean'
                    }).reset_index()
                    
                    fig1 = px.bar(
                        dev_metrics,
                        x='Main_Developer',
                        y='Name',
                        color='Main_Developer',
                        title="Number of Games",
                        text='Name'
                    )
                    fig1.update_traces(textposition='outside')
                    st.plotly_chart(fig1, width='stretch')
                
                with col2:
                    fig2 = px.bar(
                        dev_metrics,
                        x='Main_Developer',
                        y='positive_rate',
                        color='Main_Developer',
                        title="Average Rating",
                        text='positive_rate'
                    )
                    fig2.update_traces(texttemplate='%{text:.1f}%', textposition='outside')
                    st.plotly_chart(fig2, width='stretch')
                
                # Portfolio distribution
                st.markdown("#### Portfolio Distribution")
                fig3 = px.box(
                    compare_data,
                    x='Main_Developer',
                    y='Price',
                    color='Main_Developer',
                    title="Price Distribution by Developer"
                )
                st.plotly_chart(fig3, width='stretch')
        
        else:  # Developer Portfolio
            developer = st.selectbox(
                "Select Developer",
                df['Main_Developer'].value_counts().head(50).index.tolist()
            )
            
            dev_games = df[df['Main_Developer'] == developer].copy()
            
            st.markdown(f"### 📊 {developer} Portfolio Analysis")
            
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("Total Games", len(dev_games))
            with col2:
                st.metric("Avg Rating", f"{dev_games['positive_rate'].mean():.1f}%")
            with col3:
                st.metric("Total Reviews", f"{dev_games['total_reviews'].sum():,}")
            with col4:
                st.metric("Avg Price", f"${dev_games['Price'].mean():.2f}")
            
            col1, col2 = st.columns(2)
            
            with col1:
                fig1 = px.bar(
                    dev_games.nlargest(10, 'total_reviews'),
                    x='total_reviews',
                    y='Name',
                    orientation='h',
                    color='positive_rate',
                    color_continuous_scale='RdYlGn',
                    title="Top 10 Most Reviewed Games"
                )
                st.plotly_chart(fig1, width='stretch')
            
            with col2:
                fig2 = px.scatter(
                    dev_games,
                    x='Release_Year',
                    y='positive_rate',
                    size='total_reviews',
                    color='Price',
                    hover_data=['Name'],
                    title="Game Performance Over Time"
                )
                st.plotly_chart(fig2, width='stretch')
    
    elif analysis_type == "Platform Comparison":
        st.markdown("### 💻 Platform Comparison Analysis")
        
        # Platform statistics
        platform_data = pd.DataFrame({
            'Platform': ['Windows', 'Mac', 'Linux'],
            'Game_Count': [df['Windows'].sum(), df['Mac'].sum(), df['Linux'].sum()],
            'Avg_Price': [
                df[df['Windows']==1]['Price'].mean(),
                df[df['Mac']==1]['Price'].mean(),
                df[df['Linux']==1]['Price'].mean()
            ],
            'Avg_Rating': [
                df[df['Windows']==1]['positive_rate'].mean(),
                df[df['Mac']==1]['positive_rate'].mean(),
                df[df['Linux']==1]['positive_rate'].mean()
            ]
        })
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            fig1 = px.pie(
                platform_data,
                values='Game_Count',
                names='Platform',
                title='Game Distribution by Platform',
                color_discrete_sequence=['#0078D4', '#A3AAAE', '#FCC624']
            )
            st.plotly_chart(fig1, width='stretch')
        
        with col2:
            fig2 = px.bar(
                platform_data,
                x='Platform',
                y='Avg_Price',
                color='Platform',
                title='Average Price by Platform',
                text='Avg_Price',
                color_discrete_sequence=['#0078D4', '#A3AAAE', '#FCC624']
            )
            fig2.update_traces(texttemplate='$%{text:.2f}', textposition='outside')
            st.plotly_chart(fig2, width='stretch')
        
        with col3:
            fig3 = px.bar(
                platform_data,
                x='Platform',
                y='Avg_Rating',
                color='Platform',
                title='Average Rating by Platform',
                text='Avg_Rating',
                color_discrete_sequence=['#0078D4', '#A3AAAE', '#FCC624']
            )
            fig3.update_traces(texttemplate='%{text:.1f}%', textposition='outside')
            st.plotly_chart(fig3, width='stretch')
        
        # Multi-platform analysis
        st.markdown("### 🔄 Multi-Platform Analysis")
        
        df['platform_category'] = df.apply(
            lambda row: 'All Platforms' if row['platform_count'] == 3
            else 'Windows Only' if row['Windows'] and row['platform_count'] == 1
            else 'Mac Only' if row['Mac'] and row['platform_count'] == 1
            else 'Linux Only' if row['Linux'] and row['platform_count'] == 1
            else 'Multi-Platform (2)', axis=1
        )
        
        multi_stats = df.groupby('platform_category').agg({
            'Name': 'count',
            'positive_rate': 'mean',
            'total_reviews': 'mean',
            'Price': 'mean'
        }).reset_index()
        multi_stats.columns = ['Category', 'Game_Count', 'Avg_Rating', 'Avg_Reviews', 'Avg_Price']
        
        col1, col2 = st.columns(2)
        
        with col1:
            fig4 = px.bar(
                multi_stats,
                x='Category',
                y='Game_Count',
                color='Avg_Rating',
                color_continuous_scale='RdYlGn',
                title='Games by Platform Category',
                text='Game_Count'
            )
            fig4.update_traces(textposition='outside')
            st.plotly_chart(fig4, width='stretch')
        
        with col2:
            fig5 = px.scatter(
                multi_stats,
                x='Avg_Price',
                y='Avg_Rating',
                size='Game_Count',
                color='Category',
                text='Category',
                title='Price vs Rating by Platform Category'
            )
            st.plotly_chart(fig5, width='stretch')
        
        st.dataframe(multi_stats, width='stretch', hide_index=True)
        st.markdown("### 🎮 Genre Analysis")
        
        # Explode genres
        genre_exploded = df.explode('genre_list')
        genre_exploded['genre_list'] = genre_exploded['genre_list'].str.strip()
        
        genre_stats = genre_exploded.groupby('genre_list').agg({
            'Name': 'count',
            'Price': 'mean',
            'positive_rate': 'mean',
            'total_reviews': 'sum'
        }).reset_index()
        genre_stats.columns = ['Genre', 'Game_Count', 'Avg_Price', 'Avg_Rating', 'Total_Reviews']
        genre_stats = genre_stats.sort_values('Game_Count', ascending=False).head(20)
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("#### Top Genres by Game Count")
            fig1 = px.bar(
                genre_stats,
                x='Game_Count',
                y='Genre',
                orientation='h',
                color='Game_Count',
                color_continuous_scale='Blues'
            )
            fig1.update_layout(height=600, showlegend=False)
            st.plotly_chart(fig1, width='stretch')
        
        with col2:
            st.markdown("#### Average Rating by Genre")
            fig2 = px.bar(
                genre_stats.sort_values('Avg_Rating', ascending=False),
                x='Avg_Rating',
                y='Genre',
                orientation='h',
                color='Avg_Rating',
                color_continuous_scale='RdYlGn'
            )
            fig2.update_layout(height=600, showlegend=False)
            st.plotly_chart(fig2, width='stretch')

elif page == "🖼️ Static Panels":
    st.markdown('<div class="main-header">🖼️ Static Analysis Panels</div>', unsafe_allow_html=True)
    
    st.info("""💡 **What's inside?** 
    26 professional analysis panels generated with Octave:
    - 📊 **8 Price Analyses:** Distributions, trends, comparisons
    - ⏱️ **4 Playtime Analyses:** Distributions and insights
    - 📅 **4 Time Series:** Yearly trends, platform and genre evolution
    - 🆓 **2 Free vs Paid:** Score and playtime comparisons
    - 🏆 **4 Performance Metrics:** Top games, developers, success factors
    - 🎯 **4 Studio Comparison:** Indie vs Mid-tier vs AAA analysis""")
    
    # Panel categories
    panel_category = st.selectbox(
        "Select Category",
        ["All Panels", "Price Analysis (6)", "Playtime Analysis (4)", "Time Series (4)", "Free vs Paid (2)", "Performance Metrics (4)", "Studio Comparison (4)"]
    )
    
    # Define all panels (using actual file names)
    panels = {
        "Price Analysis (8)": [
            ("outputs/images/panel1_hexbin_density.png", "Price vs Rating - Hexbin Density"),
            ("outputs/images/panel2_boxplot_by_price.png", "Rating by Price Category - Boxplot"),
            ("outputs/images/panel3_density_distribution.png", "Price Density Distribution"),
            ("outputs/images/panel4_heatmap_2d.png", "Price-Rating Heatmap"),
            ("outputs/images/panel5_smooth_trend.png", "Price Trend - Smooth Line"),
            ("outputs/images/panel6_genre_comparison.png", "Genre Price Comparison"),
            ("outputs/images/genre_pricing_panel.png", "Average Game Price by Genre (Top 20 Genres)")
        ],
        "Playtime Analysis (4)": [
            ("outputs/images/playtime_panel1_density.png", "Playtime Density Distribution"),
            ("outputs/images/playtime_panel2_boxplot.png", "Playtime Boxplot Analysis"),
            ("outputs/images/playtime_panel3_violin_swarm.png", "Playtime Violin & Swarm Plot"),
            ("outputs/images/playtime_panel4_facet_by_genre.png", "Playtime by Genre Facets")
        ],
        "Time Series (4)": [
            ("outputs/images/time_panel1_yearly_trends.png", "Yearly Trends"),
            ("outputs/images/time_panel2_platform_evolution.png", "Platform Evolution"),
            ("outputs/images/time_panel3_monthly_patterns.png", "Monthly Release Patterns"),
            ("outputs/images/time_panel4_genre_trends.png", "Genre Trends Over Time")
        ],
        "Free vs Paid (2)": [
            ("outputs/images/free_vs_paid_panel1_scores.png", "Free vs Paid - Scores"),
            ("outputs/images/free_vs_paid_panel2_playtime.png", "Free vs Paid - Playtime")
        ],
        "Performance Metrics (4)": [
            ("outputs/images/performance_panel1_characteristics.png", "Top 100 vs Average 100"),
            ("outputs/images/performance_panel2_factors.png", "Success Factor Correlations"),
            ("outputs/images/performance_panel3_developers.png", "Developer Popularity vs Quality"),
            ("outputs/images/performance_panel4_top_games.png", "Top 12 Successful Games")
        ],
        "Studio Comparison (4)": [
            ("outputs/images/studio_panel1_pricing.png", "Pricing Strategy: Indie vs Mid-tier vs AAA"),
            ("outputs/images/studio_panel2_quality.png", "Quality & Engagement Metrics"),
            ("outputs/images/studio_panel3_content.png", "Playtime & Content Features"),
            ("outputs/images/studio_panel4_platforms.png", "Platform Support Strategy")
        ]
    }
    
    # Display panels (click the fullscreen icon on each image to enlarge)
    if panel_category == "All Panels":
        for category, panel_list in panels.items():
            st.markdown(f"### {category}")
            cols = st.columns(2)
            for idx, (path, title) in enumerate(panel_list):
                with cols[idx % 2]:
                    if os.path.exists(path):
                        st.image(path, caption=title, width='stretch')
                    else:
                        st.warning(f"⚠️ {title} not found")
            st.markdown("---")
    else:
        if panel_category in panels:
            panel_list = panels[panel_category]
            cols = st.columns(2)
            for idx, (path, title) in enumerate(panel_list):
                with cols[idx % 2]:
                    if os.path.exists(path):
                        st.image(path, caption=title, width='stretch')
                    else:
                        st.warning(f"⚠️ {title} not found")

elif page == "📋 Data Table":
    st.markdown('<div class="main-header">📋 Data Table</div>', unsafe_allow_html=True)
    
    st.info("""💡 **How to use**
    1. 🔍 Enter a game or developer name in the search box
    2. 📊 Choose a sort key (price, rating, reviews, etc.)
    3. ✅ Pick the columns you want to see
    4. 📄 Set rows per page
    5. 💾 Export as CSV if needed""")
    
    # Search and filter
    col1, col2, col3 = st.columns([2, 1, 1])
    
    with col1:
        search = st.text_input("🔍 Search by name or developer", "")
    with col2:
        sort_by = st.selectbox("Sort by", ['Name', 'Price', 'positive_rate', 'total_reviews', 'Release_Year'])
    with col3:
        ascending = st.checkbox("Ascending", value=True)
    
    # Filter data
    display_df = df.copy()
    
    if search:
        mask = display_df['Name'].str.contains(search, case=False, na=False) | \
               display_df['Developers'].str.contains(search, case=False, na=False)
        display_df = display_df[mask]
    
    # Sort
    display_df = display_df.sort_values(sort_by, ascending=ascending)
    
    # Select columns to display
    st.markdown("### 📊 Select Columns to Display")
    all_columns = ['Name', 'Price', 'positive_rate', 'total_reviews', 'Positive', 'Negative',
                   'Main_Developer', 'Release_Year', 'Median playtime forever', 'DLC count',
                   'Achievements', 'Genres', 'Windows', 'Mac', 'Linux']
    
    selected_columns = st.multiselect(
        "Columns",
        all_columns,
        default=['Name', 'Price', 'positive_rate', 'total_reviews', 'Main_Developer', 'Release_Year']
    )
    
    if selected_columns:
        # Pagination
        page_size = st.slider("Rows per page", 10, 100, 25)
        total_pages = len(display_df) // page_size + (1 if len(display_df) % page_size > 0 else 0)
        page_num = st.number_input("Page", 1, max(1, total_pages), 1)
        
        start_idx = (page_num - 1) * page_size
        end_idx = start_idx + page_size
        
        st.info(f"Showing rows {start_idx + 1} to {min(end_idx, len(display_df))} of {len(display_df)} total games")
        
        # Display table
        st.dataframe(
            display_df[selected_columns].iloc[start_idx:end_idx],
            width='stretch',
            hide_index=True
        )
        
        # Export button
        if st.button("📥 Export to CSV"):
            csv = display_df[selected_columns].to_csv(index=False)
            st.download_button(
                label="Download CSV",
                data=csv,
                file_name="filtered_steam_games.csv",
                mime="text/csv"
            )

elif page == "💡 Insights":
    st.markdown('<div class="main-header">💡 Data Insights & Recommendations</div>', unsafe_allow_html=True)
    
    st.info("""💡 **What's inside?** 
    - **📊 Key Insights:** Summary statistics and findings about the dataset
    - **🎯 Success Patterns:** Common traits of the most successful games
    - **🔮 Recommendations:** Find games similar to your selection""")
    
    tab1, tab2, tab3 = st.tabs(["📊 Key Insights", "🎯 Success Patterns", "🔮 Find Similar Games"])
    
    with tab1:
        st.markdown("### 📊 Key Dataset Insights")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("#### 💰 Price Insights")
            free_games = len(df[df['Price'] == 0])
            paid_games = len(df[df['Price'] > 0])
            avg_paid_price = df[df['Price'] > 0]['Price'].mean()
            
            st.write(f"- **{free_games:,}** free games ({free_games/len(df)*100:.1f}%)")
            st.write(f"- **{paid_games:,}** paid games ({paid_games/len(df)*100:.1f}%)")
            st.write(f"- Average paid game price: **${avg_paid_price:.2f}**")
            st.write(f"- Most expensive game: **${df['Price'].max():.2f}**")
            
            st.markdown("#### ⭐ Rating Insights")
            high_rated = len(df[df['positive_rate'] >= 80])
            avg_rating = df['positive_rate'].mean()
            
            st.write(f"- **{high_rated:,}** games with 80%+ rating ({high_rated/len(df)*100:.1f}%)")
            st.write(f"- Average rating: **{avg_rating:.1f}%**")
            st.write(f"- Highest rated: **{df.nlargest(1, 'positive_rate')['Name'].values[0]}** ({df['positive_rate'].max():.1f}%)")
        
        with col2:
            st.markdown("#### 🎮 Platform Insights")
            windows_games = df['Windows'].sum()
            mac_games = df['Mac'].sum()
            linux_games = df['Linux'].sum()
            
            st.write(f"- **{windows_games:,}** Windows games ({windows_games/len(df)*100:.1f}%)")
            st.write(f"- **{mac_games:,}** Mac games ({mac_games/len(df)*100:.1f}%)")
            st.write(f"- **{linux_games:,}** Linux games ({linux_games/len(df)*100:.1f}%)")
            
            multi_platform = df['platform_count'] > 1
            st.write(f"- **{multi_platform.sum():,}** multi-platform games ({multi_platform.sum()/len(df)*100:.1f}%)")
            
            st.markdown("#### 📅 Release Insights")
            recent_games = len(df[df['Release_Year'] >= 2020])
            st.write(f"- **{recent_games:,}** games from 2020+ ({recent_games/len(df)*100:.1f}%)")
            st.write(f"- Peak year: **{df['Release_Year'].mode()[0]:.0f}** with {len(df[df['Release_Year'] == df['Release_Year'].mode()[0]])} games")
    
    with tab2:
        st.markdown("### 🎯 Success Pattern Analysis")
        
        # Define success (top 10% by combined score)
        df['success_score'] = (df['positive_rate'] * 0.4 + 
                               np.log1p(df['total_reviews']) / np.log1p(df['total_reviews'].max()) * 100 * 0.6)
        success_threshold = df['success_score'].quantile(0.9)
        df['is_success'] = df['success_score'] >= success_threshold
        
        successful = df[df['is_success']]
        others = df[~df['is_success']]
        
        st.write(f"Comparing top 10% successful games (**{len(successful)}** games) vs others")
        
        # Comparison metrics
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric(
                "Avg Price",
                f"${successful['Price'].mean():.2f}",
                f"{((successful['Price'].mean() - others['Price'].mean()) / others['Price'].mean() * 100):.1f}%"
            )
        
        with col2:
            st.metric(
                "Avg Rating",
                f"{successful['positive_rate'].mean():.1f}%",
                f"{(successful['positive_rate'].mean() - others['positive_rate'].mean()):.1f}%"
            )
        
        with col3:
            st.metric(
                "Avg DLC Count",
                f"{successful['DLC count'].mean():.1f}",
                f"+{(successful['DLC count'].mean() - others['DLC count'].mean()):.1f}"
            )
        
        with col4:
            st.metric(
                "Multi-Platform %",
                f"{(successful['platform_count'] > 1).sum() / len(successful) * 100:.1f}%",
                f"+{((successful['platform_count'] > 1).sum() / len(successful) - (others['platform_count'] > 1).sum() / len(others)) * 100:.1f}%"
            )
        
        # Success factors visualization
        st.markdown("#### 📊 Success Factor Comparison")
        
        comparison_data = pd.DataFrame({
            'Metric': ['Price ($)', 'Rating (%)', 'Reviews (K)', 'Playtime (h)', 'DLC Count', 'Achievements'],
            'Successful': [
                successful['Price'].mean(),
                successful['positive_rate'].mean(),
                successful['total_reviews'].mean() / 1000,
                successful['Median playtime forever'].mean(),
                successful['DLC count'].mean(),
                successful['Achievements'].mean()
            ],
            'Others': [
                others['Price'].mean(),
                others['positive_rate'].mean(),
                others['total_reviews'].mean() / 1000,
                others['Median playtime forever'].mean(),
                others['DLC count'].mean(),
                others['Achievements'].mean()
            ]
        })
        
        fig = go.Figure()
        fig.add_trace(go.Bar(name='Top 10% Successful', x=comparison_data['Metric'], y=comparison_data['Successful'], marker_color='#5cb85c'))
        fig.add_trace(go.Bar(name='Others', x=comparison_data['Metric'], y=comparison_data['Others'], marker_color='#d9534f'))
        fig.update_layout(barmode='group', height=400)
        st.plotly_chart(fig, width='stretch')
    
    with tab3:
        st.markdown("### 🔮 Find Similar Games")
        
        # Game selector
        reference_game = st.selectbox(
            "Select a game to find similar ones:",
            df.nlargest(500, 'total_reviews')['Name'].tolist()
        )
        
        if reference_game:
            ref_game_data = df[df['Name'] == reference_game].iloc[0]
            
            # Calculate similarity based on multiple factors
            df['similarity'] = (
                1 - abs(df['Price'] - ref_game_data['Price']) / (df['Price'].max() + 1) * 0.2 +
                1 - abs(df['positive_rate'] - ref_game_data['positive_rate']) / 100 * 0.3 +
                1 - abs(df['Median playtime forever'] - ref_game_data['Median playtime forever']) / (df['Median playtime forever'].max() + 1) * 0.2 +
                1 - abs(df['Release_Year'] - ref_game_data['Release_Year']) / 30 * 0.1 +
                (df['platform_count'] == ref_game_data['platform_count']).astype(int) * 0.2
            )
            
            # Find top 10 similar games (excluding the reference game)
            similar_games = df[df['Name'] != reference_game].nlargest(10, 'similarity')
            
            st.markdown(f"#### Games Similar to **{reference_game}**")
            
            st.dataframe(
                similar_games[['Name', 'Main_Developer', 'Price', 'positive_rate', 'total_reviews', 'Median playtime forever']]
                .style.background_gradient(subset=['positive_rate'], cmap='RdYlGn'),
                width='stretch',
                hide_index=True
            )

else:
    st.markdown(f'<div class="main-header">{page}</div>', unsafe_allow_html=True)
    st.info(f"🚧 {page} - Coming soon! Building additional features...")

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: gray;'>
    🎮 Steam Games Analytics Dashboard | Data from HuggingFace | Built with Streamlit & Plotly
</div>
""", unsafe_allow_html=True)
