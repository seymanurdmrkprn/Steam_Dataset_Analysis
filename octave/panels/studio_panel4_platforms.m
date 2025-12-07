% STUDIO COMPARISON PANEL 4: PLATFORM SUPPORT
% Compares cross-platform support strategies between studio types

pkg load statistics;

fprintf('Studio Panel 4: Platform Support Analysis...\n');

% Read simplified CSV file
fid = fopen('../../data/processed/studio_panel4_data.csv', 'r');
fgetl(fid);  % Skip header
studio_types = {};
windows = [];
mac = [];
linux = [];
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && length(line) > 0
        parts = strsplit(line, ',');
        studio_types{end+1} = parts{1};
        windows(end+1) = str2double(parts{2});
        mac(end+1) = str2double(parts{3});
        linux(end+1) = str2double(parts{4});
    end
end
fclose(fid);
windows = windows';
mac = mac';
linux = linux';

% Calculate percentages by studio type
studios = {'Indie', 'Mid-tier', 'AAA'};
platform_data = zeros(3, 3);  % 3 studios x 3 platforms

for i = 1:3
    studio_mask = strcmp(studio_types, studios{i});
    total_games = sum(studio_mask);
    
    platform_data(i, 1) = sum(windows(studio_mask)) / total_games * 100;  % Windows
    platform_data(i, 2) = sum(mac(studio_mask)) / total_games * 100;      % Mac
    platform_data(i, 3) = sum(linux(studio_mask)) / total_games * 100;    % Linux
    
    fprintf('%s: Win=%.1f%%, Mac=%.1f%%, Linux=%.1f%%\n', ...
            studios{i}, platform_data(i,1), platform_data(i,2), platform_data(i,3));
end

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Colors
indie_color = [0.3, 0.7, 0.9];
midtier_color = [0.9, 0.6, 0.2];
aaa_color = [0.5, 0.3, 0.7];
studio_colors = {indie_color, midtier_color, aaa_color};

platform_colors = [0.2, 0.5, 0.8;   % Windows - Blue
                   0.7, 0.7, 0.7;   % Mac - Gray
                   0.9, 0.5, 0.1];  % Linux - Orange

% SUBPLOT 1: Grouped Bar Chart
subplot(2, 2, 1);
hold on;

bar_width = 0.25;
x_positions = [1, 2, 3];
platform_labels = {'Windows', 'Mac', 'Linux'};

for p = 1:3  % For each platform
    for s = 1:3  % For each studio
        x_pos = x_positions(s) + (p-2) * bar_width;
        x = [x_pos-bar_width/2, x_pos+bar_width/2, x_pos+bar_width/2, x_pos-bar_width/2];
        y = [0, 0, platform_data(s, p), platform_data(s, p)];
        patch(x, y, platform_colors(p,:), 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1);
    end
end

xlim([0.3, 3.7]);
ylim([0, 105]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', studios);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Platform Support (%)', 'FontSize', 14, 'FontWeight', 'bold');
title('Platform Support by Studio Type', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);

% Add legend manually with colored boxes
legend_x = 2.8;
legend_y_start = 90;
legend_spacing = 8;

for p = 1:3
    % Draw colored box
    legend_box_x = [legend_x, legend_x+0.15, legend_x+0.15, legend_x];
    legend_box_y = [legend_y_start - (p-1)*legend_spacing, legend_y_start - (p-1)*legend_spacing, ...
                    legend_y_start - (p-1)*legend_spacing + 4, legend_y_start - (p-1)*legend_spacing + 4];
    patch(legend_box_x, legend_box_y, platform_colors(p,:), 'EdgeColor', 'k', 'LineWidth', 1);
    
    % Add text label
    text(legend_x + 0.2, legend_y_start - (p-1)*legend_spacing + 2, platform_labels{p}, ...
         'FontSize', 10, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
end

grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 2: Stacked Bar (100% view)
subplot(2, 2, 2);
hold on;

% For each studio, show platform exclusivity
exclusive_win = [100-platform_data(1,2), 100-platform_data(2,2), 100-platform_data(3,2)];
multi_platform = [platform_data(1,2), platform_data(2,2), platform_data(3,2)];

bar_width = 0.6;
for i = 1:3
    % Windows-only part (red/orange)
    x = [i-bar_width/2, i+bar_width/2, i+bar_width/2, i-bar_width/2];
    y = [0, 0, exclusive_win(i), exclusive_win(i)];
    patch(x, y, [0.9, 0.4, 0.4], 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    % Multi-platform part (green)
    y2 = [exclusive_win(i), exclusive_win(i), 100, 100];
    patch(x, y2, [0.3, 0.8, 0.4], 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    % Add percentage labels
    text(i, exclusive_win(i)/2, sprintf('%.0f%%\nWin-only', exclusive_win(i)), ...
         'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(i, exclusive_win(i) + multi_platform(i)/2, sprintf('%.0f%%\nMulti', multi_platform(i)), ...
         'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, 100]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', studios);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Distribution (%)', 'FontSize', 14, 'FontWeight', 'bold');
title('Cross-Platform vs Windows-Only', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 3: Mac Support Comparison
subplot(2, 2, 3);
hold on;

mac_support = platform_data(:, 2)';

for i = 1:3
    x = [i-bar_width/2, i+bar_width/2, i+bar_width/2, i-bar_width/2];
    y = [0, 0, mac_support(i), mac_support(i)];
    patch(x, y, studio_colors{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    text(i, mac_support(i) + 4, sprintf('%.1f%%', mac_support(i)), ...
         'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, max(mac_support) * 1.2]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', studios);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Mac Support (%)', 'FontSize', 14, 'FontWeight', 'bold');
title('macOS Platform Support', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 4: Linux Support Comparison
subplot(2, 2, 4);
hold on;

linux_support = platform_data(:, 3)';

for i = 1:3
    x = [i-bar_width/2, i+bar_width/2, i+bar_width/2, i-bar_width/2];
    y = [0, 0, linux_support(i), linux_support(i)];
    patch(x, y, studio_colors{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    text(i, linux_support(i) + 3, sprintf('%.1f%%', linux_support(i)), ...
         'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, max(linux_support) * 1.2]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', studios);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Linux Support (%)', 'FontSize', 14, 'FontWeight', 'bold');
title('Linux Platform Support', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% Save figure
print('../../outputs/images/studio_panel4_platforms.png', '-dpng', '-r300');
fprintf('✓ Saved: studio_panel4_platforms.png\n');
