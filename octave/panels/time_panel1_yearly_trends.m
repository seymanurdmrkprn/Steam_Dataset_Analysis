% TIME PANEL 1: YEARLY GAME RELEASES
% Number of games released per year (consistent style with other panels)

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('../time_panel1_yearly.csv', 1, 0);

release_year = data(:, 1);
game_count = data(:, 2);

fprintf('Time Panel 1: Yearly Game Releases...\n');
fprintf('Years: %d to %d\n', min(release_year), max(release_year));

% Create figure
figure('Position', [100, 100, 1400, 900]);
set(gcf, 'Color', [0.97, 0.97, 0.97]);
hold on;

% Plot as bars (consistent with panel 2 style)
for i = 1:length(release_year)
    fill([release_year(i)-0.4, release_year(i)+0.4, release_year(i)+0.4, release_year(i)-0.4], ...
         [0, 0, game_count(i), game_count(i)], ...
         [0.3, 0.5, 0.9], 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1);
end

% Mark important milestones
milestones = [2003, 2013, 2020];
milestone_labels = {'Steam Launch', 'Early Access', 'COVID-19'};
milestone_colors = {[0.5, 0.5, 0.5], [0.6, 0.4, 0.8], [0.9, 0.5, 0.1]};

for i = 1:length(milestones)
    year = milestones(i);
    plot([year, year], [0, max(game_count)*0.85], '--', ...
         'Color', milestone_colors{i}, 'LineWidth', 2.5);
    text(year, max(game_count)*0.90, milestone_labels{i}, ...
         'FontSize', 11, 'FontWeight', 'bold', 'Color', milestone_colors{i}, ...
         'HorizontalAlignment', 'center');
end

% Add trend line
trend = movmean(game_count, 3);
plot(release_year, trend, '-', 'Color', [0.9, 0.3, 0.3], 'LineWidth', 3.5);

% Title
title('Steam Games Released Per Year (1997-2023)', ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
xlabel('Release Year', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Number of Games Released', 'FontSize', 17, 'FontWeight', 'bold');

% Styling (consistent with price/playtime panels)
grid on;
set(gca, 'GridAlpha', 0.15);
set(gca, 'FontSize', 14);
set(gca, 'Color', [1, 1, 1]);
set(gca, 'LineWidth', 1.5);
xlim([min(release_year)-1, max(release_year)+1]);
ylim([0, max(game_count)*1.05]);

% Save
print -dpng -r300 'time_panel1_yearly_trends.png';
fprintf('✅ Time Panel 1 saved\n');

% Stats
[max_count, max_idx] = max(game_count);
fprintf('\n📊 YEARLY RELEASE TRENDS:\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('• Peak year: %d (%d games)\n', release_year(max_idx), max_count);
fprintf('• Total games: %d\n', sum(game_count));
fprintf('• Average per year: %.0f games\n', mean(game_count));
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
