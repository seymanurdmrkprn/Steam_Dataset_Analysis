% PLAYTIME PANEL 2: BAR CHART BY CATEGORY
% Median success rate by playtime category (similar style to price panel 2)

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('playtime_data.csv', 1, 0);

Playtime = data(:, 1);
PositiveRate = data(:, 2);
PlaytimeCategory = data(:, 4);

fprintf('Playtime Panel 2: Bar Chart by Category...\n');

% Category labels
cat_labels = {'<1h', '1-2h\nRefund', '2-5h', '5-10h', '10-20h', '20-50h', '50h+'};
categories = [0, 1, 2, 3, 4, 5, 6];

% Calculate median and count for each category
medians = [];
counts = [];
for i = 1:length(categories)
    mask = PlaytimeCategory == categories(i);
    if sum(mask) > 0
        medians(i) = median(PositiveRate(mask));
        counts(i) = sum(mask);
    else
        medians(i) = 0;
        counts(i) = 0;
    end
end

fprintf('Calculated medians for %d categories\n', length(medians));

% Create figure
figure('Position', [100, 100, 1400, 900]);
set(gcf, 'Color', [0.97, 0.97, 0.97]);

% Create bar chart with gradient colors (blue to purple)
colors = [
    0.3, 0.5, 0.9;  % <1h - light blue
    0.4, 0.4, 0.85; % 1-2h - blue
    0.5, 0.3, 0.8;  % 2-5h - blue-purple
    0.6, 0.25, 0.75; % 5-10h - purple
    0.65, 0.2, 0.7;  % 10-20h - darker purple
    0.7, 0.15, 0.65; % 20-50h - more purple
    0.75, 0.1, 0.6   % 50h+ - deepest purple
];

hold on;

% Draw bars (median values) - one at a time to avoid overlap
for i = 1:length(medians)
    if medians(i) > 0
        % Draw individual bar
        h = fill([i-0.4, i+0.4, i+0.4, i-0.4], [0, 0, medians(i), medians(i)], ...
                 colors(i,:), 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 2);
    end
end

% Add value labels on top of bars
for i = 1:length(medians)
    text(i, medians(i) + 3, sprintf('%.1f%%', medians(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
    text(i, 3, sprintf('n=%d', counts(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
end

% Overall median line
overall_median = median(PositiveRate);
plot([0.5, length(medians)+0.5], [overall_median, overall_median], '--', ...
     'Color', [0.2, 0.7, 0.3], 'LineWidth', 3);
text(length(medians) + 0.3, overall_median + 2, sprintf('Avg: %.1f%%', overall_median), ...
     'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.2, 0.7, 0.3]);

% Highlight refund zone (1-2h category) - better position
plot(2, medians(2) + 8, 'v', 'MarkerSize', 15, 'MarkerFaceColor', [0.9, 0.2, 0.2], 'MarkerEdgeColor', 'none');
text(2, medians(2) + 11, 'Refund Zone', 'FontSize', 12, 'FontWeight', 'bold', ...
     'Color', [0.9, 0.2, 0.2], 'HorizontalAlignment', 'center', 'BackgroundColor', 'white');

% Title and labels
title(sprintf('Median Success Rate by Playtime Category - %s Games', num2str(length(Playtime), '%d')), ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
xlabel('Playtime Category', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Median Success Rate (% Positive Reviews)', 'FontSize', 17, 'FontWeight', 'bold');

% X-axis
set(gca, 'XTick', 1:length(cat_labels));
set(gca, 'XTickLabel', cat_labels);
set(gca, 'FontSize', 14);
set(gca, 'Color', [1, 1, 1]);
set(gca, 'LineWidth', 1.5);

% Grid
grid on;
set(gca, 'GridAlpha', 0.15);
set(gca, 'Layer', 'top');

ylim([0, 100]);
xlim([0.5, length(medians) + 0.5]);

% Save
print -dpng -r300 'playtime_panel2_boxplot.png';
fprintf('✅ Playtime Panel 2 saved: playtime_panel2_boxplot.png\n');

% Analysis
fprintf('\n📊 MEDIAN SUCCESS BY PLAYTIME:\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
for i = 1:length(cat_labels)
    fprintf('%-12s: %.1f%% (n=%d)\n', strrep(cat_labels{i}, '\n', ' '), medians(i), counts(i));
end
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

[max_val, max_idx] = max(medians);
fprintf('✓ Highest success: %s (%.1f%%)\n', strrep(cat_labels{max_idx}, '\n', ' '), max_val);
[min_val, min_idx] = min(medians);
fprintf('✓ Lowest success: %s (%.1f%%)\n', strrep(cat_labels{min_idx}, '\n', ' '), min_val);
