% Performance Panel 2: Success Correlation Factors
% Shows which factors correlate most with high game ratings

pkg load statistics;

% Read the correlation factors data manually
fid = fopen('../performance_panel2_factors.csv', 'r');
header = fgetl(fid);

factors = {};
correlations = [];

while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(line)
        parts = strsplit(line, ',');
        if length(parts) == 2
            factors{end+1} = parts{1};
            correlations(end+1) = str2double(parts{2});
        end
    end
end
fclose(fid);

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Create horizontal bar chart with color coding
hold on;
for i = 1:length(correlations)
    if correlations(i) >= 0
        % Positive correlation - Green shades
        color = [0.2, 0.7, 0.3];
    else
        % Negative correlation - Red shades
        color = [0.9, 0.3, 0.3];
    end
    barh(i, correlations(i), 'FaceColor', color, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
end
hold off;

% Add value labels
for i = 1:length(correlations)
    val = correlations(i);
    if val >= 0
        text(val + 1.5, i, sprintf('%.1f%%', val), ...
             'FontSize', 13, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
    else
        text(val - 1.5, i, sprintf('%.1f%%', val), ...
             'FontSize', 13, 'FontWeight', 'bold', 'VerticalAlignment', 'middle', ...
             'HorizontalAlignment', 'right');
    end
end

% Set axis properties
set(gca, 'YTick', 1:length(factors));
set(gca, 'YTickLabel', factors);
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'Color', [1, 1, 1]);
set(gca, 'Box', 'off');

% Set x-axis limits to accommodate both positive and negative
max_abs = max(abs(correlations));
xlim([-max_abs - 5, max_abs + 5]);

% Add vertical line at zero
line([0, 0], [0, length(correlations) + 1], 'Color', [0.3, 0.3, 0.3], 'LineWidth', 2, 'LineStyle', '--');

% Grid
grid on;
set(gca, 'GridColor', [0.7, 0.7, 0.7]);
set(gca, 'GridAlpha', 0.15);

% Labels and title
xlabel('Correlation with High Ratings (%)', 'FontSize', 17, 'FontWeight', 'bold');
title('Success Factors: What Correlates with High Game Ratings?', 'FontSize', 20, 'FontWeight', 'bold');

% Add interpretation text box
annotation('textbox', [0.68, 0.82, 0.25, 0.10], ...
    'String', {'Higher review count,', 'newer release year,', 'and higher price', 'correlate with success'}, ...
    'FontSize', 12, 'FontWeight', 'bold', ...
    'EdgeColor', [0.2, 0.7, 0.3], 'LineWidth', 2, ...
    'BackgroundColor', [0.95, 1, 0.95], ...
    'FitBoxToText', 'on');

% Add legend
annotation('textbox', [0.20, 0.08, 0.35, 0.04], ...
    'String', 'Green = Positive | Red = Negative', ...
    'FontSize', 12, 'FontWeight', 'bold', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.97, 0.97, 0.97]);

% Add note
annotation('textbox', [0.20, 0.03, 0.6, 0.04], ...
    'String', 'Spearman correlation: measures relationship strength between factors and ratings', ...
    'FontSize', 10, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.97, 0.97, 0.97]);

% Adjust layout
set(gca, 'Position', [0.20, 0.16, 0.73, 0.78]);

% Save the figure
print('-dpng', '-r300', 'performance_panel2_factors.png');

disp('Performance Panel 2: Success correlation factors saved!');
