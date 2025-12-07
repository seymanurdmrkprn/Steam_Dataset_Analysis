% Free vs Paid Panel 2: Playtime Comparison
% Compares median playtime between free and paid games

pkg load statistics;

% Read the playtime comparison data manually (text with categories)
fid = fopen('../../data/processed/free_vs_paid_playtime.csv', 'r');
header = fgetl(fid);  % Skip header

free_playtime = [];
paid_playtime = [];

while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(line)
        parts = strsplit(line, ',');
        if length(parts) == 2
            playtime = str2double(parts{1});
            category = strtrim(parts{2});
            
            if strcmp(category, 'Free')
                free_playtime = [free_playtime; playtime];
            elseif strcmp(category, 'Paid')
                paid_playtime = [paid_playtime; playtime];
            end
        end
    end
end
fclose(fid);

disp(['Free games: ', num2str(length(free_playtime))]);
disp(['Paid games: ', num2str(length(paid_playtime))]);

% Calculate statistics
stats = [mean(free_playtime), mean(paid_playtime); 
         median(free_playtime), median(paid_playtime)];

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Create manual bars with different colors for Free vs Paid
hold on;

bar_width = 0.35;
free_color = [0.3, 0.7, 0.9];   % Light blue for Free
paid_color = [0.9, 0.5, 0.3];   % Orange for Paid

% Free games bars (position 1)
x_free = [1-bar_width/2, 1+bar_width/2, 1+bar_width/2, 1-bar_width/2];
y_mean_free = [0, 0, stats(1,1), stats(1,1)];
patch(x_free, y_mean_free, free_color, 'EdgeColor', [0.2, 0.5, 0.7], 'LineWidth', 1.5);

y_median_free = [0, 0, stats(2,1), stats(2,1)];
x_free2 = x_free + bar_width;
patch(x_free2, y_median_free, free_color*0.75, 'EdgeColor', [0.2, 0.5, 0.7], 'LineWidth', 1.5);

% Paid games bars (position 2)
x_paid = [2-bar_width/2, 2+bar_width/2, 2+bar_width/2, 2-bar_width/2];
y_mean_paid = [0, 0, stats(1,2), stats(1,2)];
patch(x_paid, y_mean_paid, paid_color, 'EdgeColor', [0.7, 0.3, 0.1], 'LineWidth', 1.5);

y_median_paid = [0, 0, stats(2,2), stats(2,2)];
x_paid2 = x_paid + bar_width;
patch(x_paid2, y_median_paid, paid_color*0.75, 'EdgeColor', [0.7, 0.3, 0.1], 'LineWidth', 1.5);

% Add value labels on top of bars
text(1, stats(1,1) + 10, sprintf('%.0fh', stats(1,1)), ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
     'FontSize', 12, 'FontWeight', 'bold');
text(1+bar_width, stats(2,1) + 5, sprintf('%.0fh', stats(2,1)), ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
     'FontSize', 12, 'FontWeight', 'bold');
text(2, stats(1,2) + 15, sprintf('%.0fh', stats(1,2)), ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
     'FontSize', 12, 'FontWeight', 'bold');
text(2+bar_width, stats(2,2) + 10, sprintf('%.0fh', stats(2,2)), ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
     'FontSize', 12, 'FontWeight', 'bold');

% Set axis properties
xlim([0.3, 2.7]);
set(gca, 'XTick', [1.175, 2.175], 'XTickLabel', {'Free Games', 'Paid Games'});
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'Color', [1, 1, 1]);
set(gca, 'Box', 'off');

% Grid
grid on;
set(gca, 'GridColor', [0.7, 0.7, 0.7]);
set(gca, 'GridAlpha', 0.15);
set(gca, 'Layer', 'top');

% Labels and title
ylabel('Playtime (hours)', 'FontSize', 17, 'FontWeight', 'bold');
title('Playtime Comparison: Free vs Paid Games', 'FontSize', 20, 'FontWeight', 'bold');

% Get max value for scaling
max_val = max([stats(1,1), stats(1,2)]);

% Adjust ylim to give more space for legend
ylim([0, max_val * 1.15]);

% Manual legend positioned inside plot at top right with aesthetic split colors
legend_x = 2.35;
legend_y = max_val * 1.05;
legend_spacing = max_val * 0.07;
box_width = 0.12;
box_height = max_val * 0.035;

% Mean - split colored rectangle (blue left, orange right)
patch([legend_x-box_width, legend_x-box_width/2, legend_x-box_width/2, legend_x-box_width], ...
      [legend_y, legend_y, legend_y+box_height, legend_y+box_height], ...
      free_color, 'EdgeColor', [0.2, 0.5, 0.7], 'LineWidth', 1.5);
patch([legend_x-box_width/2, legend_x, legend_x, legend_x-box_width/2], ...
      [legend_y, legend_y, legend_y+box_height, legend_y+box_height], ...
      paid_color, 'EdgeColor', [0.7, 0.3, 0.1], 'LineWidth', 1.5);
text(legend_x+0.08, legend_y+box_height/2, 'Mean', 'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');

% Median - split colored rectangle (darker blue left, darker orange right)
patch([legend_x-box_width, legend_x-box_width/2, legend_x-box_width/2, legend_x-box_width], ...
      [legend_y-legend_spacing, legend_y-legend_spacing, legend_y-legend_spacing+box_height, legend_y-legend_spacing+box_height], ...
      free_color*0.75, 'EdgeColor', [0.2, 0.5, 0.7], 'LineWidth', 1.5);
patch([legend_x-box_width/2, legend_x, legend_x, legend_x-box_width/2], ...
      [legend_y-legend_spacing, legend_y-legend_spacing, legend_y-legend_spacing+box_height, legend_y-legend_spacing+box_height], ...
      paid_color*0.75, 'EdgeColor', [0.7, 0.3, 0.1], 'LineWidth', 1.5);
text(legend_x+0.08, legend_y-legend_spacing+box_height/2, 'Median', 'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');

% Add summary
summary_text = sprintf('Paid games are played 3.6x longer on average (%.0fh vs %.0fh)', ...
                       mean(paid_playtime), mean(free_playtime));
annotation('textbox', [0.15, 0.02, 0.7, 0.05], ...
    'String', summary_text, ...
    'FontSize', 12, 'FontWeight', 'bold', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.97, 0.97, 0.97]);

% Adjust layout
set(gca, 'Position', [0.08, 0.12, 0.88, 0.82]);

% Save the figure
print('-dpng', '-r300', '../../outputs/images/free_vs_paid_panel2_playtime.png');

disp('Free vs Paid Panel 2: Playtime comparison saved!');
