% STUDIO COMPARISON PANEL 3: PLAYTIME & CONTENT
% Compares playtime and content features between studio types

pkg load statistics;

fprintf('Studio Panel 3: Playtime & Content Analysis...\n');

% Read simplified CSV file
fid = fopen('../../data/processed/studio_panel3_data.csv', 'r');
fgetl(fid);  % Skip header
studio_types = {};
playtimes = [];
dlc_counts = [];
achievements = [];
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && length(line) > 0
        parts = strsplit(line, ',');
        studio_types{end+1} = parts{1};
        playtimes(end+1) = str2double(parts{2});
        dlc_counts(end+1) = str2double(parts{3});
        achievements(end+1) = str2double(parts{4});
    end
end
fclose(fid);
playtimes = playtimes';
dlc_counts = dlc_counts';
achievements = achievements';

% Separate by studio type
indie_playtime = playtimes(strcmp(studio_types, 'Indie'));
midtier_playtime = playtimes(strcmp(studio_types, 'Mid-tier'));
aaa_playtime = playtimes(strcmp(studio_types, 'AAA'));

indie_dlc = dlc_counts(strcmp(studio_types, 'Indie'));
midtier_dlc = dlc_counts(strcmp(studio_types, 'Mid-tier'));
aaa_dlc = dlc_counts(strcmp(studio_types, 'AAA'));

indie_ach = achievements(strcmp(studio_types, 'Indie'));
midtier_ach = achievements(strcmp(studio_types, 'Mid-tier'));
aaa_ach = achievements(strcmp(studio_types, 'AAA'));

fprintf('Indie: playtime=%dh, DLC=%.1f, achievements=%.0f\n', round(mean(indie_playtime)), mean(indie_dlc), mean(indie_ach));
fprintf('Mid-tier: playtime=%dh, DLC=%.1f, achievements=%.0f\n', round(mean(midtier_playtime)), mean(midtier_dlc), mean(midtier_ach));
fprintf('AAA: playtime=%dh, DLC=%.1f, achievements=%.0f\n', round(mean(aaa_playtime)), mean(aaa_dlc), mean(aaa_ach));

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Colors
indie_color = [0.3, 0.7, 0.9];
midtier_color = [0.9, 0.6, 0.2];
aaa_color = [0.5, 0.3, 0.7];
colors_list = {indie_color, midtier_color, aaa_color};

bar_width = 0.6;
positions = [1, 2, 3];
labels = {'Indie', 'Mid-tier', 'AAA'};

% SUBPLOT 1: Average Playtime
subplot(2, 2, 1);
hold on;

avg_playtime = [mean(indie_playtime), mean(midtier_playtime), mean(aaa_playtime)];

for i = 1:3
    x = [positions(i)-bar_width/2, positions(i)+bar_width/2, positions(i)+bar_width/2, positions(i)-bar_width/2];
    y = [0, 0, avg_playtime(i), avg_playtime(i)];
    patch(x, y, colors_list{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    text(positions(i), avg_playtime(i) + 30, sprintf('%d h', round(avg_playtime(i))), ...
         'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, max(avg_playtime) * 1.15]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', labels);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Average Playtime (hours)', 'FontSize', 14, 'FontWeight', 'bold');
title('Player Engagement Time', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 2: Playtime Distribution
subplot(2, 2, 2);
hold on;

all_playtimes = {indie_playtime, midtier_playtime, aaa_playtime};

for i = 1:3
    pt_data = all_playtimes{i};
    pos = i;
    
    % Calculate quartiles
    q1 = quantile(pt_data, 0.25);
    q2 = median(pt_data);
    q3 = quantile(pt_data, 0.75);
    iqr_val = q3 - q1;
    whisker_low = max(min(pt_data), q1 - 1.5*iqr_val);
    whisker_high = min(max(pt_data), q3 + 1.5*iqr_val);
    
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
end

xlim([0.5, 3.5]);
ylim([0, 1500]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', labels);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Playtime (hours)', 'FontSize', 14, 'FontWeight', 'bold');
title('Playtime Distribution', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 3: Average DLC Count
subplot(2, 2, 3);
hold on;

avg_dlc = [mean(indie_dlc), mean(midtier_dlc), mean(aaa_dlc)];

for i = 1:3
    x = [positions(i)-bar_width/2, positions(i)+bar_width/2, positions(i)+bar_width/2, positions(i)-bar_width/2];
    y = [0, 0, avg_dlc(i), avg_dlc(i)];
    patch(x, y, colors_list{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    text(positions(i), avg_dlc(i) + 0.2, sprintf('%.1f', avg_dlc(i)), ...
         'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, max(avg_dlc) * 1.2]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', labels);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Average DLC Count', 'FontSize', 14, 'FontWeight', 'bold');
title('DLC Strategy', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 4: Average Achievements
subplot(2, 2, 4);
hold on;

avg_ach = [mean(indie_ach), mean(midtier_ach), mean(aaa_ach)];

for i = 1:3
    x = [positions(i)-bar_width/2, positions(i)+bar_width/2, positions(i)+bar_width/2, positions(i)-bar_width/2];
    y = [0, 0, avg_ach(i), avg_ach(i)];
    patch(x, y, colors_list{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    text(positions(i), avg_ach(i) + 3, sprintf('%.0f', avg_ach(i)), ...
         'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, max(avg_ach) * 1.15]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', labels);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Average Achievement Count', 'FontSize', 14, 'FontWeight', 'bold');
title('Achievement System', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% Save figure
print('../../outputs/images/studio_panel3_content.png', '-dpng', '-r300');
fprintf('✓ Saved: studio_panel3_content.png\n');
