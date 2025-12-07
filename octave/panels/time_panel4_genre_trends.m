% Time Panel 4: Genre Trends Over Time (1997-2023)
% Shows how different game genres evolved over the years

pkg load statistics;

% Read the genre trends data - simple numeric CSV now
data = csvread('../time_panel4_genres.csv', 1, 0);

% Extract data
years = data(:, 1);
genre_counts = data(:, 2:end);

disp(['Loaded ', num2str(length(years)), ' years of data']);
disp(['Data range: ', num2str(min(years)), ' to ', num2str(max(years))]);
disp(['Genre counts size: ', num2str(size(genre_counts))]);
disp(['First few genre totals: ', num2str(sum(genre_counts(1:5, :), 1))]);

% Genre names (top 12 in order: Genre1=Indie, Genre2=Action, etc.)
genre_names = {'Indie', 'Action', 'Adventure', 'Casual', 'Simulation', ...
               'Strategy', 'RPG', 'Free to Play', 'Early Access', 'Sports', ...
               'Massively Multiplayer', 'Racing'};

% Select top 8 most popular genres for clearer visualization
total_counts = sum(genre_counts, 1);
disp(['Total counts per genre: ', num2str(total_counts)]);
[sorted_totals, top_idx] = sort(total_counts, 'descend');
disp(['Top 8 indices: ', num2str(top_idx(1:8))]);
top_8_idx = top_idx(1:8);

selected_genres = genre_counts(:, top_8_idx);
selected_names = genre_names(top_8_idx);

disp(['Selected genres: ', strjoin(selected_names, ', ')]);
disp(['Selected data size: ', num2str(size(selected_genres))]);

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Define colors for genres (distinct colors)
colors = [
    0.2, 0.5, 0.8;   % Blue
    0.9, 0.3, 0.2;   % Red
    0.2, 0.7, 0.3;   % Green
    0.9, 0.6, 0.1;   % Orange
    0.6, 0.2, 0.7;   % Purple
    0.3, 0.8, 0.8;   % Cyan
    0.9, 0.4, 0.6;   % Pink
    0.5, 0.5, 0.2;   % Olive
];

% Plot lines for each genre
hold on;
for i = 1:8
    plot(years, selected_genres(:, i), '-o', 'Color', colors(i, :), ...
         'LineWidth', 2, 'MarkerSize', 3, 'MarkerFaceColor', colors(i, :), ...
         'DisplayName', selected_names{i});
end

% Add key milestones BEFORE hold off
steam_launch = 2003;
indie_boom = 2013;
covid = 2020;

y_max = max(max(selected_genres));

plot([steam_launch, steam_launch], [0, y_max*0.12], '--', 'Color', [0.6, 0.6, 0.6], ...
     'LineWidth', 1.2, 'HandleVisibility', 'off');
text(steam_launch, y_max*0.15, 'Steam Launch', 'FontSize', 10, 'FontWeight', 'bold', ...
     'Color', [0.5, 0.5, 0.5], 'HorizontalAlignment', 'center');

plot([indie_boom, indie_boom], [0, y_max*0.12], '--', 'Color', [0.6, 0.6, 0.6], ...
     'LineWidth', 1.2, 'HandleVisibility', 'off');
text(indie_boom, y_max*0.15, 'Indie Boom', 'FontSize', 10, 'FontWeight', 'bold', ...
     'Color', [0.5, 0.5, 0.5], 'HorizontalAlignment', 'center');

plot([covid, covid], [0, y_max*0.12], '--', 'Color', [0.6, 0.6, 0.6], ...
     'LineWidth', 1.2, 'HandleVisibility', 'off');
text(covid, y_max*0.15, 'COVID-19', 'FontSize', 10, 'FontWeight', 'bold', ...
     'Color', [0.5, 0.5, 0.5], 'HorizontalAlignment', 'center');

hold off;

% Set axis properties
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'Color', [1, 1, 1]);
set(gca, 'Box', 'off');
xlim([min(years)-1, max(years)+1]);

% Grid
grid on;
set(gca, 'GridColor', [0.7, 0.7, 0.7]);
set(gca, 'GridAlpha', 0.15);
set(gca, 'Layer', 'top');

% Labels and title
xlabel('Release Year', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Number of Games', 'FontSize', 17, 'FontWeight', 'bold');
title('Genre Trends Over Time (Top 8 Genres)', 'FontSize', 20, 'FontWeight', 'bold');

% Legend
leg = legend('Location', 'northwest');
set(leg, 'FontSize', 12, 'FontWeight', 'bold', 'Box', 'on');
set(leg, 'Color', [1, 1, 1], 'EdgeColor', [0.3, 0.3, 0.3]);

% Adjust layout
set(gca, 'Position', [0.08, 0.12, 0.88, 0.80]);

% Save the figure
print('-dpng', '-r300', 'time_panel4_genre_trends.png');

disp('Time Panel 4: Genre trends over time saved!');

disp('Time Panel 4: Genre trends over time saved!');
