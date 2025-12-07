% ADVANCED PANEL 22: BOX PLOT - Review Distribution Analysis
% High-quality box plots showing review count patterns

clear all;
close all;
clc;

fprintf('Creating Advanced Box Plot Panel (Review Distribution)...\n');
fprintf('Using preprocessed data for fast loading...\n');

% Load preprocessed data (Price, Rating, Reviews)
data = dlmread('panel22_boxplot_data.csv', ',');
prices = data(:, 1);
ratings = data(:, 2);
total_reviews = data(:, 3);

% Log scale for reviews
log_reviews = log10(total_reviews + 1);

fprintf('Loaded %d games\n', length(prices));

% Create figure
fig = figure('Position', [100, 100, 1600, 1100], 'Color', [0.95 0.95 0.95]);
set(fig, 'PaperPositionMode', 'auto');

% PANEL 1: Box plot by price category
subplot(2, 2, 1);

% Categorize prices
price_cats = {'$0-10', '$10-20', '$20-30', '$30-50', '$50+'};
price_bins = [0 10 20 30 50 inf];
n_cats = length(price_cats);

% Prepare data for box plot
box_data = [];
box_groups = [];

for i = 1:n_cats
    idx = prices >= price_bins(i) & prices < price_bins(i+1);
    cat_reviews = log_reviews(idx);
    box_data = [box_data; cat_reviews];
    box_groups = [box_groups; i * ones(sum(idx), 1)];
end

boxplot(box_data, box_groups, 'Labels', price_cats, 'Colors', 'b');
ylabel('Log10(Review Count)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Price Category', 'FontSize', 12, 'FontWeight', 'bold');
title('Review Distribution by Price', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

% PANEL 2: Box plot by rating category
subplot(2, 2, 2);

% Categorize ratings
rating_cats = {'<50%', '50-70%', '70-80%', '80-90%', '90+%'};
rating_bins = [0 50 70 80 90 100];
n_rating_cats = length(rating_cats);

% Prepare data
box_data2 = [];
box_groups2 = [];

for i = 1:n_rating_cats
    idx = ratings >= rating_bins(i) & ratings < rating_bins(i+1);
    cat_reviews = log_reviews(idx);
    box_data2 = [box_data2; cat_reviews];
    box_groups2 = [box_groups2; i * ones(sum(idx), 1)];
end

boxplot(box_data2, box_groups2, 'Labels', rating_cats, 'Colors', 'r');
ylabel('Log10(Review Count)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Rating Category', 'FontSize', 12, 'FontWeight', 'bold');
title('Review Distribution by Rating', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

% PANEL 3: Violin-style plot (simulated with histogram)
subplot(2, 2, 3);

colors = [0.2 0.5 0.8; 0.8 0.5 0.2; 0.5 0.8 0.2; 0.8 0.2 0.5; 0.5 0.2 0.8];
x_offset = 0;

for i = 1:n_cats
    idx = prices >= price_bins(i) & prices < price_bins(i+1);
    cat_reviews = log_reviews(idx);
    
    % Create histogram for violin effect
    [counts, edges] = histcounts(cat_reviews, 20);
    centers = (edges(1:end-1) + edges(2:end)) / 2;
    
    % Normalize counts for width
    counts_norm = counts / max(counts) * 0.4;
    
    % Plot mirrored histogram
    hold on;
    fill([x_offset + counts_norm, x_offset - fliplr(counts_norm)], ...
         [centers, fliplr(centers)], colors(i, :), ...
         'EdgeColor', 'black', 'LineWidth', 1.5, 'FaceAlpha', 0.6);
    
    x_offset = x_offset + 1;
end
hold off;

set(gca, 'XTick', 0:n_cats-1, 'XTickLabel', price_cats);
ylabel('Log10(Review Count)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Price Category', 'FontSize', 12, 'FontWeight', 'bold');
title('Violin-Style Distribution', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([-0.7 n_cats-0.3]);

% PANEL 4: Statistics summary
subplot(2, 2, 4);
axis off;

stats_text = 'REVIEW DISTRIBUTION STATISTICS\n';
stats_text = [stats_text repmat('=', 1, 50) '\n\n'];

% Overall stats
stats_text = sprintf('%sOverall Statistics:\n', stats_text);
stats_text = sprintf('%s  Total Games: %d\n', stats_text, length(total_reviews));
stats_text = sprintf('%s  Avg Reviews: %s\n', stats_text, format_number(mean(total_reviews)));
stats_text = sprintf('%s  Median Reviews: %s\n', stats_text, format_number(median(total_reviews)));
stats_text = sprintf('%s  Max Reviews: %s\n', stats_text, format_number(max(total_reviews)));

stats_text = sprintf('%s\nReview Categories:\n', stats_text);

review_cats = {
    'Very Low (<100)', 0, 100;
    'Low (100-1K)', 100, 1000;
    'Medium (1K-10K)', 1000, 10000;
    'High (10K-100K)', 10000, 100000;
    'Very High (100K+)', 100000, inf
};

for i = 1:size(review_cats, 1)
    cat_name = review_cats{i, 1};
    min_val = review_cats{i, 2};
    max_val = review_cats{i, 3};
    
    count = sum(total_reviews >= min_val & total_reviews < max_val);
    pct = 100 * count / length(total_reviews);
    
    stats_text = sprintf('%s  %-20s: %5d games (%4.1f%%)\n', ...
                        stats_text, cat_name, count, pct);
end

stats_text = sprintf('%s\nTop 10 Most Reviewed Games:\n', stats_text);
[sorted_reviews, idx] = sort(total_reviews, 'descend');
stats_text = sprintf('%s  1. %s reviews\n', stats_text, format_number(sorted_reviews(1)));
stats_text = sprintf('%s  2. %s reviews\n', stats_text, format_number(sorted_reviews(2)));
stats_text = sprintf('%s  3. %s reviews\n', stats_text, format_number(sorted_reviews(3)));
stats_text = sprintf('%s  ...\n', stats_text);
stats_text = sprintf('%s  10. %s reviews\n', stats_text, format_number(sorted_reviews(10)));

text(0.1, 0.95, stats_text, 'Units', 'normalized', ...
     'VerticalAlignment', 'top', 'FontSize', 9, ...
     'FontName', 'FixedWidth', 'FontWeight', 'bold', ...
     'BackgroundColor', [0.9 1 0.9], 'EdgeColor', 'black', ...
     'LineWidth', 2, 'Margin', 10);

% Save (sgtitle not available in Octave)
print('advanced_panel22_boxplot_reviews.png', '-dpng', '-r300');
fprintf('Saved: advanced_panel22_boxplot_reviews.png\n');

close all;
fprintf('Panel creation complete!\n');

% Helper function
function str = format_number(num)
    if num >= 1000000
        str = sprintf('%.1fM', num / 1000000);
    elseif num >= 1000
        str = sprintf('%.1fK', num / 1000);
    else
        str = sprintf('%d', round(num));
    end
end
