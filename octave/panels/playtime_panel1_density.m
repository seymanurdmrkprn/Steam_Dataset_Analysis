% PLAYTIME PANEL 1: SCATTER WITH AVERAGES
% Playtime-Success relationship (similar style to price panel 1)

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('playtime_data.csv', 1, 0);

Playtime = data(:, 1);
PositiveRate = data(:, 2);
LogPlaytime = data(:, 3);

fprintf('Playtime Panel 1: Playtime vs Success Rate visualization...\n');
fprintf('Total data points: %d\n', length(Playtime));

% Filter to 0-2000 hours
mask = Playtime <= 2000;
Playtime_filt = Playtime(mask);
PositiveRate_filt = PositiveRate(mask);
LogPlaytime_filt = LogPlaytime(mask);

fprintf('Filtered to 0-2000h: %d games (%.1f%%)\n', sum(mask), 100*sum(mask)/length(Playtime));

% Create figure
figure('Position', [100, 100, 1400, 900]);

% Background color (light gray - consistent with price panels)
set(gcf, 'Color', [0.97, 0.97, 0.97]);

% Scatter plot - same colors as price panel 1
scatter(LogPlaytime_filt, PositiveRate_filt, 25, [0.2, 0.4, 0.75], 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none');
hold on;

% Average lines (same style as price panel 1)
mean_playtime = mean(LogPlaytime_filt);
mean_rate = mean(PositiveRate_filt);

% Vertical line (average playtime) - orange
plot([mean_playtime, mean_playtime], [0, 105], '--', 'Color', [0.9, 0.5, 0.1], 'LineWidth', 2.5, ...
     'DisplayName', sprintf('Avg. Playtime: %.0fh', 10^mean_playtime - 1));

% Horizontal line (average success) - purple
plot([min(LogPlaytime_filt), max(LogPlaytime_filt)], [mean_rate, mean_rate], '--', 'Color', [0.6, 0.2, 0.7], 'LineWidth', 2.5, ...
     'DisplayName', sprintf('Avg. Score: %.1f%%', mean_rate));

% Refund zone marker (2h) - green
refund_log = log10(2 + 1);
plot([refund_log, refund_log], [0, 105], '--', 'Color', [0.2, 0.7, 0.2], 'LineWidth', 2.5, ...
     'DisplayName', '2h Refund Zone');

% Correlation
correlation = corr(LogPlaytime_filt, PositiveRate_filt);

% Title and labels (consistent style)
title(sprintf('Playtime vs Success Rate - %s Steam Games (0-2000h)', num2str(length(Playtime_filt), '%d')), ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
xlabel('Median Playtime (log scale)', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Success Rate (% Positive Reviews)', 'FontSize', 17, 'FontWeight', 'bold');

set(gca, 'FontSize', 14);
set(gca, 'Color', [1, 1, 1]);  % White plot background
set(gca, 'LineWidth', 1.5);

% Grid - aesthetic
grid on;
set(gca, 'GridAlpha', 0.15);
set(gca, 'GridLineStyle', '-');

ylim([0, 105]);

% Format x-axis to show hours
x_min = min(LogPlaytime_filt);
x_max = max(LogPlaytime_filt);
tick_positions = linspace(x_min, x_max, 8);
tick_labels = {};
for i = 1:length(tick_positions)
    hours = round(10^tick_positions(i) - 1);
    if hours < 1
        tick_labels{i} = '<1h';
    else
        tick_labels{i} = sprintf('%dh', hours);
    end
end
set(gca, 'XTick', tick_positions);
set(gca, 'XTickLabel', tick_labels);

% Legend - same style as price panel 1
leg = legend('Location', 'southeast', 'FontSize', 13);
set(leg, 'Box', 'on');
set(leg, 'EdgeColor', [0.7, 0.7, 0.7]);

% Save
print -dpng -r300 'playtime_panel1_density.png';
fprintf('✅ Playtime Panel 1 saved: playtime_panel1_density.png\n');
fprintf('   Correlation: %.3f\n', correlation);

% Analysis results
fprintf('\n📊 ANALYSIS RESULTS:\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('• Average playtime: %.0f hours\n', 10^mean_playtime - 1);
fprintf('• Average success: %.1f%%\n', mean_rate);
fprintf('• Correlation: %.3f\n', correlation);
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

if correlation > 0.10
    fprintf('✓ Playtime increases → Success increases (weak positive)\n');
elseif correlation < -0.10
    fprintf('✓ Playtime increases → Success decreases (negative)\n');
else
    fprintf('✓ Very weak relationship between playtime and success\n');
end

% Save
print -dpng -r300 'playtime_panel1_density.png';
fprintf('✅ Playtime Panel 1 saved\n');
fprintf('   Correlation: %.3f\n', r);
