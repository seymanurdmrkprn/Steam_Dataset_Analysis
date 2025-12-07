% Time Panel 3: Monthly Release Patterns (2014-2023)
% Shows which months are most popular for game releases

pkg load statistics;

% Read the monthly pattern data
% Format: first column is year, columns 2-13 are months 1-12
data = csvread('../time_panel3_monthly.csv', 1, 0);

% Extract years and monthly data
years = data(:, 1);
monthly_data = data(:, 2:13);  % 12 columns for 12 months

% Calculate average games per month across all years
monthly_avg = mean(monthly_data, 1);

disp('Monthly averages:');
disp(monthly_avg);

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Create bar chart
b = bar(monthly_avg, 'FaceColor', [0.2, 0.5, 0.8], 'EdgeColor', [0.1, 0.3, 0.6], 'LineWidth', 1.5);

% Set axis properties
set(gca, 'XTick', 1:12);
set(gca, 'XTickLabel', {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'});
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'Color', [1, 1, 1]);
set(gca, 'Box', 'off');

% Grid
grid on;
set(gca, 'GridColor', [0.7, 0.7, 0.7]);
set(gca, 'GridAlpha', 0.15);
set(gca, 'Layer', 'top');

% Labels and title
xlabel('Month', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Average Games Released per Year', 'FontSize', 17, 'FontWeight', 'bold');
title('Monthly Game Release Patterns (2014-2023)', 'FontSize', 20, 'FontWeight', 'bold');

% Add value labels on top of bars
for i = 1:12
    text(i, monthly_avg(i) + max(monthly_avg)*0.02, sprintf('%.0f', monthly_avg(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 11, 'FontWeight', 'bold');
end

% Find busiest and slowest months
[max_val, busiest_idx] = max(monthly_avg);
[min_val, slowest_idx] = min(monthly_avg);
month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
               'July', 'August', 'September', 'October', 'November', 'December'};

% Add summary text
summary_text = sprintf('Busiest: %s (%.0f games/year) | Slowest: %s (%.0f games/year)', ...
                       month_names{busiest_idx}, max_val, month_names{slowest_idx}, min_val);
annotation('textbox', [0.15, 0.02, 0.7, 0.05], ...
    'String', summary_text, ...
    'FontSize', 13, 'FontWeight', 'bold', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.97, 0.97, 0.97]);

% Adjust layout
set(gca, 'Position', [0.08, 0.12, 0.88, 0.82]);

% Save the figure
print('-dpng', '-r300', 'time_panel3_monthly_patterns.png');

disp('Time Panel 3: Monthly release patterns saved!');
