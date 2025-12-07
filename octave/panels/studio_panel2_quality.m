% STUDIO COMPARISON PANEL 2: QUALITY METRICS
% Compares rating and review metrics between Indie, Mid-tier, and AAA studios

pkg load statistics;

fprintf('Studio Panel 2: Quality Metrics Comparison...\n');

% Read simplified CSV file
fid = fopen('../../data/processed/studio_panel2_data.csv', 'r');
fgetl(fid);  % Skip header
studio_types = {};
ratings = [];
reviews = [];
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line) && length(line) > 0
        parts = strsplit(line, ',');
        studio_types{end+1} = parts{1};
        ratings(end+1) = str2double(parts{2});
        reviews(end+1) = str2double(parts{3});
    end
end
fclose(fid);
ratings = ratings';
reviews = reviews';

% Separate by studio type
indie_ratings = ratings(strcmp(studio_types, 'Indie'));
midtier_ratings = ratings(strcmp(studio_types, 'Mid-tier'));
aaa_ratings = ratings(strcmp(studio_types, 'AAA'));

indie_reviews = reviews(strcmp(studio_types, 'Indie'));
midtier_reviews = reviews(strcmp(studio_types, 'Mid-tier'));
aaa_reviews = reviews(strcmp(studio_types, 'AAA'));

fprintf('Indie: avg rating=%.1f%%, median reviews=%d\n', mean(indie_ratings), median(indie_reviews));
fprintf('Mid-tier: avg rating=%.1f%%, median reviews=%d\n', mean(midtier_ratings), median(midtier_reviews));
fprintf('AAA: avg rating=%.1f%%, median reviews=%d\n', mean(aaa_ratings), median(aaa_reviews));

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Colors
indie_color = [0.3, 0.7, 0.9];
midtier_color = [0.9, 0.6, 0.2];
aaa_color = [0.5, 0.3, 0.7];
colors_list = {indie_color, midtier_color, aaa_color};

% SUBPLOT 1: Average Rating Comparison
subplot(2, 2, 1);
hold on;

bar_width = 0.6;
positions = [1, 2, 3];
avg_ratings = [mean(indie_ratings), mean(midtier_ratings), mean(aaa_ratings)];

for i = 1:3
    x = [positions(i)-bar_width/2, positions(i)+bar_width/2, positions(i)+bar_width/2, positions(i)-bar_width/2];
    y = [0, 0, avg_ratings(i), avg_ratings(i)];
    patch(x, y, colors_list{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    text(positions(i), avg_ratings(i) + 1, sprintf('%.1f%%', avg_ratings(i)), ...
         'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
ylim([0, 100]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', {'Indie', 'Mid-tier', 'AAA'});
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Average Rating (%)', 'FontSize', 14, 'FontWeight', 'bold');
title('Average User Rating', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 2: Rating Distribution (violin plot)
subplot(2, 2, 2);
hold on;

all_ratings = {indie_ratings, midtier_ratings, aaa_ratings};
labels = {'Indie', 'Mid-tier', 'AAA'};

for i = 1:3
    rating_data = all_ratings{i};
    pos = i;
    
    % Calculate quartiles
    q1 = quantile(rating_data, 0.25);
    q2 = median(rating_data);
    q3 = quantile(rating_data, 0.75);
    
    % Draw box
    box_x = [pos-0.25, pos+0.25, pos+0.25, pos-0.25, pos-0.25];
    box_y = [q1, q1, q3, q3, q1];
    patch(box_x, box_y, colors_list{i}, 'FaceAlpha', 0.6, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 2);
    
    % Draw median line
    plot([pos-0.25, pos+0.25], [q2, q2], 'k-', 'LineWidth', 3);
    
    % Draw whiskers
    plot([pos, pos], [min(rating_data), q1], 'k-', 'LineWidth', 1.5);
    plot([pos, pos], [q3, max(rating_data)], 'k-', 'LineWidth', 1.5);
end

xlim([0.5, 3.5]);
ylim([70, 100]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', labels);
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Rating (%)', 'FontSize', 14, 'FontWeight', 'bold');
title('Rating Distribution', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 3: Review Count Comparison (log scale)
subplot(2, 2, 3);
hold on;

median_reviews = [median(indie_reviews), median(midtier_reviews), median(aaa_reviews)];

for i = 1:3
    x = [positions(i)-bar_width/2, positions(i)+bar_width/2, positions(i)+bar_width/2, positions(i)-bar_width/2];
    y = [1, 1, median_reviews(i), median_reviews(i)];
    patch(x, y, colors_list{i}, 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    text(positions(i), median_reviews(i) * 1.5, sprintf('%d', round(median_reviews(i))), ...
         'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

xlim([0.5, 3.5]);
set(gca, 'YScale', 'log');
ylim([1000, max(median_reviews) * 3]);
set(gca, 'XTick', [1, 2, 3], 'XTickLabel', {'Indie', 'Mid-tier', 'AAA'});
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
ylabel('Median Review Count (log scale)', 'FontSize', 14, 'FontWeight', 'bold');
title('Community Engagement', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% SUBPLOT 4: Rating vs Reviews Scatter
subplot(2, 2, 4);
hold on;

% Plot each studio type
scatter(indie_reviews, indie_ratings, 50, indie_color, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.6);
scatter(midtier_reviews, midtier_ratings, 50, midtier_color, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.6);
scatter(aaa_reviews, aaa_ratings, 50, aaa_color, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.6);

set(gca, 'XScale', 'log');
xlim([500, max([indie_reviews; midtier_reviews; aaa_reviews]) * 1.5]);
ylim([70, 105]); % Increase y-scale to avoid overlap
xlabel('Total Reviews (log scale)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Rating (%)', 'FontSize', 14, 'FontWeight', 'bold');
title('Rating vs Community Size', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
legend({'Indie', 'Mid-tier', 'AAA'}, 'Location', 'northeast', 'FontSize', 11); % Move legend to top-right corner
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);

% Save figure
print('../../outputs/images/studio_panel2_quality.png', '-dpng', '-r300');
fprintf('✓ Saved: studio_panel2_quality.png\n');
