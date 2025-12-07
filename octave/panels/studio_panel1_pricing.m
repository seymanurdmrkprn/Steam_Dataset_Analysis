% STUDIO COMPARISON PANEL 1: PRICING STRATEGY
% Compares average pricing between Indie, Mid-tier, and AAA studios

pkg load statistics;

fprintf('Studio Panel 1: Pricing Strategy Comparison...\n');

% Read simplified CSV file
fid = fopen('../../data/processed/studio_panel1_data.csv', 'r');
fgetl(fid);  % Skip header
studio_types = {};
prices = [];
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && length(line) > 0
        parts = strsplit(line, ',');
        studio_types{end+1} = parts{1};
        prices(end+1) = str2double(parts{2});
    end
end
fclose(fid);
prices = prices';

% Calculate averages by studio type
indie_prices = prices(strcmp(studio_types, 'Indie'));
midtier_prices = prices(strcmp(studio_types, 'Mid-tier'));
aaa_prices = prices(strcmp(studio_types, 'AAA'));

avg_indie = mean(indie_prices);
avg_midtier = mean(midtier_prices);
avg_aaa = mean(aaa_prices);

med_indie = median(indie_prices);
med_midtier = median(midtier_prices);
med_aaa = median(aaa_prices);

fprintf('Indie: avg=$%.2f, median=$%.2f, n=%d\n', avg_indie, med_indie, length(indie_prices));
fprintf('Mid-tier: avg=$%.2f, median=$%.2f, n=%d\n', avg_midtier, med_midtier, length(midtier_prices));
fprintf('AAA: avg=$%.2f, median=$%.2f, n=%d\n', avg_aaa, med_aaa, length(aaa_prices));

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Colors for each studio type
indie_color = [0.3, 0.7, 0.9];    % Light blue
midtier_color = [0.9, 0.6, 0.2];  % Orange
aaa_color = [0.5, 0.3, 0.7];      % Purple

% Create 2 subplots: Average Price and Price Distribution
subplot(1, 2, 1);
hold on;

% Average Price Comparison (bar chart)
bar_width = 0.6;
positions = [1, 2, 3];
avg_vals = [avg_indie, avg_midtier, avg_aaa];
colors_list = {indie_color, midtier_color, aaa_color};

for i = 1:3
    x = [positions(i)-bar_width/2, positions(i)+bar_width/2, positions(i)+bar_width/2, positions(i)-bar_width/2];
    y = [0, 0, avg_vals(i), avg_vals(i)];
    patch(x, y, colors_list{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    % Add value labels
    text(positions(i), avg_vals(i) + 1.5, sprintf('$%.2f', avg_vals(i)), ...
         'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, max(avg_vals) * 1.15]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', {'Indie', 'Mid-tier', 'AAA'});
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Average Price ($)', 'FontSize', 14, 'FontWeight', 'bold');
title('Average Game Price by Studio Type', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% Price Distribution (violin-style box plot)
subplot(1, 2, 2);
hold on;

% Box plot data for each studio type
all_prices = {indie_prices, midtier_prices, aaa_prices};
labels = {'Indie', 'Mid-tier', 'AAA'};

for i = 1:3
    prices_data = all_prices{i};
    pos = i;
    
    % Calculate quartiles
    q1 = quantile(prices_data, 0.25);
    q2 = median(prices_data);
    q3 = quantile(prices_data, 0.75);
    iqr_val = q3 - q1;
    whisker_low = max(min(prices_data), q1 - 1.5*iqr_val);
    whisker_high = min(max(prices_data), q3 + 1.5*iqr_val);
    
    % Draw box
    box_x = [pos-0.25, pos+0.25, pos+0.25, pos-0.25, pos-0.25];
    box_y = [q1, q1, q3, q3, q1];
    patch(box_x, box_y, colors_list{i}, 'FaceAlpha', 0.6, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 2);
    
    % Draw median line
    plot([pos-0.25, pos+0.25], [q2, q2], 'k-', 'LineWidth', 3);
    
    % Draw whiskers
    plot([pos, pos], [whisker_low, q1], 'k-', 'LineWidth', 1.5);
    plot([pos, pos], [q3, whisker_high], 'k-', 'LineWidth', 1.5);
    plot([pos-0.1, pos+0.1], [whisker_low, whisker_low], 'k-', 'LineWidth', 1.5);
    plot([pos-0.1, pos+0.1], [whisker_high, whisker_high], 'k-', 'LineWidth', 1.5);
    
    % Add outliers
    outliers_low = prices_data(prices_data < whisker_low);
    outliers_high = prices_data(prices_data > whisker_high);
    if length(outliers_low) > 0
        scatter(ones(size(outliers_low))*pos, outliers_low, 30, colors_list{i}, 'filled', 'MarkerEdgeColor', 'k');
    end
    if length(outliers_high) > 0
        scatter(ones(size(outliers_high))*pos, outliers_high, 30, colors_list{i}, 'filled', 'MarkerEdgeColor', 'k');
    end
end

xlim([0.5, 3.5]);
ylim([0, max(aaa_prices) * 1.05]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', labels);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Price ($)', 'FontSize', 14, 'FontWeight', 'bold');
title('Price Distribution by Studio Type', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% Save figure
print('../../outputs/images/studio_panel1_pricing.png', '-dpng', '-r300');
fprintf('✓ Saved: studio_panel1_pricing.png\n');
