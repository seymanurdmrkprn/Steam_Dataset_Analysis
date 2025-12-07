% Performance Panel 3: Top Developers - Scatter Plot
% Shows developers by popularity (reviews) and quality (rating)

pkg load statistics;

% Read the developer data manually
fid = fopen('C:\Users\seyma\OneDrive\Masaüstü\Scientific Computing\data\processed\performance_panel3_developers.csv', 'r');
header = fgetl(fid);

developers = {};
game_counts = [];
avg_ratings = [];
total_reviews = [];

while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(line)
        parts = strsplit(line, ',');
        if length(parts) >= 4
            developers{end+1} = parts{1};
            game_counts(end+1) = str2double(parts{2});
            avg_ratings(end+1) = str2double(parts{3});
            total_reviews(end+1) = str2double(parts{4});
        end
    end
end
fclose(fid);

% Create figure - larger size for better label spacing
fig = figure('Position', [100, 100, 1600, 1000]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Create scatter plot with bubble sizes
hold on;

% Draw bubbles
for i = 1:length(developers)
    % Bubble size based on game count
    bubble_size = 300 + game_counts(i) * 30;
    
    % Color based on rating (gradient from yellow to dark green)
    rating = avg_ratings(i);
    if rating >= 90
        face_color = [0.1, 0.6, 0.2];  % Dark green for excellent
    elseif rating >= 85
        face_color = [0.3, 0.7, 0.3];  % Medium green
    elseif rating >= 80
        face_color = [0.5, 0.8, 0.4];  % Light green
    else
        face_color = [0.8, 0.8, 0.3];  % Yellow for good
    end
    
    scatter(total_reviews(i), avg_ratings(i), bubble_size, ...
            'MarkerFaceColor', face_color, 'MarkerEdgeColor', [0.2, 0.2, 0.2], ...
            'LineWidth', 2);
end

% Add developer labels with smart positioning to avoid overlap
for i = 1:length(developers)
    % Shorten long names
    dev_name = developers{i};
    if length(dev_name) > 25
        dev_name = [dev_name(1:22) '...'];
    end
    
    % Calculate bubble radius for positioning
    bubble_size = 300 + game_counts(i) * 30;
    bubble_radius = sqrt(bubble_size) * 0.015;  % Approximate radius in data units
    
    % Position label close to bubble edge
    % Use log scale for x positioning
    log_reviews = log10(total_reviews(i));
    x_offset = 10^(log_reviews) * 1.08;  % Just 8% away from bubble
    
    % Vertical offset to avoid overlap
    y_offset = avg_ratings(i);
    if i > 1
        % Check if too close to previous labels
        for j = 1:(i-1)
            if abs(log10(total_reviews(i)) - log10(total_reviews(j))) < 0.4 && ...
               abs(avg_ratings(i) - avg_ratings(j)) < 2.5
                % Shift vertically if too close
                y_offset = y_offset + 1.2;
            end
        end
    end
    
    text(x_offset, y_offset, dev_name, ...
         'FontSize', 12, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
end

hold off;

% Set axis properties
set(gca, 'FontSize', 15, 'FontWeight', 'bold');
set(gca, 'Color', [1, 1, 1]);
set(gca, 'XScale', 'log');  % Log scale for reviews (better visualization)

% Format x-axis labels (log scale with K/M)
xlim([min(total_reviews)*0.6, max(total_reviews)*2]);
ylim([min(avg_ratings)-3, max(avg_ratings)+3]);

% Grid
grid on;
set(gca, 'GridColor', [0.7, 0.7, 0.7]);
set(gca, 'GridAlpha', 0.2);

% Labels and title
xlabel('Total Player Reviews (Popularity)', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('Average Rating % (Quality)', 'FontSize', 18, 'FontWeight', 'bold');
title('Top Game Developers: Popularity vs Quality', 'FontSize', 22, 'FontWeight', 'bold');

% Add combined info box in top-right
annotation('textbox', [0.72, 0.75, 0.01, 0.01], ...
    'String', {'TOP-RIGHT = MOST SUCCESSFUL', '(high quality + popularity)', '', ...
               'Bubble size = Game count', '', ...
               'Colors:', '  • Dark green = 90%+ rating', ...
               '  • Light green = 80-90%', '  • Yellow = 75-80%'}, ...
    'FontSize', 11, 'FontWeight', 'bold', ...
    'EdgeColor', [0.1, 0.6, 0.2], 'BackgroundColor', [0.95, 1, 0.95], ...
    'LineWidth', 2, 'FitBoxToText', 'on');

% Add note at bottom
annotation('textbox', [0.10, 0.01, 0.01, 0.01], ...
    'String', 'Quality = Average positive rating % | Popularity = Total review count', ...
    'FontSize', 10, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.97, 0.97, 0.97], 'FitBoxToText', 'on');

% Adjust layout - more space for labels
set(gca, 'Position', [0.10, 0.12, 0.83, 0.72]);

% Save the figure
print('-dpng', '-r300', 'performance_panel3_developers.png');

disp('Performance Panel 3: Top developers (scatter plot) saved!');
