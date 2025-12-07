% PANEL 3: DENSITY DISTRIBUTION
% Success rate distribution by price category

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('octave_data.csv', 1, 0);

Price = data(:, 1);
PositiveRate = data(:, 2);
PriceCategory = data(:, 3);

fprintf('Panel 3: Density Distribution by Price Category...\n');

% Price categories
price_labels = {'Free', '0-5', '5-10', '10-20', '20-30', '30-40', '40-60', '60+'};
categories = 0:7;

figure('Position', [100, 100, 1400, 900]);
set(gcf, 'Color', [0.97, 0.97, 0.97]);
hold on;

% Color palette (matching other panels)
color_palette = [
    230, 240, 255;
    200, 220, 255;
    170, 200, 255;
    140, 180, 240;
    110, 160, 225;
    80, 140, 210;
    120, 100, 200;
    100, 80, 180
] / 255;

% Draw density curves for each category
for i = 1:length(categories)
    cat_data = PositiveRate(PriceCategory == categories(i));
    
    if length(cat_data) > 10
        % Create histogram
        [counts, edges] = hist(cat_data, 15);
        centers = (edges(1:end-1) + edges(2:end)) / 2;
        
        % Normalize counts to width
        max_width = 0.35;
        widths = (counts / max(counts)) * max_width;
        
        % Draw horizontal bars for each bin
        for j = 1:length(centers)
            if counts(j) > 0
                y_bottom = centers(j) - (edges(2) - edges(1)) / 2;
                y_top = centers(j) + (edges(2) - edges(1)) / 2;
                
                % Draw rectangle
                rectangle('Position', [i, y_bottom, widths(j), y_top - y_bottom], ...
                         'FaceColor', color_palette(i,:), 'EdgeColor', [0.3, 0.3, 0.3], ...
                         'LineWidth', 1);
            end
        end
        
        % Add median line
        median_val = median(cat_data);
        plot([i, i + max_width], [median_val, median_val], '-', ...
             'Color', [0.9, 0.2, 0.2], 'LineWidth', 3);
        
        % Add median label
        text(i + max_width + 0.05, median_val, sprintf('%.0f%%', median_val), ...
             'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.9, 0.2, 0.2], ...
             'VerticalAlignment', 'middle');
        
        fprintf('  %8s: Median=%.1f%%, N=%d\n', price_labels{i}, median_val, length(cat_data));
    end
end

% Title and labels
title('Success Rate Distribution Shape by Price Category', ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
xlabel('Price Category (USD)', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Success Rate (% Positive Reviews)', 'FontSize', 17, 'FontWeight', 'bold');

% X axis
set(gca, 'XTick', 1:8);
set(gca, 'XTickLabel', price_labels);
set(gca, 'XTickLabelRotation', 45);

ylim([0, 105]);
xlim([0.5, 8.5]);
grid on;
set(gca, 'GridAlpha', 0.15);
set(gca, 'FontSize', 14);
set(gca, 'Color', [1, 1, 1]);
set(gca, 'LineWidth', 1.5);

% Save
print -dpng -r300 'panel3_density_distribution.png';
fprintf('✅ Panel 3 saved: panel3_density_distribution.png\n');
