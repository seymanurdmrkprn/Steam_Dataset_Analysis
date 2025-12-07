
% PANEL 5: SMOOTH TREND LINE
% Non-linear relationship trend


clear all; close all; clc;


pkg load statistics; % Load statistics package


data = csvread('octave_data.csv', 1, 0); % Load data from CSV


Price = data(:, 1);
PositiveRate = data(:, 2);


fprintf('Panel 5: Smooth Trend Analysis...\n');


figure('Position', [100, 100, 1400, 900]); % Create figure with custom size
set(gcf, 'Color', [0.97, 0.97, 0.97]); % Set background color


scatter(Price, PositiveRate, 8, [0.3, 0.5, 0.8], 'filled', 'MarkerFaceAlpha', 0.3); % Scatter plot
hold on;


n_points = 100;
price_smooth = linspace(min(Price), 80, n_points);  % 0-80 range for smooth trend
rate_smooth = zeros(size(price_smooth));
rate_std = zeros(size(price_smooth));


window_size = length(Price) * 0.08;  % 8% window size for smoothing


for i = 1:n_points
    % For each smooth point, find nearest values
    distances = abs(Price - price_smooth(i));
    [~, sorted_idx] = sort(distances);
    window_idx = sorted_idx(1:min(round(window_size), length(Price)));
    rate_smooth(i) = mean(PositiveRate(window_idx));
    rate_std(i) = std(PositiveRate(window_idx));
end


plot(price_smooth, rate_smooth, '-', 'Color', [0.9, 0.3, 0.3], 'LineWidth', 4); % Draw smooth trend line


upper_bound = rate_smooth + rate_std;
lower_bound = rate_smooth - rate_std; % Confidence interval (±1 std)


fill([price_smooth, fliplr(price_smooth)], ...
     [upper_bound, fliplr(lower_bound)], ...
     [0.9, 0.3, 0.3], 'FaceAlpha', 0.15, 'EdgeColor', 'none'); % Fill confidence area


SS_res = sum((PositiveRate - interp1(price_smooth, rate_smooth, Price, 'linear', 'extrap')).^2); % Residual sum of squares
SS_tot = sum((PositiveRate - mean(PositiveRate)).^2); % Total sum of squares
R_squared = 1 - SS_res / SS_tot; % R² for LOESS


correlation = corr(Price, PositiveRate); % Correlation


title('Price-Success Relationship with Smooth Trend', ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]); % Title
xlabel('Price (USD)', 'FontSize', 17, 'FontWeight', 'bold'); % X label
ylabel('Success Rate (% Positive Reviews)', 'FontSize', 17, 'FontWeight', 'bold'); % Y label

grid on;
set(gca, 'GridAlpha', 0.15);
set(gca, 'FontSize', 14);
set(gca, 'Color', [1, 1, 1]);
set(gca, 'LineWidth', 1.5);
xlim([0, 80]);
ylim([0, 105]);


text_str = sprintf('Correlation: %.3f\nR²: %.3f\nN: %s', ...
                   correlation, R_squared, num2str(length(Price)));
text(65, 15, text_str, ...
     'FontSize', 13, 'BackgroundColor', [1, 1, 0.95], ...
     'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5, 'FontWeight', 'bold'); % Add statistics annotation


print -dpng -r300 'panel5_smooth_trend.png'; % Save figure as PNG
fprintf('✅ Panel 5 saved: panel5_smooth_trend.png\n');
fprintf('   Correlation: %.3f\n', correlation);
fprintf('   R²: %.3f\n', R_squared);


[max_rate, max_idx] = max(rate_smooth); % Find optimal price
optimal_price = price_smooth(max_idx);
fprintf('   Peak success at: $%.2f (%.1f%% success rate)\n', optimal_price, max_rate);
