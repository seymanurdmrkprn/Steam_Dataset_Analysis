% Genre Pricing Analysis Panel
% Shows average prices for top 20 most popular genres

pkg load statistics;

fprintf('Loading genre pricing data...\n');

% Read genre pricing data
fid = fopen('../../data/processed/genre_pricing.csv', 'r');
header = fgetl(fid);

genres = {};
game_counts = [];
avg_prices = [];
median_prices = [];

while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(line)
        parts = strsplit(line, ',');
        if length(parts) >= 5
            genres{end+1} = parts{1};
            game_counts(end+1) = str2double(parts{2});
            avg_prices(end+1) = str2double(parts{3});
            median_prices(end+1) = str2double(parts{4});
        end
    end
end
fclose(fid);

fprintf('Loaded %d genres\n', length(genres));

% Create figure
fig = figure('Position', [100, 100, 1600, 1000]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Reverse order for top-to-bottom display
genres = fliplr(genres);
avg_prices = fliplr(avg_prices);
median_prices = fliplr(median_prices);
game_counts = fliplr(game_counts);

% Adjust bar positions to prevent overlap
bar_spacing = 1.75; % Increase spacing between bars

hold on;

for i = 1:length(genres)
    % Adjusted bar position with increased spacing
    bar_position = i * bar_spacing;

    % Color based on price range
    price = avg_prices(i);
    
    if price >= 15
        bar_color = [0.8, 0.2, 0.2];  % Red for expensive
    elseif price >= 10
        bar_color = [0.9, 0.6, 0.2];  % Orange for mid-high
    elseif price >= 7
        bar_color = [0.9, 0.8, 0.3];  % Yellow for mid
    elseif price >= 5
        bar_color = [0.5, 0.8, 0.5];  % Light green for low-mid
    elseif price >= 1
        bar_color = [0.3, 0.7, 0.3];  % Green for low
    else
        bar_color = [0.2, 0.5, 0.8];  % Blue for very low/free
    end
    
    barh(bar_position, price, 0.7, 'FaceColor', bar_color, 'EdgeColor', [0.2, 0.2, 0.2], 'LineWidth', 1.5);
end

hold off;

% Update price labels and game count positions
for i = 1:length(genres)
    bar_position = i * bar_spacing;

    % Price label at end of bar
    text(avg_prices(i) + 0.5, bar_position, sprintf('$%.2f', avg_prices(i)), ...
         'FontSize', 11, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
    
    % Game count inside bar (if bar is wide enough)
    if avg_prices(i) > 3
        if game_counts(i) >= 1000
            count_str = sprintf('%dk', round(game_counts(i)/1000));
        else
            count_str = sprintf('%d', game_counts(i));
        end
        
        text(avg_prices(i) * 0.5, bar_position, count_str, ...
             'FontSize', 9, 'FontWeight', 'bold', 'Color', [1, 1, 1], ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
end

% Shorten genre names for better display
display_genres = genres;
for i = 1:length(genres)
    if length(genres{i}) > 18
        display_genres{i} = [genres{i}(1:15) '...'];
    end
end

% Set axis properties
set(gca, 'YTick', (1:length(genres)) * bar_spacing);
set(gca, 'YTickLabel', display_genres);
set(gca, 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'Color', [1, 1, 1]);
set(gca, 'Box', 'off');
xlim([0, max(avg_prices) + 5]);
ylim([0.3, length(genres) * bar_spacing + 0.7]);

% Grid
grid on;
set(gca, 'GridColor', [0.8, 0.8, 0.8]);
set(gca, 'GridAlpha', 0.3);
set(gca, 'Layer', 'top');

% Labels and title
xlabel('Average Price (USD)', 'FontSize', 18, 'FontWeight', 'bold');
title('Average Game Price by Genre (Top 20 Genres)', 'FontSize', 22, 'FontWeight', 'bold');

% Legend - manual color boxes
legend_x = max(avg_prices) * 0.75; % Move legend further to the right
legend_y_start = 18; % Move legend higher
legend_spacing = 1.2;
box_width = 1.5;
box_height = 0.6;

% Price ranges
price_ranges = {
    '$15+', [0.8, 0.2, 0.2];
    '$10-15', [0.9, 0.6, 0.2];
    '$7-10', [0.9, 0.8, 0.3];
    '$5-7', [0.5, 0.8, 0.5];
    '$1-5', [0.3, 0.7, 0.3];
    '<$1', [0.2, 0.5, 0.8]
};

for i = 1:size(price_ranges, 1)
    y_pos = legend_y_start - (i-1) * legend_spacing;
    
    % Draw colored box
    patch([legend_x, legend_x+box_width, legend_x+box_width, legend_x], ...
          [y_pos, y_pos, y_pos+box_height, y_pos+box_height], ...
          price_ranges{i, 2}, 'EdgeColor', [0.2, 0.2, 0.2], 'LineWidth', 1.5);
    
    % Add label
    text(legend_x + box_width + 0.3, y_pos + box_height/2, price_ranges{i, 1}, ...
         'FontSize', 10, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
end

% Add note about game counts
annotation('textbox', [0.10, 0.01, 0.01, 0.01], ...
    'String', 'Numbers inside bars show game count (e.g., "56k" = 56,000 games) | Top genres by total game count', ...
    'FontSize', 9, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.97, 0.97, 0.97], 'FitBoxToText', 'on');

% Adjust layout
set(gca, 'Position', [0.20, 0.10, 0.70, 0.80]);

% Save the figure
fprintf('Saving figure...\n');
print('-dpng', '-r600', '../../outputs/images/genre_pricing_panel.png'); % Save figure with higher DPI

fprintf('✅ Genre Pricing Panel saved!\n');
fprintf('   Top 3 Most Expensive: Video Production ($%.2f), Animation & Modeling ($%.2f), Game Development ($%.2f)\n', ...
    avg_prices(end), avg_prices(end-1), avg_prices(end-2));
fprintf('   Top 3 Cheapest: Free to Play ($%.2f), Massively Multiplayer ($%.2f), Casual ($%.2f)\n', ...
    avg_prices(1), avg_prices(2), avg_prices(3));
