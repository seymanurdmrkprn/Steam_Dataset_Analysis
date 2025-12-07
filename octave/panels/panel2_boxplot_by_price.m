
% PANEL 2: BOX PLOT (By Price Category)
% Success rate distribution by price category


clear all; close all; clc;


pkg load statistics; % Load statistics package


data = csvread('octave_data.csv', 1, 0); % Load data from CSV


Price = data(:, 1);
PositiveRate = data(:, 2);
PriceCategory = data(:, 3);


fprintf('Panel 2: Box Plot by Price Category...\n');


price_labels = {'Free', '0-5', '5-10', '10-20', '20-30', '30-40', '40-60', '60+'}; % Price categories
categories = 0:7;


figure('Position', [100, 100, 1400, 900]); % Create figure with custom size
set(gcf, 'Color', [0.97, 0.97, 0.97]); % Set background color
hold on;


box_data = [];
positions = [];
colors = [];


color_palette = [
    230, 240, 255;
    200, 220, 255;
    170, 200, 255;
    140, 180, 240;
    110, 160, 225;
    80, 140, 210;
    120, 100, 200;
    100, 80, 180
] / 255; % Gradient blue-purple color palette


median_values = [];
mean_values = [];
count_values = [];


for i = 1:length(categories)
    cat_data = PositiveRate(PriceCategory == categories(i));
    if length(cat_data) > 0
        median_values(i) = median(cat_data);
        mean_values(i) = mean(cat_data);
        count_values(i) = length(cat_data);
        fprintf('  %8s: Median=%.1f%%, Mean=%.1f%%, N=%d\n', ...
                price_labels{i}, median_values(i), mean_values(i), count_values(i));
    else
        median_values(i) = 0;
        mean_values(i) = 0;
        count_values(i) = 0;
    end
end


for i = 1:length(categories)
    if median_values(i) > 0
        % Draw bar for median value
        h = fill([i-0.4, i+0.4, i+0.4, i-0.4], [0, 0, median_values(i), median_values(i)], ...
                 color_palette(i,:), 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 2);
        % Add value label above bar
        text(i, median_values(i) + 3, sprintf('%.1f%%', median_values(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 13, 'FontWeight', 'bold', ...
             'Color', [0.2, 0.2, 0.2]);
        % Add game count below bar
        text(i, 3, sprintf('n=%d', count_values(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
    end
end


% Draw trend line for mean values
valid_idx = find(mean_values > 0);
if length(valid_idx) > 1
    plot(valid_idx, mean_values(valid_idx), '-o', 'Color', [0.9, 0.3, 0.3], ...
         'LineWidth', 3.5, 'MarkerSize', 10, 'MarkerFaceColor', [0.9, 0.3, 0.3]);
end


overall_avg = mean(PositiveRate); % Overall average line
plot([0.5, 8.5], [overall_avg, overall_avg], '--', 'Color', [0.2, 0.7, 0.3], ...
     'LineWidth', 3);


text(8.3, overall_avg + 2, sprintf('Avg: %.1f%%', overall_avg), ...
     'FontSize', 12, 'Color', [0.2, 0.7, 0.3], 'FontWeight', 'bold'); % Annotate average line


title('Median Success Rate by Price Category', ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]); % Title
xlabel('Price Category (USD)', 'FontSize', 17, 'FontWeight', 'bold'); % X label
ylabel('Success Rate (% Positive Reviews)', 'FontSize', 17, 'FontWeight', 'bold'); % Y label


set(gca, 'XTick', 1:8); % X axis ticks
set(gca, 'XTickLabel', price_labels); % X axis labels
set(gca, 'XTickLabelRotation', 45); % Rotate X labels


ylim([0, 100]); % Y axis limits
xlim([0.5, 8.5]); % X axis limits
grid on; % Show grid
set(gca, 'GridAlpha', 0.15); % Grid transparency
set(gca, 'FontSize', 14); % Font size
set(gca, 'Color', [1, 1, 1]); % Axes background color
set(gca, 'LineWidth', 1.5); % Axes line width


print -dpng -r300 'panel2_boxplot_by_price.png'; % Save figure as PNG
fprintf('✅ Panel 2 saved: panel2_boxplot_by_price.png\n');
