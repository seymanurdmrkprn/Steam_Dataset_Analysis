% ADVANCED PANEL 21: SCATTER PLOT - Price vs Rating Analysis
% High-quality scatter plot with trend line and correlation analysis

clear all;
close all;
clc;

fprintf('Creating Advanced Scatter Plot Panel (Price vs Rating)...\n');
fprintf('Using preprocessed data for fast loading...\n');

% Load preprocessed data (Price, Rating, Reviews)
data = dlmread('panel21_scatter_data.csv', ',');
prices_valid = data(:, 1);
ratings_valid = data(:, 2);
reviews_valid = data(:, 3);

fprintf('Loaded %d games with >10 reviews\n', length(prices_valid));

% Create figure with 2x2 subplots
fig = figure('Position', [100, 100, 1600, 1100], 'Color', [0.95 0.95 0.95]);
set(fig, 'PaperPositionMode', 'auto');

% PANEL 1: Basic Scatter with Trend Line
subplot(2, 2, 1);
scatter(prices_valid, ratings_valid, 30, ratings_valid, 'filled', ...
        'MarkerEdgeColor', 'black', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.6);
colormap(gca, jet);
cb = colorbar;
ylabel(cb, 'Rating (%)', 'FontSize', 10, 'FontWeight', 'bold');

% Add trend line
hold on;
p = polyfit(prices_valid, ratings_valid, 1);
trend_x = linspace(min(prices_valid), max(prices_valid), 100);
trend_y = polyval(p, trend_x);
plot(trend_x, trend_y, 'r--', 'LineWidth', 3);
hold off;

xlabel('Price ($)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Rating (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Price vs Rating (Color = Rating)', 'FontSize', 14, 'FontWeight', 'bold');
legend(sprintf('Trend: y=%.3fx+%.1f', p(1), p(2)), 'Location', 'southwest');
grid on;
ylim([0 100]);
xlim([0 max(prices_valid)]);

% PANEL 2: Bubble Plot (size = review count)
subplot(2, 2, 2);
bubble_sizes = log10(reviews_valid + 1) * 20;
scatter(prices_valid, ratings_valid, bubble_sizes, ratings_valid, 'filled', ...
        'MarkerEdgeColor', 'black', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.5);
colormap(gca, jet);
cb = colorbar;
ylabel(cb, 'Rating (%)', 'FontSize', 10, 'FontWeight', 'bold');

xlabel('Price ($)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Rating (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Bubble Plot (Size = Review Count)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
ylim([0 100]);
xlim([0 max(prices_valid)]);

% PANEL 3: Density Hexbin Simulation
subplot(2, 2, 3);
% Create 2D histogram
nbins = 40;
[N, Xedges, Yedges] = histcounts2(prices_valid, ratings_valid, nbins);
imagesc(Xedges(1:end-1), Yedges(1:end-1), N');
set(gca, 'YDir', 'normal');
colormap(gca, hot);
cb = colorbar;
ylabel(cb, 'Count', 'FontSize', 10, 'FontWeight', 'bold');

xlabel('Price ($)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Rating (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('2D Density Heatmap', 'FontSize', 14, 'FontWeight', 'bold');

% PANEL 4: Correlation Statistics by Price Range
subplot(2, 2, 4);
axis off;

% Calculate correlations for price ranges
price_ranges = {
    'All Games', [0 inf];
    '$0-10', [0 10];
    '$10-30', [10 30];
    '$30-60', [30 60];
    '$60+', [60 inf]
};

stats_text = 'CORRELATION STATISTICS\n';
stats_text = [stats_text repmat('=', 1, 50) '\n\n'];

for i = 1:size(price_ranges, 1)
    range_name = price_ranges{i, 1};
    range_vals = price_ranges{i, 2};
    
    idx = prices_valid >= range_vals(1) & prices_valid < range_vals(2);
    if sum(idx) > 1
        corr_val = corr(prices_valid(idx), ratings_valid(idx));
        stats_text = sprintf('%s%-12s | Corr: %6.3f | n=%5d\n', ...
                            stats_text, range_name, corr_val, sum(idx));
    end
end

stats_text = [stats_text '\n' repmat('=', 1, 50) '\n\n'];
stats_text = sprintf('%sOverall Statistics:\n', stats_text);
stats_text = sprintf('%s  Total Games: %d\n', stats_text, length(prices_valid));
stats_text = sprintf('%s  Avg Price: $%.2f\n', stats_text, mean(prices_valid));
stats_text = sprintf('%s  Avg Rating: %.1f%%\n', stats_text, mean(ratings_valid));
stats_text = sprintf('%s  Median Price: $%.2f\n', stats_text, median(prices_valid));
stats_text = sprintf('%s  Median Rating: %.1f%%\n', stats_text, median(ratings_valid));
stats_text = sprintf('%s\nCorrelation Interpretation:\n', stats_text);

overall_corr = corr(prices_valid, ratings_valid);
if overall_corr > 0.3
    stats_text = sprintf('%s  Positive correlation detected!\n', stats_text);
    stats_text = sprintf('%s  Higher priced games tend to\n', stats_text);
    stats_text = sprintf('%s  have better ratings.\n', stats_text);
elseif overall_corr < -0.3
    stats_text = sprintf('%s  Negative correlation detected!\n', stats_text);
    stats_text = sprintf('%s  Lower priced games tend to\n', stats_text);
    stats_text = sprintf('%s  have better ratings.\n', stats_text);
else
    stats_text = sprintf('%s  Weak correlation.\n', stats_text);
    stats_text = sprintf('%s  Price and rating are not\n', stats_text);
    stats_text = sprintf('%s  strongly related.\n', stats_text);
end

text(0.1, 0.95, stats_text, 'Units', 'normalized', ...
     'VerticalAlignment', 'top', 'FontSize', 10, ...
     'FontName', 'FixedWidth', 'FontWeight', 'bold', ...
     'BackgroundColor', [1 0.95 0.8], 'EdgeColor', 'black', ...
     'LineWidth', 2, 'Margin', 10);

% Save (sgtitle not available in Octave)
print('advanced_panel21_scatter_price_rating.png', '-dpng', '-r300');
fprintf('Saved: advanced_panel21_scatter_price_rating.png\n');

close all;
fprintf('Panel creation complete!\n');
