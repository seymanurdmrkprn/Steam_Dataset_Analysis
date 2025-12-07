% ADVANCED PANEL 23: LINE CHART - Yearly Trends Analysis
% High-quality line charts showing temporal patterns (simulated)

clear all;
close all;
clc;

fprintf('Creating Advanced Line Chart Panel (Yearly Trends)...\n');
fprintf('Using preprocessed data (already sorted by popularity)...\n');

% Load preprocessed data (Price, Rating, Reviews - sorted by reviews DESC)
data = dlmread('panel23_linechart_data.csv', ',');
prices = data(:, 1);
ratings = data(:, 2);
total_reviews = data(:, 3);

fprintf('Loaded %d games\n', length(prices));

% Simulate years based on position (already sorted by popularity)
% Data is pre-sorted: most reviews = most recent
years = zeros(size(prices));
games_per_year = floor(length(prices) / 15);  % 15 years (2010-2024)

for i = 1:length(prices)
    year_offset = min(floor((i-1) / games_per_year), 14);
    years(i) = 2024 - year_offset;
end

% Calculate yearly statistics
unique_years = unique(years);
unique_years = sort(unique_years);

year_counts = zeros(size(unique_years));
year_avg_price = zeros(size(unique_years));
year_avg_rating = zeros(size(unique_years));
year_median_price = zeros(size(unique_years));

for i = 1:length(unique_years)
    yr = unique_years(i);
    yr_idx = years == yr;
    
    year_counts(i) = sum(yr_idx);
    year_avg_price(i) = mean(prices(yr_idx));
    year_median_price(i) = median(prices(yr_idx));
    
    yr_ratings = ratings(yr_idx);
    yr_ratings = yr_ratings(yr_ratings > 0);
    if ~isempty(yr_ratings)
        year_avg_rating(i) = mean(yr_ratings);
    else
        year_avg_rating(i) = 0;
    end
end

% Create figure
fig = figure('Position', [100, 100, 1600, 1100], 'Color', [0.95 0.95 0.95]);
set(fig, 'PaperPositionMode', 'auto');

% PANEL 1: Games released per year
subplot(2, 2, 1);
plot(unique_years, year_counts, '-o', 'LineWidth', 3, 'MarkerSize', 10, ...
     'Color', [0.2 0.4 0.8], 'MarkerFaceColor', [0.2 0.4 0.8]);
fill([unique_years; flipud(unique_years)], ...
     [year_counts; zeros(size(year_counts))], ...
     [0.6 0.7 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
plot(unique_years, year_counts, '-o', 'LineWidth', 3, 'MarkerSize', 10, ...
     'Color', [0.2 0.4 0.8], 'MarkerFaceColor', [0.2 0.4 0.8]);
hold off;

xlabel('Year', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Number of Games', 'FontSize', 12, 'FontWeight', 'bold');
title('Games Released Per Year (Simulated)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([min(unique_years)-1 max(unique_years)+1]);

% PANEL 2: Average price trend
subplot(2, 2, 2);
plot(unique_years, year_avg_price, '-s', 'LineWidth', 3, 'MarkerSize', 10, ...
     'Color', [0.8 0.3 0.2], 'MarkerFaceColor', [0.8 0.3 0.2]);
fill([unique_years; flipud(unique_years)], ...
     [year_avg_price; zeros(size(year_avg_price))], ...
     [0.9 0.6 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
plot(unique_years, year_avg_price, '-s', 'LineWidth', 3, 'MarkerSize', 10, ...
     'Color', [0.8 0.3 0.2], 'MarkerFaceColor', [0.8 0.3 0.2]);
hold off;

xlabel('Year', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Average Price ($)', 'FontSize', 12, 'FontWeight', 'bold');
title('Average Game Price Over Time', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([min(unique_years)-1 max(unique_years)+1]);

% PANEL 3: Average rating trend
subplot(2, 2, 3);
plot(unique_years, year_avg_rating, '-d', 'LineWidth', 3, 'MarkerSize', 10, ...
     'Color', [0.2 0.7 0.3], 'MarkerFaceColor', [0.2 0.7 0.3]);
fill([unique_years; flipud(unique_years)], ...
     [year_avg_rating; zeros(size(year_avg_rating))], ...
     [0.6 0.9 0.6], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
plot(unique_years, year_avg_rating, '-d', 'LineWidth', 3, 'MarkerSize', 10, ...
     'Color', [0.2 0.7 0.3], 'MarkerFaceColor', [0.2 0.7 0.3]);
hold off;

xlabel('Year', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Average Rating (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Average Rating Over Time', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([min(unique_years)-1 max(unique_years)+1]);
ylim([0 100]);

% PANEL 4: Combined trends (triple axis)
subplot(2, 2, 4);

% Normalize all metrics to 0-100 scale for comparison
norm_counts = 100 * (year_counts - min(year_counts)) / (max(year_counts) - min(year_counts));
norm_price = 100 * (year_avg_price - min(year_avg_price)) / (max(year_avg_price) - min(year_avg_price));
norm_rating = year_avg_rating;  % Already 0-100

plot(unique_years, norm_counts, '-o', 'LineWidth', 2.5, 'MarkerSize', 8, ...
     'Color', [0.2 0.4 0.8], 'DisplayName', 'Game Count');
hold on;
plot(unique_years, norm_price, '-s', 'LineWidth', 2.5, 'MarkerSize', 8, ...
     'Color', [0.8 0.3 0.2], 'DisplayName', 'Avg Price');
plot(unique_years, norm_rating, '-d', 'LineWidth', 2.5, 'MarkerSize', 8, ...
     'Color', [0.2 0.7 0.3], 'DisplayName', 'Avg Rating');
hold off;

xlabel('Year', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Normalized Value (0-100)', 'FontSize', 12, 'FontWeight', 'bold');
title('Combined Trends (Normalized)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on;
xlim([min(unique_years)-1 max(unique_years)+1]);
ylim([0 100]);

% Save (sgtitle not available in Octave)
print('advanced_panel23_linechart_trends.png', '-dpng', '-r300');
fprintf('Saved: advanced_panel23_linechart_trends.png\n');

close all;
fprintf('Panel creation complete!\n');
fprintf('\nNOTE: Year data is simulated based on review count.\n');
fprintf('      Higher review count = more recent game (assumption).\n');
