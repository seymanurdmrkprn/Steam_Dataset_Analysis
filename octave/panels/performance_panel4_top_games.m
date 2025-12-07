% Performance Panel 4: Top Successful Games
% Shows the most successful games on Steam

pkg load statistics;

% Read the top games data manually
fid = fopen('../../data/processed/performance_panel4_top_games.csv', 'r');
header = fgetl(fid);

game_names = {};
developers = {};
ratings = [];
review_counts = [];
success_scores = [];

while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && ~isempty(line)
        parts = strsplit(line, ',');
        if length(parts) >= 6
            % Parse values
            game = parts{1};
            dev = parts{2};
            rating = str2double(parts{3});
            reviews = str2double(parts{4});
            score = str2double(parts{6});
            
            % Skip if any value is NaN or invalid
            if ~isnan(rating) && ~isnan(reviews) && ~isnan(score) && ...
               rating > 0 && reviews > 0 && score > 0
                game_names{end+1} = game;
                developers{end+1} = dev;
                ratings(end+1) = rating;
                review_counts(end+1) = reviews;
                success_scores(end+1) = score;
            end
        end
    end
end
fclose(fid);

% Take top 12 for better visibility
n_games = min(12, length(game_names));
game_names = game_names(1:n_games);
developers = developers(1:n_games);
ratings = ratings(1:n_games);
review_counts = review_counts(1:n_games);
success_scores = success_scores(1:n_games);

% Reverse for top-to-bottom display
game_names = fliplr(game_names);
developers = fliplr(developers);
ratings = fliplr(ratings);
review_counts = fliplr(review_counts);
success_scores = fliplr(success_scores);

% Create figure - taller for better spacing
fig = figure('Position', [100, 100, 1600, 1100]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Create horizontal bar chart with color gradient based on rating
hold on;
for i = 1:length(success_scores)
    % Color gradient based on rating
    rating = ratings(i);
    if rating >= 95
        bar_color = [0.1, 0.6, 0.2];  % Dark green
    elseif rating >= 90
        bar_color = [0.2, 0.7, 0.3];  % Medium green
    elseif rating >= 85
        bar_color = [0.4, 0.8, 0.4];  % Light green
    else
        bar_color = [0.6, 0.85, 0.5];  % Very light green
    end
    
    % Thinner bars with spacing (0.5 instead of 0.7)
    barh(i, success_scores(i), 0.5, 'FaceColor', bar_color, 'EdgeColor', [0.2, 0.4, 0.2], 'LineWidth', 1.5);
end
hold off;

% Add score labels with rating and review count on the bars
for i = 1:length(success_scores)
    % Format review count
    if review_counts(i) >= 1e6
        review_str = sprintf('%.1fM', review_counts(i)/1e6);
    elseif review_counts(i) >= 1e3
        review_str = sprintf('%.0fK', review_counts(i)/1e3);
    else
        review_str = sprintf('%.0f', review_counts(i));
    end
    
    % Place score at end of bar
    text(success_scores(i) + 0.8, i, sprintf('%.1f', success_scores(i)), ...
         'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
    
    % Place rating and review count inside the bar
    label_x = success_scores(i) * 0.5;
    text(label_x, i, sprintf('%.0f%% | %s', ratings(i), review_str), ...
         'FontSize', 10, 'FontWeight', 'bold', 'Color', [1, 1, 1], ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

% Create simplified game labels with only name and developer
game_labels = {};
for i = 1:length(game_names)
    % Shorten game name if too long
    game_name = game_names{i};
    if length(game_name) > 25
        game_name = [game_name(1:22) '...'];
    end
    
    % Shorten developer name
    dev_name = developers{i};
    if length(dev_name) > 20
        dev_name = [dev_name(1:17) '...'];
    end
    
    game_labels{i} = sprintf('%s  (%s)', game_name, dev_name);
end

% Set axis properties
set(gca, 'YTick', 1:length(game_names));
set(gca, 'YTickLabel', game_labels);
set(gca, 'FontSize', 11, 'FontWeight', 'bold');
set(gca, 'Color', [1, 1, 1]);
set(gca, 'Box', 'off');
xlim([0, 120]);  % Extended to fit legend
ylim([0.3, length(game_names) + 0.7]);  % Proper vertical spacing

% Grid - subtle
grid on;
set(gca, 'GridColor', [0.8, 0.8, 0.8]);
set(gca, 'GridAlpha', 0.3);
set(gca, 'Layer', 'top');

% Labels and title
xlabel('Success Score', 'FontSize', 18, 'FontWeight', 'bold');
title('Top 12 Most Successful Games on Steam', 'FontSize', 22, 'FontWeight', 'bold');

% Manual legend on the right side outside plot
legend_x = 108;
legend_y_start = 10.5;
legend_spacing = 1.8;
box_size = 0.7;

% Dark green box - 95%+
patch([legend_x, legend_x+2.5, legend_x+2.5, legend_x], ...
      [legend_y_start, legend_y_start, legend_y_start+box_size, legend_y_start+box_size], ...
      [0.1, 0.6, 0.2], 'EdgeColor', [0.05, 0.3, 0.1], 'LineWidth', 1.5);
text(legend_x+3, legend_y_start+box_size/2, '95%+ rating', ...
     'FontSize', 11, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');

% Medium green box - 90-95%
patch([legend_x, legend_x+2.5, legend_x+2.5, legend_x], ...
      [legend_y_start-legend_spacing, legend_y_start-legend_spacing, ...
       legend_y_start-legend_spacing+box_size, legend_y_start-legend_spacing+box_size], ...
      [0.2, 0.7, 0.3], 'EdgeColor', [0.1, 0.35, 0.15], 'LineWidth', 1.5);
text(legend_x+3, legend_y_start-legend_spacing+box_size/2, '90-95% rating', ...
     'FontSize', 11, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');

% Light green box - 85-90%
patch([legend_x, legend_x+2.5, legend_x+2.5, legend_x], ...
      [legend_y_start-2*legend_spacing, legend_y_start-2*legend_spacing, ...
       legend_y_start-2*legend_spacing+box_size, legend_y_start-2*legend_spacing+box_size], ...
      [0.4, 0.8, 0.4], 'EdgeColor', [0.2, 0.4, 0.2], 'LineWidth', 1.5);
text(legend_x+3, legend_y_start-2*legend_spacing+box_size/2, '85-90% rating', ...
     'FontSize', 11, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');

% Add note at bottom
annotation('textbox', [0.10, 0.01, 0.01, 0.01], ...
    'String', 'Success Score: Combines rating quality (40%), review volume (40%), and playtime engagement (20%)', ...
    'FontSize', 9, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.97, 0.97, 0.97], 'FitBoxToText', 'on');

% Adjust layout - balanced spacing
set(gca, 'Position', [0.30, 0.10, 0.50, 0.80]);

% Save the figure
print('-dpng', '-r300', '../../outputs/images/performance_panel4_top_games.png');

disp('Performance Panel 4: Top successful games saved!');
