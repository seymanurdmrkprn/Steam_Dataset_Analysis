
% PANEL 4: HEATMAP (2D Histogram)
% Price-Success Rate combination frequencies


clear all; close all; clc;


pkg load statistics; % Load statistics package


data = csvread('octave_data.csv', 1, 0); % Load data from CSV


Price = data(:, 1);
PositiveRate = data(:, 2);


fprintf('Panel 4: 2D Heatmap visualization...\n');


price_edges = [0, 0.01, 5, 10, 20, 30, 40, 60, 80]; % Price bin edges
price_labels = {'Free', '0-5', '5-10', '10-20', '20-30', '30-40', '40-60', '60-80'}; % Price bin labels


rate_edges = [0, 50, 70, 85, 95, 100]; % Success rate bin edges
rate_labels = {'0-50%', '50-70%', '70-85%', '85-95%', '95-100%'}; % Success rate bin labels


n_price_bins = length(price_edges) - 1;
n_rate_bins = length(rate_edges) - 1;
heatmap_matrix = zeros(n_rate_bins, n_price_bins); % Initialize 2D histogram matrix


for i = 1:n_price_bins
    for j = 1:n_rate_bins
        price_mask = (Price >= price_edges(i)) & (Price < price_edges(i+1));
        rate_mask = (PositiveRate >= rate_edges(j)) & (PositiveRate < rate_edges(j+1));
        heatmap_matrix(j, i) = sum(price_mask & rate_mask); % Count games in each cell
    end
end


for j = 1:n_rate_bins
    if rate_edges(j+1) == 100
        price_mask = Price >= price_edges(end-1);
        rate_mask = (PositiveRate >= rate_edges(j)) & (PositiveRate <= 100);
        heatmap_matrix(j, end) = sum(price_mask & rate_mask); % Include upper bound for last bin
    end
end


fprintf('Heatmap matrix created (%dx%d)\n', n_rate_bins, n_price_bins);


figure('Position', [100, 100, 1400, 900]); % Create figure with custom size
set(gcf, 'Color', [0.97, 0.97, 0.97]); % Set background color


imagesc(heatmap_matrix); % Draw heatmap
colormap('hot');
cbar = colorbar;
set(get(cbar, 'ylabel'), 'String', 'Number of Games', 'FontSize', 14, 'FontWeight', 'bold');


title('Game Distribution: Price vs Success Rate', ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]); % Title
xlabel('Price Category (USD)', 'FontSize', 17, 'FontWeight', 'bold'); % X label
ylabel('Success Rate Range', 'FontSize', 17, 'FontWeight', 'bold'); % Y label


set(gca, 'XTick', 1:n_price_bins); % X axis ticks
set(gca, 'XTickLabel', price_labels); % X axis labels
set(gca, 'XTickLabelRotation', 45); % Rotate X labels


set(gca, 'YTick', 1:n_rate_bins); % Y axis ticks
set(gca, 'YTickLabel', rate_labels); % Y axis labels
set(gca, 'FontSize', 14); % Font size
set(gca, 'LineWidth', 1.5); % Axes line width


hold on;
for i = 1:n_price_bins
    for j = 1:n_rate_bins
        count = heatmap_matrix(j, i);
        if count > 0
            % Add subtle semi-transparent background to cell
            patch([i-0.18, i+0.18, i+0.18, i-0.18], ...
                  [j-0.12, j-0.12, j+0.12, j+0.12], ...
                  [1, 1, 1], 'EdgeColor', 'none', 'FaceAlpha', 0.75);
            % Add cell count text
            text(i, j, sprintf('%d', round(count)), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'Color', [0, 0, 0], ...
                 'FontSize', 11, ...
                 'FontWeight', 'bold');
        end
    end
end


[max_val, max_idx] = max(heatmap_matrix(:)); % Find most common combination
[max_j, max_i] = ind2sub(size(heatmap_matrix), max_idx);


fprintf('\n✅ Panel 4 saved: panel4_heatmap_2d.png\n');
fprintf('   Most common: %s price, %s success (%d games)\n', ...
        price_labels{max_i}, rate_labels{max_j}, round(max_val));


print -dpng -r300 'panel4_heatmap_2d.png'; % Save figure as PNG
