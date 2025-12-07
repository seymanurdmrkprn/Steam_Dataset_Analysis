% PLAYTIME PANEL 3: DENSITY DISTRIBUTION
% Success rate distribution by playtime category (similar style to price panel 3)

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('playtime_data.csv', 1, 0);

Playtime = data(:, 1);
PositiveRate = data(:, 2);
PlaytimeCategory = data(:, 4);

fprintf('Playtime Panel 3: Density Distribution...\n');

% Category labels
cat_labels = {'<1h', '1-2h\nRefund', '2-5h', '5-10h', '10-20h', '20-50h', '50h+'};
categories = [0, 1, 2, 3, 4, 5, 6];

% Create figure
figure('Position', [100, 100, 1400, 900]);
set(gcf, 'Color', [0.97, 0.97, 0.97]);
hold on;

% Colors (blue to purple gradient)
colors = [
    0.3, 0.5, 0.9;
    0.4, 0.4, 0.85;
    0.5, 0.3, 0.8;
    0.6, 0.25, 0.75;
    0.65, 0.2, 0.7;
    0.7, 0.15, 0.65;
    0.75, 0.1, 0.6
];

% Plot density distributions for each category
for i = 1:length(categories)
    cat_data = PositiveRate(PlaytimeCategory == categories(i));
    
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
                         'FaceColor', colors(i,:), 'EdgeColor', [0.3, 0.3, 0.3], ...
                         'LineWidth', 1);
            end
        end
        
        % Add median line
        med = median(cat_data);
        plot([i, i + max_width], [med, med], '-', ...
             'Color', [0.9, 0.2, 0.2], 'LineWidth', 3);
        
        % Add median label
        text(i + max_width + 0.05, med, sprintf('%.0f%%', med), ...
             'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.9, 0.2, 0.2], ...
             'VerticalAlignment', 'middle');
        
        fprintf('  %s: Median=%.1f%%, N=%d\n', strrep(cat_labels{i}, '\n', ' '), med, length(cat_data));
    end
end

% Overall median line
overall_median = median(PositiveRate);
plot([0.5, length(categories)+0.5], [overall_median, overall_median], '--', ...
     'Color', [0.2, 0.7, 0.3], 'LineWidth', 2.5);
text(0.7, overall_median + 3, sprintf('Overall: %.1f%%', overall_median), ...
     'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.2, 0.7, 0.3]);

% Highlight refund zone
refund_data = PositiveRate(PlaytimeCategory == 1);
if length(refund_data) > 0
    plot(2, 95, 'v', 'MarkerSize', 15, 'MarkerFaceColor', [0.9, 0.2, 0.2], 'MarkerEdgeColor', 'none');
    text(2, 98, 'Refund Zone', 'FontSize', 11, 'FontWeight', 'bold', ...
         'Color', [0.9, 0.2, 0.2], 'HorizontalAlignment', 'center');
end

% Title and labels
title('Success Rate Distribution by Playtime Category', ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
xlabel('Playtime Category', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Success Rate (% Positive Reviews)', 'FontSize', 17, 'FontWeight', 'bold');

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
xlim([0.5, length(categories) + 0.5]);

% Save
print -dpng -r300 'playtime_panel3_violin_swarm.png';
fprintf('✅ Playtime Panel 3 saved: playtime_panel3_violin_swarm.png\n');

% Analysis
fprintf('\n📊 DISTRIBUTION ANALYSIS:\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('• Overall median: %.1f%%\n', overall_median);
fprintf('• Distributions show engagement patterns\n');
fprintf('• Refund zone (1-2h) has distinct behavior\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
