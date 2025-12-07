% TIME PANEL 2: PLATFORM EVOLUTION
% Line chart showing platform support growth over years

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('../time_panel2_platforms.csv', 1, 0);

release_year = data(:, 1);
total_games = data(:, 2);
windows_count = data(:, 3);
mac_count = data(:, 4);
linux_count = data(:, 5);

fprintf('Time Panel 2: Platform Evolution...\n');
fprintf('Years: %d to %d\n', min(release_year), max(release_year));

% Filter to 2000 onwards for clarity
mask = release_year >= 2000;
release_year = release_year(mask);
windows_count = windows_count(mask);
mac_count = mac_count(mask);
linux_count = linux_count(mask);

% Create figure
figure('Position', [100, 100, 1400, 900]);
set(gcf, 'Color', [0.97, 0.97, 0.97]);
hold on;

% Plot lines for each platform (thinner lines)
plot(release_year, windows_count, '-o', 'Color', [0.2, 0.4, 0.8], ...
     'LineWidth', 2.5, 'MarkerSize', 5, 'MarkerFaceColor', [0.2, 0.4, 0.8]);
plot(release_year, mac_count, '-s', 'Color', [0.2, 0.7, 0.3], ...
     'LineWidth', 2.5, 'MarkerSize', 5, 'MarkerFaceColor', [0.2, 0.7, 0.3]);
plot(release_year, linux_count, '-^', 'Color', [0.9, 0.5, 0.1], ...
     'LineWidth', 2.5, 'MarkerSize', 5, 'MarkerFaceColor', [0.9, 0.5, 0.1]);

% Mark important platform milestones (with explanations)
mac_launch = 2010;
linux_launch = 2013;
proton = 2018;

plot([mac_launch, mac_launch], [0, max(windows_count)*0.80], '--', ...
     'Color', [0.2, 0.7, 0.3], 'LineWidth', 2);
text(mac_launch, max(windows_count)*0.85, {'Mac Steam', 'Client Launch'}, 'FontSize', 10, ...
     'FontWeight', 'bold', 'Color', [0.2, 0.7, 0.3], 'HorizontalAlignment', 'center');

plot([linux_launch, linux_launch], [0, max(windows_count)*0.80], '--', ...
     'Color', [0.9, 0.5, 0.1], 'LineWidth', 2);
text(linux_launch, max(windows_count)*0.85, {'Linux Steam', 'Client Launch'}, 'FontSize', 10, ...
     'FontWeight', 'bold', 'Color', [0.9, 0.5, 0.1], 'HorizontalAlignment', 'center');

plot([proton, proton], [0, max(windows_count)*0.80], '--', ...
     'Color', [0.6, 0.4, 0.8], 'LineWidth', 2);
text(proton, max(windows_count)*0.85, {'Proton/Steam Play', '(Win→Linux)'}, 'FontSize', 10, ...
     'FontWeight', 'bold', 'Color', [0.6, 0.4, 0.8], 'HorizontalAlignment', 'center');

% Legend
legend({'Windows', 'Mac', 'Linux'}, 'Location', 'northwest', ...
       'FontSize', 13, 'Box', 'on', 'EdgeColor', [0.7, 0.7, 0.7]);

% Title and labels
title('Platform Support Growth (Number of Games)', ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
xlabel('Release Year', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Number of Games with Platform Support', 'FontSize', 17, 'FontWeight', 'bold');

% Styling
grid on;
set(gca, 'GridAlpha', 0.15);
set(gca, 'FontSize', 14);
set(gca, 'Color', [1, 1, 1]);
set(gca, 'LineWidth', 1.5);
xlim([min(release_year)-1, max(release_year)+1]);
ylim([0, max(windows_count)*1.05]);

% Save
print -dpng -r300 'time_panel2_platform_evolution.png';
fprintf('✅ Time Panel 2 saved\n');

% Stats
fprintf('\n🖥️  PLATFORM SUPPORT (2023):\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('• Windows: %d games (%.1f%%)\n', windows_count(end), windows_count(end)/total_games(end)*100);
fprintf('• Mac: %d games (%.1f%%)\n', mac_count(end), mac_count(end)/total_games(end)*100);
fprintf('• Linux: %d games (%.1f%%)\n', linux_count(end), linux_count(end)/total_games(end)*100);
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
