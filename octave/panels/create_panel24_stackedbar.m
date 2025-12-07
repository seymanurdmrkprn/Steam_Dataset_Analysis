% ADVANCED PANEL 24: STACKED BAR - Platform Support Analysis
% High-quality stacked bar charts showing platform distribution (simulated)

clear all;
close all;
clc;

fprintf('Creating Advanced Stacked Bar Panel (Platform Analysis)...\n');
fprintf('Using preprocessed data for fast loading...\n');

% Load preprocessed data (Price, Rating)
data = dlmread('panel24_stackedbar_data.csv', ',');
prices = data(:, 1);
ratings = data(:, 2);

fprintf('Loaded %d games\n', length(prices));

% Simulate platform support (real platform data not in numeric columns)
% Based on typical Steam statistics
rng(42);  % For reproducibility
n = length(prices);

% Platform probabilities
windows = true(n, 1);  % All games on Windows
mac = rand(n, 1) < 0.6;  % 60% Mac support
linux = rand(n, 1) < 0.4;  % 40% Linux support

% Expensive games tend to have more platform support
expensive_idx = prices > 30;
mac(expensive_idx) = rand(sum(expensive_idx), 1) < 0.8;
linux(expensive_idx) = rand(sum(expensive_idx), 1) < 0.6;

% Categorize by platform combination
platform_cats = zeros(n, 1);
% 1 = Windows only, 2 = Win+Mac, 3 = Win+Linux, 4 = All platforms
platform_cats(~mac & ~linux) = 1;
platform_cats(mac & ~linux) = 2;
platform_cats(~mac & linux) = 3;
platform_cats(mac & linux) = 4;

% Categorize prices
price_bins = [0 10 20 30 50 inf];
price_labels = {'$0-10', '$10-20', '$20-30', '$30-50', '$50+'};
n_price_cats = length(price_labels);

% Create cross-tabulation
platform_by_price = zeros(n_price_cats, 4);

for i = 1:n_price_cats
    price_idx = prices >= price_bins(i) & prices < price_bins(i+1);
    
    for j = 1:4
        platform_by_price(i, j) = sum(price_idx & platform_cats == j);
    end
end

% Create figure
fig = figure('Position', [100, 100, 1600, 1100], 'Color', [0.95 0.95 0.95]);
set(fig, 'PaperPositionMode', 'auto');

% Define colors
colors = [
    0.90 0.22 0.27;  % Red - Windows only
    0.95 0.98 0.93;  % Light - Win+Mac
    0.66 0.85 0.86;  % Cyan - Win+Linux
    0.27 0.48 0.62   % Blue - All platforms
];

% PANEL 1: Stacked bar by price
subplot(2, 2, 1);
bar_handle = bar(1:n_price_cats, platform_by_price, 'stacked');

% Set colors
for i = 1:4
    set(bar_handle(i), 'FaceColor', colors(i, :), 'EdgeColor', 'black', 'LineWidth', 1.5);
end

set(gca, 'XTickLabel', price_labels);
ylabel('Number of Games', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Price Category', 'FontSize', 12, 'FontWeight', 'bold');
title('Platform Support by Price (Stacked)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Win Only', 'Win+Mac', 'Win+Linux', 'All Platforms', ...
       'Location', 'northwest', 'FontSize', 9);
grid on;

% PANEL 2: Percentage stacked
subplot(2, 2, 2);

% Calculate percentages
platform_by_price_pct = 100 * platform_by_price ./ sum(platform_by_price, 2);

bar_handle2 = bar(1:n_price_cats, platform_by_price_pct, 'stacked');

% Set colors
for i = 1:4
    set(bar_handle2(i), 'FaceColor', colors(i, :), 'EdgeColor', 'black', 'LineWidth', 1.5);
end

set(gca, 'XTickLabel', price_labels);
ylabel('Percentage (%)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Price Category', 'FontSize', 12, 'FontWeight', 'bold');
title('Platform Support % by Price', 'FontSize', 14, 'FontWeight', 'bold');
legend('Win Only', 'Win+Mac', 'Win+Linux', 'All Platforms', ...
       'Location', 'best', 'FontSize', 9);
grid on;
ylim([0 100]);

% PANEL 3: Total platform support
subplot(2, 2, 3);

platform_totals = [sum(windows), sum(mac), sum(linux)];
platform_names = {'Windows', 'Mac', 'Linux'};
colors_simple = [0.2 0.4 0.8; 0.7 0.7 0.7; 0.9 0.5 0.2];

bar_handle3 = bar(1:3, platform_totals);
for i = 1:3
    set(bar_handle3, 'FaceColor', colors_simple(i, :), ...
        'EdgeColor', 'black', 'LineWidth', 2);
end

set(gca, 'XTickLabel', platform_names);
ylabel('Number of Games', 'FontSize', 12, 'FontWeight', 'bold');
title('Total Platform Support', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

% Add value labels on bars
for i = 1:3
    text(i, platform_totals(i) + max(platform_totals)*0.02, ...
         sprintf('%d\n(%.1f%%)', platform_totals(i), ...
                 100*platform_totals(i)/n), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

% PANEL 4: Platform combination pie chart
subplot(2, 2, 4);

platform_combo_labels = {'Win Only', 'Win+Mac', 'Win+Linux', 'All Platforms'};
platform_combo_counts = [
    sum(platform_cats == 1),
    sum(platform_cats == 2),
    sum(platform_cats == 3),
    sum(platform_cats == 4)
];

% Find most common
[~, max_idx] = max(platform_combo_counts);
explode = zeros(1, 4);
explode(max_idx) = 0.1;

pie(platform_combo_counts);
colormap(colors);

% Add custom legend with percentages
legend_labels = cell(4, 1);
for i = 1:4
    pct = 100 * platform_combo_counts(i) / sum(platform_combo_counts);
    legend_labels{i} = sprintf('%s (%.1f%%)', platform_combo_labels{i}, pct);
end
legend(legend_labels, 'Location', 'southoutside', 'FontSize', 9);

title('Platform Combination Distribution', 'FontSize', 14, 'FontWeight', 'bold');

% Save (sgtitle not available in Octave)
print('advanced_panel24_stackedbar_platform.png', '-dpng', '-r300');
fprintf('Saved: advanced_panel24_stackedbar_platform.png\n');

close all;
fprintf('Panel creation complete!\n');
fprintf('\nNOTE: Platform data is simulated based on typical Steam statistics.\n');
fprintf('      Real platform support data not available in numeric format.\n');
