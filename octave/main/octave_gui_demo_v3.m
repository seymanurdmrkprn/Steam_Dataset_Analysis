% STEAM GAMES ANALYTICS - OCTAVE GUI DEMO V3 (IMPROVED)
% Enhanced with better error handling, aesthetics, and search functionality

function octave_gui_demo_v3()

clear all;
close all;
clc;

pkg load statistics;

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║      STEAM GAMES ANALYTICS - OCTAVE GUI DEMO           ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

% Load data
fprintf('Loading demo dataset (1,730 famous games)...\n');

if ~exist('../../data/processed/demo_data_simple.csv', 'file')
    fprintf('Creating simplified data files...\n');
    system('python create_simple_data.py');
end

try
    % Load numeric data
    raw_data = dlmread('../../data/processed/demo_data_simple.csv', ',', 1, 0);
    
    % Load string data
    fid = fopen('../../data/processed/demo_data_names.txt', 'r', 'n', 'UTF-8');
    names = {};
    devs = {};
    genres = {};
    
    fgetl(fid);  % Skip header
    
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(line)
            parts = strsplit(line, '|');
            if length(parts) >= 3
                names{end+1} = parts{1};
                devs{end+1} = parts{2};
                genres{end+1} = parts{3};
            end
        end
    end
    fclose(fid);
    
    % Create data structure
    data = struct();
    data.AppID = raw_data(:, 1);
    data.Price = raw_data(:, 2);
    data.Positive = raw_data(:, 3);
    data.Negative = raw_data(:, 4);
    data.demo_score = raw_data(:, 5);
    data.Name = names';
    data.Developers = devs';
    data.Genres = genres';
    data.count = length(data.AppID);
    
    % Calculate additional metrics (safe division)
    data.TotalReviews = data.Positive + data.Negative;
    data.Rating = zeros(size(data.Positive));
    valid_reviews = data.TotalReviews > 0;
    data.Rating(valid_reviews) = (data.Positive(valid_reviews) ./ data.TotalReviews(valid_reviews)) * 100;
    
    fprintf('Successfully loaded %d games!\n\n', data.count);
catch err
    fprintf('ERROR: Could not load data!\n');
    fprintf('  Message: %s\n', err.message);
    return;
end

% Main menu loop
while true
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║                      MAIN MENU                         ║\n');
    fprintf('╠════════════════════════════════════════════════════════╣\n');
    fprintf('║  1. Top 10 Most Popular Games                          ║\n');
    fprintf('║  2. Price Analysis (Detailed)                          ║\n');
    fprintf('║  3. Developer Rankings                                 ║\n');
    fprintf('║  4. Genre Distribution                                 ║\n');
    fprintf('║  5. Rating Analysis                                    ║\n');
    fprintf('║  6. Price vs Rating Correlation                        ║\n');
    fprintf('║  7. Review Distribution Analysis                       ║\n');
    fprintf('║  8. Yearly Trends (Simulated)                          ║\n');
    fprintf('║  9. Platform Support Analysis                          ║\n');
    fprintf('║ 10. Search Games by Name                               ║\n');
    fprintf('║ 11. Find Games by Price Range                          ║\n');
    fprintf('║ 12. Dataset Statistics                                 ║\n');
    fprintf('║ 13. Studio Comparison (Indie vs AAA)                   ║\n');
    fprintf('║  0. Exit                                               ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n');
    
    choice = input('\nYour choice (0-13): ');
    
    if isempty(choice) || ~isnumeric(choice)
        fprintf('\nInvalid input! Please enter a number.\n');
        continue;
    end
    
    switch choice
        case 1
            show_top_games(data);
        case 2
            price_analysis(data);
        case 3
            developer_analysis(data);
        case 4
            genre_analysis(data);
        case 5
            rating_analysis(data);
        case 6
            price_vs_rating(data);
        case 7
            review_distribution(data);
        case 8
            yearly_trends(data);
        case 9
            platform_analysis(data);
        case 10
            search_games(data);
        case 11
            find_by_price(data);
        case 12
            dataset_stats(data);
        case 13
            studio_comparison();
        case 0
            fprintf('\nThank you for using Steam Analytics!\n');
            fprintf('Closing all windows...\n\n');
            close all;
            break;
        otherwise
            fprintf('\nInvalid choice! Please enter 0-13.\n');
    end
end

end  % Main function end

% ========== ANALYSIS FUNCTIONS ==========

function show_top_games(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║              TOP 10 MOST POPULAR GAMES                 ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    % Sort by demo_score
    [~, idx] = sort(data.demo_score, 'descend');
    idx = idx(1:min(10, length(idx)));
    
    fprintf('%-4s %-40s %-25s %8s %10s %7s\n', ...
            'Rank', 'Game', 'Developer', 'Price', 'Reviews', 'Rating');
    fprintf('%s\n', repmat('─', 1, 105));
    
    for i = 1:length(idx)
        game_name = truncate_string(data.Name{idx(i)}, 40);
        dev_name = truncate_string(data.Developers{idx(i)}, 25);
        price = data.Price(idx(i));
        reviews = data.Positive(idx(i)) + data.Negative(idx(i));
        rating = data.Rating(idx(i));
        
        fprintf('%-4d %-40s %-25s $%7.2f %10s %6.1f%%\n', ...
                i, game_name, dev_name, price, format_number(reviews), rating);
    end
    
    fprintf('\nSorted by popularity score (reviews x rating)\n');
    pause_continue();
end

function price_analysis(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║                   PRICE ANALYSIS                       ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    % Price categories with safe indexing
    prices = data.Price;
    prices(isnan(prices)) = 0;  % Handle NaN
    
    free_idx = prices == 0;
    cheap_idx = prices > 0 & prices <= 10;
    mid_idx = prices > 10 & prices <= 30;
    expensive_idx = prices > 30 & prices <= 60;
    premium_idx = prices > 60;
    
    fprintf('Price Distribution:\n');
    fprintf('  Free (0$):          %4d games (%.1f%%)\n', sum(free_idx), 100*sum(free_idx)/data.count);
    fprintf('  Cheap (0-10$):      %4d games (%.1f%%)\n', sum(cheap_idx), 100*sum(cheap_idx)/data.count);
    fprintf('  Mid (10-30$):       %4d games (%.1f%%)\n', sum(mid_idx), 100*sum(mid_idx)/data.count);
    fprintf('  Expensive (30-60$): %4d games (%.1f%%)\n', sum(expensive_idx), 100*sum(expensive_idx)/data.count);
    fprintf('  Premium (60$+):     %4d games (%.1f%%)\n', sum(premium_idx), 100*sum(premium_idx)/data.count);
    
    % Average prices and ratings
    fprintf('\nStatistics:\n');
    fprintf('  Average price:   $%.2f\n', mean(prices));
    fprintf('  Median price:    $%.2f\n', median(prices));
    fprintf('  Max price:       $%.2f\n', max(prices));
    
    % Create visualization
    figure('Position', [100, 100, 1400, 700], 'Color', [0.95 0.95 0.95]);
    
    categories = {'Free', '0-10$', '10-30$', '30-60$', '60$+'};
    counts = [sum(free_idx), sum(cheap_idx), sum(mid_idx), sum(expensive_idx), sum(premium_idx)];
    
    % Subplot 1: Game count by price
    subplot(2, 2, 1);
    colors = [0.8 0.8 0.8; 0.4 0.8 0.4; 0.9 0.9 0.4; 0.9 0.6 0.3; 0.9 0.3 0.3];
    hold on;
    for i = 1:length(counts)
        bar(i, counts(i), 0.6, 'FaceColor', colors(i,:), 'EdgeColor', 'black', 'LineWidth', 1.5);
    end
    hold off;
    set(gca, 'XTick', 1:length(categories), 'XTickLabel', categories, 'FontSize', 11);
    title('Game Distribution by Price Category', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Number of Games', 'FontSize', 11);
    xlabel('Price Range', 'FontSize', 11);
    xlim([0.5, length(counts)+0.5]);
    grid on;
    
    % Add value labels on bars
    for i = 1:length(counts)
        text(i, counts(i) + max(counts)*0.02, num2str(counts(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    end
    
    % Subplot 2: Average rating by price
    subplot(2, 2, 2);
    avg_ratings = [
        safe_mean_rating(data, free_idx),
        safe_mean_rating(data, cheap_idx),
        safe_mean_rating(data, mid_idx),
        safe_mean_rating(data, expensive_idx),
        safe_mean_rating(data, premium_idx)
    ];
    
    hold on;
    for i = 1:length(avg_ratings)
        bar(i, avg_ratings(i), 0.6, 'FaceColor', colors(i,:), 'EdgeColor', 'black', 'LineWidth', 1.5);
    end
    hold off;
    set(gca, 'XTick', 1:length(categories), 'XTickLabel', categories, 'FontSize', 11);
    xlim([0.5, length(avg_ratings)+0.5]);
    title('Average Rating by Price Category', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Average Rating (%)', 'FontSize', 11);
    xlabel('Price Range', 'FontSize', 11);
    ylim([0, 100]);
    grid on;
    
    % Add value labels
    for i = 1:length(avg_ratings)
        if ~isnan(avg_ratings(i))
            text(i, avg_ratings(i) + 3, sprintf('%.1f%%', avg_ratings(i)), ...
                 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
        end
    end
    
    % Subplot 3: Price distribution histogram
    subplot(2, 2, 3);
    paid_prices = prices(prices > 0);
    if ~isempty(paid_prices)
        hist(paid_prices, 30);
        h = findobj(gca, 'Type', 'patch');
        set(h, 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'black', 'LineWidth', 1);
        title('Price Distribution (Paid Games Only)', 'FontSize', 13, 'FontWeight', 'bold');
        xlabel('Price ($)', 'FontSize', 11);
        ylabel('Frequency', 'FontSize', 11);
        grid on;
    end
    
    % Subplot 4: Cumulative distribution
    subplot(2, 2, 4);
    sorted_prices = sort(prices);
    cumulative = (1:length(sorted_prices)) / length(sorted_prices) * 100;
    plot(sorted_prices, cumulative, 'LineWidth', 2.5, 'Color', [0.2 0.4 0.8]);
    title('Cumulative Price Distribution', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Price ($)', 'FontSize', 11);
    ylabel('Cumulative Percentage (%)', 'FontSize', 11);
    grid on;
    xlim([0, max(prices)]);
    ylim([0, 100]);
    
    pause_continue();
end

function developer_analysis(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║                 DEVELOPER RANKINGS                     ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    % Count games per developer
    devs = data.Developers;
    unique_devs = unique(devs);
    
    % Filter out empty or NaN developers
    valid_devs = {};
    for i = 1:length(unique_devs)
        dev_str = unique_devs{i};
        % Check if not empty, not 'NaN', 'nan', or contains 'NaN'
        if ~isempty(dev_str) && ...
           ~strcmpi(dev_str, 'NaN') && ...
           ~strcmpi(dev_str, 'nan') && ...
           isempty(strfind(lower(dev_str), 'nan'))
            valid_devs{end+1} = dev_str;
        end
    end
    
    dev_counts = zeros(length(valid_devs), 1);
    dev_avg_rating = zeros(length(valid_devs), 1);
    dev_total_reviews = zeros(length(valid_devs), 1);
    
    for i = 1:length(valid_devs)
        idx = strcmp(devs, valid_devs{i});
        dev_counts(i) = sum(idx);
        dev_avg_rating(i) = safe_mean_rating(data, idx);
        dev_total_reviews(i) = sum(data.TotalReviews(idx));
    end
    
    % Sort by game count
    [sorted_counts, sort_idx] = sort(dev_counts, 'descend');
    top_n = min(15, length(sort_idx));
    
    fprintf('Top %d Developers (by game count in demo):\n\n', top_n);
    fprintf('%-4s %-35s %6s %10s %10s\n', 'Rank', 'Developer', 'Games', 'Avg Rating', 'Total Reviews');
    fprintf('%s\n', repmat('─', 1, 75));
    
    for i = 1:top_n
        dev_name = truncate_string(valid_devs{sort_idx(i)}, 35);
        fprintf('%-4d %-35s %6d %9.1f%% %10s\n', ...
                i, dev_name, sorted_counts(i), ...
                dev_avg_rating(sort_idx(i)), ...
                format_number(dev_total_reviews(sort_idx(i))));
    end
    
    % Visualization
    figure('Position', [100, 100, 1400, 800], 'Color', [0.95 0.95 0.95]);
    
    % Horizontal bar chart
    subplot(2, 1, 1);
    display_counts = sorted_counts(1:top_n);
    barh(display_counts, 'FaceColor', [0.3 0.6 0.8], 'EdgeColor', 'black', 'LineWidth', 1.5);
    set(gca, 'YTickLabel', valid_devs(sort_idx(1:top_n)), 'FontSize', 10);
    title(sprintf('Top %d Developers by Game Count', top_n), 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Number of Games', 'FontSize', 11);
    grid on;
    
    % Add value labels
    for i = 1:top_n
        text(display_counts(i) + max(display_counts)*0.01, i, num2str(display_counts(i)), ...
             'FontSize', 9, 'FontWeight', 'bold');
    end
    
    % Rating comparison
    subplot(2, 1, 2);
    display_ratings = dev_avg_rating(sort_idx(1:top_n));
    barh(display_ratings, 'FaceColor', [0.4 0.8 0.5], 'EdgeColor', 'black', 'LineWidth', 1.5);
    set(gca, 'YTickLabel', valid_devs(sort_idx(1:top_n)), 'FontSize', 10);
    title(sprintf('Average Rating by Developer (Top %d)', top_n), 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Average Rating (%)', 'FontSize', 11);
    xlim([0, 100]);
    grid on;
    
    % Add value labels
    for i = 1:top_n
        if ~isnan(display_ratings(i))
            text(display_ratings(i) + 2, i, sprintf('%.1f%%', display_ratings(i)), ...
                 'FontSize', 9, 'FontWeight', 'bold');
        end
    end
    
    pause_continue();
end

function genre_analysis(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║                 GENRE DISTRIBUTION                     ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    % Parse genres (may have multiple per game)
    all_genres = {};
    for i = 1:length(data.Genres)
        genre_list = strsplit(data.Genres{i}, ',');
        for j = 1:length(genre_list)
            genre = strtrim(genre_list{j});
            if ~isempty(genre)
                all_genres{end+1} = genre;
            end
        end
    end
    
    unique_genres = unique(all_genres);
    genre_counts = zeros(length(unique_genres), 1);
    
    for i = 1:length(unique_genres)
        genre_counts(i) = sum(strcmp(all_genres, unique_genres{i}));
    end
    
    % Sort by count
    [sorted_counts, sort_idx] = sort(genre_counts, 'descend');
    top_n = min(10, length(sort_idx));
    
    fprintf('Top %d Genres:\n\n', top_n);
    for i = 1:top_n
        fprintf('%2d. %-25s %5d games (%.1f%%)\n', ...
                i, unique_genres{sort_idx(i)}, sorted_counts(i), ...
                100 * sorted_counts(i) / length(all_genres));
    end
    
    % Visualization
    figure('Position', [100, 100, 1400, 700], 'Color', [0.95 0.95 0.95]);
    
    % Pie chart
    subplot(1, 2, 1);
    display_counts = sorted_counts(1:top_n);
    colormap_custom = jet(top_n);
    pie(display_counts);
    labels = unique_genres(sort_idx(1:top_n));
    legend(labels, 'Location', 'eastoutside', 'FontSize', 10);
    title('Genre Distribution (Top 10)', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Bar chart
    subplot(1, 2, 2);
    bar(display_counts, 'FaceColor', [0.5 0.3 0.7], 'EdgeColor', 'black', 'LineWidth', 1.5);
    set(gca, 'XTick', 1:top_n, 'FontSize', 8);
    set(gca, 'XTickLabel', labels);
    % Rotate labels manually for better readability
    h = gca;
    set(h, 'XTickLabelRotation', 45);
    title('Game Count by Genre', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Number of Games', 'FontSize', 11);
    grid on;
    
    % Add value labels
    for i = 1:top_n
        text(i, display_counts(i) + max(display_counts)*0.02, num2str(display_counts(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
    end
    
    pause_continue();
end

function rating_analysis(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║                  RATING ANALYSIS                       ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    ratings = data.Rating;
    ratings = ratings(~isnan(ratings));  % Remove NaN
    
    % Statistics
    fprintf('Rating Statistics:\n');
    fprintf('  Average:    %.2f%%\n', mean(ratings));
    fprintf('  Median:     %.2f%%\n', median(ratings));
    fprintf('  Std Dev:    %.2f%%\n', std(ratings));
    fprintf('  Min:        %.2f%%\n', min(ratings));
    fprintf('  Max:        %.2f%%\n', max(ratings));
    
    % Rating categories
    mixed = sum(ratings < 70);
    positive = sum(ratings >= 70 & ratings < 80);
    very_positive = sum(ratings >= 80 & ratings < 90);
    overwhelm_positive = sum(ratings >= 90);
    
    fprintf('\nRating Categories:\n');
    fprintf('  Mixed (< 70%%):              %4d games (%.1f%%)\n', mixed, 100*mixed/length(ratings));
    fprintf('  Positive (70-80%%):          %4d games (%.1f%%)\n', positive, 100*positive/length(ratings));
    fprintf('  Very Positive (80-90%%):     %4d games (%.1f%%)\n', very_positive, 100*very_positive/length(ratings));
    fprintf('  Overwhelmingly Pos. (90%%+): %4d games (%.1f%%)\n', overwhelm_positive, 100*overwhelm_positive/length(ratings));
    
    % Visualization
    figure('Position', [100, 100, 1400, 700], 'Color', [0.95 0.95 0.95]);
    
    % Histogram
    subplot(2, 2, 1);
    hist(ratings, 30);
    h = findobj(gca, 'Type', 'patch');
    set(h, 'FaceColor', [0.4 0.7 0.9], 'EdgeColor', 'black', 'LineWidth', 1.5);
    title('Rating Distribution', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Rating (%)', 'FontSize', 11);
    ylabel('Frequency', 'FontSize', 11);
    grid on;
    
    % Category bar chart
    subplot(2, 2, 2);
    cats = {'Mixed\n(<70%)', 'Positive\n(70-80%)', 'Very Pos.\n(80-90%)', 'Overwhelm.\n(90%+)'};
    vals = [mixed, positive, very_positive, overwhelm_positive];
    colors_cat = [0.9 0.3 0.3; 0.9 0.9 0.4; 0.4 0.8 0.4; 0.3 0.9 0.6];
    hold on;
    for i = 1:length(vals)
        bar(i, vals(i), 0.6, 'FaceColor', colors_cat(i,:), 'EdgeColor', 'black', 'LineWidth', 1.5);
    end
    hold off;
    set(gca, 'XTick', 1:length(cats), 'XTickLabel', cats, 'FontSize', 10);
    xlim([0.5, length(vals)+0.5]);
    title('Games by Rating Category', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Number of Games', 'FontSize', 11);
    grid on;
    
    % Add value labels
    for i = 1:4
        text(i, vals(i) + max(vals)*0.02, num2str(vals(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    end
    
    % Box plot
    subplot(2, 2, 3);
    boxplot(ratings, 'Widths', 0.5);
    set(gca, 'XTickLabel', {''});  % Remove x label
    title('Rating Box Plot', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Rating (%)', 'FontSize', 11);
    ylim([0, 100]);
    grid on;
    
    % Cumulative distribution
    subplot(2, 2, 4);
    sorted_ratings = sort(ratings);
    cumulative = (1:length(sorted_ratings)) / length(sorted_ratings) * 100;
    plot(sorted_ratings, cumulative, 'LineWidth', 2.5, 'Color', [0.3 0.5 0.8]);
    title('Cumulative Rating Distribution', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Rating (%)', 'FontSize', 11);
    ylabel('Cumulative Percentage (%)', 'FontSize', 11);
    grid on;
    xlim([0, 100]);
    ylim([0, 100]);
    
    pause_continue();
end

function price_vs_rating(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║            PRICE VS RATING CORRELATION                 ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    % Clean data
    valid_idx = ~isnan(data.Rating) & ~isnan(data.Price);
    prices = data.Price(valid_idx);
    ratings = data.Rating(valid_idx);
    reviews = data.TotalReviews(valid_idx);
    
    % Correlation
    if length(prices) > 1
        corr_val = corr(prices, ratings);
        fprintf('Correlation coefficient: %.3f\n', corr_val);
        if abs(corr_val) < 0.3
            fprintf('→ Weak correlation\n');
        elseif abs(corr_val) < 0.7
            fprintf('→ Moderate correlation\n');
        else
            fprintf('→ Strong correlation\n');
        end
    end
    
    % Visualization
    figure('Position', [100, 100, 1400, 700], 'Color', [0.95 0.95 0.95]);
    
    % Subplot 1: Hexbin-style density (binned scatter)
    subplot(2, 2, 1);
    % Create 2D histogram for density using hist3
    nbins = 30;
    price_edges = linspace(min(prices), max(prices), nbins+1);
    rating_edges = linspace(min(ratings), max(ratings), nbins+1);
    
    % Manual 2D binning
    N = zeros(nbins, nbins);
    for i = 1:length(prices)
        % Find bin indices
        price_bin = find(prices(i) >= price_edges(1:end-1) & prices(i) <= price_edges(2:end), 1);
        rating_bin = find(ratings(i) >= rating_edges(1:end-1) & ratings(i) <= rating_edges(2:end), 1);
        
        if ~isempty(price_bin) && ~isempty(rating_bin)
            N(price_bin, rating_bin) = N(price_bin, rating_bin) + 1;
        end
    end
    
    % Show as image
    imagesc(price_edges(1:end-1), rating_edges(1:end-1), N');
    axis xy;
    colormap(hot);
    colorbar;
    title('Price vs Rating Density Map', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Price ($)', 'FontSize', 11);
    ylabel('Rating (%)', 'FontSize', 11);
    
    % Subplot 2: Clean scatter with trend
    subplot(2, 2, 2);
    % Sample data if too many points
    if length(prices) > 1000
        sample_idx = randperm(length(prices), 1000);
        plot_prices = prices(sample_idx);
        plot_ratings = ratings(sample_idx);
    else
        plot_prices = prices;
        plot_ratings = ratings;
    end
    scatter(plot_prices, plot_ratings, 20, [0.3 0.5 0.8], 'filled', 'MarkerFaceAlpha', 0.4);
    hold on;
    % Add trend line
    if length(prices) > 1
        p = polyfit(prices, ratings, 1);
        x_trend = linspace(min(prices), max(prices), 100);
        y_trend = polyval(p, x_trend);
        plot(x_trend, y_trend, 'r-', 'LineWidth', 3);
    end
    hold off;
    title('Scatter with Trend Line', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Price ($)', 'FontSize', 11);
    ylabel('Rating (%)', 'FontSize', 11);
    grid on;
    ylim([0, 100]);
    
    % Subplot 3: Average rating by price bins
    subplot(2, 2, 3);
    price_bins = [0, 10, 20, 30, 40, 60, 100];
    bin_names = {'0-10$', '10-20$', '20-30$', '30-40$', '40-60$', '60+$'};
    avg_ratings_by_price = zeros(length(price_bins)-1, 1);
    for i = 1:length(price_bins)-1
        idx = prices >= price_bins(i) & prices < price_bins(i+1);
        if any(idx)
            avg_ratings_by_price(i) = mean(ratings(idx));
        else
            avg_ratings_by_price(i) = NaN;
        end
    end
    bar(avg_ratings_by_price, 0.8, 'FaceColor', [0.4 0.7 0.4], 'EdgeColor', 'black', 'LineWidth', 1.5);
    set(gca, 'XTick', 1:length(bin_names), 'XTickLabel', bin_names, 'FontSize', 10);
    xlim([0.5, length(bin_names)+0.5]);
    title('Average Rating by Price Range', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Average Rating (%)', 'FontSize', 11);
    xlabel('Price Range', 'FontSize', 11);
    ylim([0, 100]);
    grid on;
    
    % Subplot 4: Correlation statistics
    subplot(2, 2, 4);
    axis off;
    text(0.1, 0.9, 'CORRELATION ANALYSIS', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Calculate statistics
    corr_val = corr(prices, ratings);
    text(0.1, 0.75, sprintf('Correlation: %.3f', corr_val), 'FontSize', 12);
    
    if abs(corr_val) < 0.3
        interp = 'Weak correlation';
        color_str = 'orange';
    elseif abs(corr_val) < 0.7
        interp = 'Moderate correlation';
        color_str = 'yellow';
    else
        interp = 'Strong correlation';
        color_str = 'green';
    end
    text(0.1, 0.65, sprintf('Interpretation: %s', interp), 'FontSize', 11);
    
    % Price ranges
    text(0.1, 0.50, 'PRICE RANGE SUMMARY:', 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.40, sprintf('Min price: $%.2f', min(prices)), 'FontSize', 10);
    text(0.1, 0.35, sprintf('Max price: $%.2f', max(prices)), 'FontSize', 10);
    text(0.1, 0.30, sprintf('Avg price: $%.2f', mean(prices)), 'FontSize', 10);
    
    text(0.1, 0.15, 'RATING RANGE SUMMARY:', 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.05, sprintf('Min rating: %.1f%%', min(ratings)), 'FontSize', 10);
    text(0.6, 0.05, sprintf('Max rating: %.1f%%', max(ratings)), 'FontSize', 10);
    text(0.1, 0.00, sprintf('Avg rating: %.1f%%', mean(ratings)), 'FontSize', 10);
    text(0.6, 0.00, sprintf('Median: %.1f%%', median(ratings)), 'FontSize', 10);
    
    pause_continue();
end

function review_distribution(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║             REVIEW DISTRIBUTION ANALYSIS               ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    reviews = data.TotalReviews;
    reviews = reviews(reviews > 0);  % Remove games with 0 reviews
    
    % Statistics
    fprintf('Review Statistics:\n');
    fprintf('  Total reviews:  %s\n', format_number(sum(reviews)));
    fprintf('  Average:        %s\n', format_number(mean(reviews)));
    fprintf('  Median:         %s\n', format_number(median(reviews)));
    fprintf('  Max:            %s\n', format_number(max(reviews)));
    
    % Categories
    very_low = sum(reviews < 100);
    low = sum(reviews >= 100 & reviews < 1000);
    medium = sum(reviews >= 1000 & reviews < 10000);
    high = sum(reviews >= 10000 & reviews < 100000);
    very_high = sum(reviews >= 100000);
    
    fprintf('\nReview Count Categories:\n');
    fprintf('  Very Low (< 100):        %4d games\n', very_low);
    fprintf('  Low (100-1K):            %4d games\n', low);
    fprintf('  Medium (1K-10K):         %4d games\n', medium);
    fprintf('  High (10K-100K):         %4d games\n', high);
    fprintf('  Very High (100K+):       %4d games\n', very_high);
    
    % Visualization
    figure('Position', [100, 100, 1400, 700], 'Color', [0.95 0.95 0.95]);
    
    % Log scale histogram
    subplot(2, 2, 1);
    log_reviews = log10(reviews);
    hist(log_reviews, 40);
    h = findobj(gca, 'Type', 'patch');
    set(h, 'FaceColor', [0.6 0.4 0.8], 'EdgeColor', 'black', 'LineWidth', 1.5);
    title('Review Distribution (Log Scale)', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('log10(Review Count)', 'FontSize', 11);
    ylabel('Frequency', 'FontSize', 11);
    grid on;
    
    % Category bar chart
    subplot(2, 2, 2);
    cats = {'Very Low', 'Low', 'Medium', 'High', 'Very High'};
    vals = [very_low, low, medium, high, very_high];
    bar(vals, 'FaceColor', [0.5 0.6 0.8], 'EdgeColor', 'black', 'LineWidth', 1.5);
    set(gca, 'XTickLabel', cats, 'FontSize', 10);
    title('Games by Review Count Category', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Number of Games', 'FontSize', 11);
    grid on;
    
    % Box plot (log scale)
    subplot(2, 2, 3);
    boxplot(log_reviews, 'Widths', 0.5);
    set(gca, 'XTickLabel', {''});  % Remove x label
    title('Review Distribution Box Plot (Log)', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('log10(Review Count)', 'FontSize', 11);
    grid on;
    
    % Top games by reviews
    subplot(2, 2, 4);
    [sorted_reviews, idx] = sort(data.TotalReviews, 'descend');
    top_n = min(10, length(idx));
    barh(sorted_reviews(1:top_n), 'FaceColor', [0.8 0.5 0.3], 'EdgeColor', 'black', 'LineWidth', 1.5);
    set(gca, 'YTickLabel', data.Name(idx(1:top_n)), 'FontSize', 9);
    title('Top 10 Games by Review Count', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Total Reviews', 'FontSize', 11);
    % Format x-axis to show full numbers instead of scientific notation
    xticks_vals = get(gca, 'XTick');
    xtick_labels = arrayfun(@(x) sprintf('%.0f', x), xticks_vals, 'UniformOutput', false);
    set(gca, 'XTickLabel', xtick_labels);
    grid on;
    
    pause_continue();
end

function yearly_trends(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║            YEARLY TRENDS (SIMULATED)                   ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    fprintf('Note: Years are simulated based on review popularity\n');
    fprintf('(More reviews = More recent)\n\n');
    
    % Simulate years based on review count
    [sorted_reviews, idx] = sort(data.TotalReviews, 'descend');
    years = zeros(size(data.Price));
    games_per_year = floor(data.count / 15);
    
    for i = 1:data.count
        year_offset = min(floor((i-1) / games_per_year), 14);
        years(idx(i)) = 2024 - year_offset;
    end
    
    % Calculate yearly statistics
    unique_years = unique(years);
    unique_years = sort(unique_years);
    
    year_counts = zeros(length(unique_years), 1);
    year_avg_price = zeros(length(unique_years), 1);
    year_avg_rating = zeros(length(unique_years), 1);
    
    for i = 1:length(unique_years)
        year_idx = years == unique_years(i);
        year_counts(i) = sum(year_idx);
        year_avg_price(i) = mean(data.Price(year_idx));
        
        year_ratings = data.Rating(year_idx);
        year_ratings = year_ratings(~isnan(year_ratings));
        if ~isempty(year_ratings)
            year_avg_rating(i) = mean(year_ratings);
        else
            year_avg_rating(i) = NaN;
        end
    end
    
    % Print summary
    fprintf('Yearly Summary:\n');
    fprintf('%-6s %8s %12s %12s\n', 'Year', 'Games', 'Avg Price', 'Avg Rating');
    fprintf('%s\n', repmat('─', 1, 45));
    for i = 1:length(unique_years)
        fprintf('%6d %8d    $%8.2f    %8.1f%%\n', ...
                unique_years(i), year_counts(i), year_avg_price(i), year_avg_rating(i));
    end
    
    % Visualization
    figure('Position', [100, 100, 1400, 900], 'Color', [0.95 0.95 0.95]);
    
    % Games per year
    subplot(3, 1, 1);
    bar(unique_years, year_counts, 'FaceColor', [0.4 0.6 0.9], 'EdgeColor', 'black', 'LineWidth', 1.5);
    title('Games Released per Year (Simulated)', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Number of Games', 'FontSize', 11);
    xlim([min(unique_years)-0.5, max(unique_years)+0.5]);
    grid on;
    
    % Average price trend
    subplot(3, 1, 2);
    plot(unique_years, year_avg_price, 'o-', 'LineWidth', 2.5, 'MarkerSize', 8, ...
         'Color', [0.8 0.4 0.2], 'MarkerFaceColor', [0.9 0.5 0.3]);
    title('Average Price Trend', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Average Price ($)', 'FontSize', 11);
    grid on;
    
    % Average rating trend
    subplot(3, 1, 3);
    valid_rating_idx = ~isnan(year_avg_rating);
    plot(unique_years(valid_rating_idx), year_avg_rating(valid_rating_idx), ...
         's-', 'LineWidth', 2.5, 'MarkerSize', 8, ...
         'Color', [0.3 0.7 0.4], 'MarkerFaceColor', [0.4 0.8 0.5]);
    title('Average Rating Trend', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Average Rating (%)', 'FontSize', 11);
    xlabel('Year', 'FontSize', 11);
    ylim([0, 100]);
    grid on;
    
    pause_continue();
end

function platform_analysis(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║          PLATFORM SUPPORT ANALYSIS (SIMULATED)         ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    fprintf('Note: Platform data is simulated based on typical Steam statistics\n\n');
    
    % Simulate platform support
    rng(42);
    n = data.count;
    
    windows = true(n, 1);
    mac = rand(n, 1) < 0.6;
    linux = rand(n, 1) < 0.4;
    
    % Expensive games more likely to have multi-platform
    expensive_idx = data.Price > 30;
    mac(expensive_idx) = rand(sum(expensive_idx), 1) < 0.8;
    linux(expensive_idx) = rand(sum(expensive_idx), 1) < 0.6;
    
    % Statistics
    fprintf('Platform Support:\n');
    fprintf('  Windows:  %4d games (%.1f%%)\n', sum(windows), 100*sum(windows)/n);
    fprintf('  Mac:      %4d games (%.1f%%)\n', sum(mac), 100*sum(mac)/n);
    fprintf('  Linux:    %4d games (%.1f%%)\n', sum(linux), 100*sum(linux)/n);
    
    % Platform combinations
    win_only = windows & ~mac & ~linux;
    win_mac = windows & mac & ~linux;
    win_linux = windows & ~mac & linux;
    all_platforms = windows & mac & linux;
    
    fprintf('\nPlatform Combinations:\n');
    fprintf('  Windows only:      %4d games (%.1f%%)\n', sum(win_only), 100*sum(win_only)/n);
    fprintf('  Windows + Mac:     %4d games (%.1f%%)\n', sum(win_mac), 100*sum(win_mac)/n);
    fprintf('  Windows + Linux:   %4d games (%.1f%%)\n', sum(win_linux), 100*sum(win_linux)/n);
    fprintf('  All platforms:     %4d games (%.1f%%)\n', sum(all_platforms), 100*sum(all_platforms)/n);
    
    % Visualization
    figure('Position', [100, 100, 1400, 700], 'Color', [0.95 0.95 0.95]);
    
    % Platform support bar chart
    subplot(2, 2, 1);
    platforms = {'Windows', 'Mac', 'Linux'};
    support = [sum(windows), sum(mac), sum(linux)];
    colors_plat = [0.3 0.6 0.9; 0.7 0.7 0.7; 0.9 0.6 0.2];
    hold on;
    for i = 1:length(support)
        bar(i, support(i), 0.6, 'FaceColor', colors_plat(i,:), 'EdgeColor', 'black', 'LineWidth', 1.5);
    end
    hold off;
    set(gca, 'XTick', 1:length(platforms), 'XTickLabel', platforms, 'FontSize', 11);
    xlim([0.5, length(support)+0.5]);
    title('Platform Support', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Number of Games', 'FontSize', 11);
    grid on;
    
    % Add value labels
    for i = 1:3
        text(i, support(i) + max(support)*0.02, num2str(support(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    end
    
    % Combination pie chart
    subplot(2, 2, 2);
    combo_labels = {'Win Only', 'Win+Mac', 'Win+Linux', 'All'};
    combo_vals = [sum(win_only), sum(win_mac), sum(win_linux), sum(all_platforms)];
    pie(combo_vals);
    legend(combo_labels, 'Location', 'eastoutside', 'FontSize', 10);
    title('Platform Combinations', 'FontSize', 13, 'FontWeight', 'bold');
    
    % Platform support by price category
    subplot(2, 2, 3);
    price_cats = {'Free', 'Cheap', 'Mid', 'Expensive', 'Premium'};
    free_idx = data.Price == 0;
    cheap_idx = data.Price > 0 & data.Price <= 10;
    mid_idx = data.Price > 10 & data.Price <= 30;
    exp_idx = data.Price > 30 & data.Price <= 60;
    prem_idx = data.Price > 60;
    
    win_by_price = [sum(windows & free_idx), sum(windows & cheap_idx), ...
                    sum(windows & mid_idx), sum(windows & exp_idx), sum(windows & prem_idx)];
    mac_by_price = [sum(mac & free_idx), sum(mac & cheap_idx), ...
                    sum(mac & mid_idx), sum(mac & exp_idx), sum(mac & prem_idx)];
    linux_by_price = [sum(linux & free_idx), sum(linux & cheap_idx), ...
                      sum(linux & mid_idx), sum(linux & exp_idx), sum(linux & prem_idx)];
    
    bar_data = [win_by_price; mac_by_price; linux_by_price]';
    bar(bar_data, 'EdgeColor', 'black', 'LineWidth', 1);
    set(gca, 'XTick', 1:length(price_cats), 'XTickLabel', price_cats, 'FontSize', 10);
    xlim([0.5, length(price_cats)+0.5]);
    title('Platform Support by Price Category', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Number of Games', 'FontSize', 11);
    legend(platforms, 'Location', 'northwest', 'FontSize', 10);
    grid on;
    
    % Percentage stacked bar
    subplot(2, 2, 4);
    bar_data_pct = bar_data ./ sum(bar_data, 2) * 100;
    bar(bar_data_pct, 'stacked', 'EdgeColor', 'black', 'LineWidth', 1);
    set(gca, 'XTick', 1:length(price_cats), 'XTickLabel', price_cats, 'FontSize', 10);
    xlim([0.5, length(price_cats)+0.5]);
    title('Platform Support % by Price', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Percentage (%)', 'FontSize', 11);
    legend(platforms, 'Location', 'northwest', 'FontSize', 10);
    ylim([0, 100]);
    grid on;
    
    pause_continue();
end

function search_games(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║                  SEARCH GAMES BY NAME                  ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    search_term = input('Enter search term (or press Enter to cancel): ', 's');
    
    if isempty(search_term)
        fprintf('Search cancelled.\n');
        return;
    end
    
    % Case-insensitive search
    search_term = lower(search_term);
    matches = [];
    
    for i = 1:data.count
        % Use strfind instead of contains (Octave compatible)
        if ~isempty(strfind(lower(data.Name{i}), search_term))
            matches = [matches; i];
        end
    end
    
    if isempty(matches)
        fprintf('\nNo games found matching "%s"\n', search_term);
    else
        fprintf('\nFound %d game(s) matching "%s":\n\n', length(matches), search_term);
        fprintf('%-4s %-50s %-8s %-10s %7s\n', 'No.', 'Game', 'Price', 'Rating', 'Reviews');
        fprintf('%s\n', repmat('─', 1, 90));
        
        for i = 1:min(20, length(matches))  % Show max 20 results
            idx = matches(i);
            game_name = truncate_string(data.Name{idx}, 50);
            price = data.Price(idx);
            rating = data.Rating(idx);
            reviews = data.TotalReviews(idx);
            
            fprintf('%-4d %-50s $%7.2f %8.1f%% %7s\n', ...
                    i, game_name, price, rating, format_number(reviews));
        end
        
        if length(matches) > 20
            fprintf('\n... and %d more results\n', length(matches) - 20);
        end
    end
    
    pause_continue();
end

function find_by_price(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║               FIND GAMES BY PRICE RANGE                ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    fprintf('Price Range Options:\n');
    fprintf('  1. Free (0$)\n');
    fprintf('  2. Under $10\n');
    fprintf('  3. $10 - $30\n');
    fprintf('  4. $30 - $60\n');
    fprintf('  5. Over $60\n');
    fprintf('  6. Custom range\n');
    
    choice = input('\nYour choice (1-6): ');
    
    if isempty(choice) || ~isnumeric(choice) || choice < 1 || choice > 6
        fprintf('Invalid choice.\n');
        return;
    end
    
    % Determine price range
    if choice == 1
        min_price = 0;
        max_price = 0;
        range_name = 'Free';
    elseif choice == 2
        min_price = 0.01;
        max_price = 10;
        range_name = 'Under $10';
    elseif choice == 3
        min_price = 10;
        max_price = 30;
        range_name = '$10-$30';
    elseif choice == 4
        min_price = 30;
        max_price = 60;
        range_name = '$30-$60';
    elseif choice == 5
        min_price = 60;
        max_price = Inf;
        range_name = 'Over $60';
    else
        min_price = input('Enter minimum price: ');
        max_price = input('Enter maximum price: ');
        if isempty(min_price) || isempty(max_price) || ~isnumeric(min_price) || ~isnumeric(max_price)
            fprintf('Invalid price range.\n');
            return;
        end
        range_name = sprintf('$%.2f-$%.2f', min_price, max_price);
    end
    
    % Find matching games
    if isinf(max_price)
        matches = find(data.Price >= min_price);
    elseif min_price == 0 && max_price == 0
        matches = find(data.Price == 0);
    else
        matches = find(data.Price >= min_price & data.Price <= max_price);
    end
    
    if isempty(matches)
        fprintf('\nNo games found in price range: %s\n', range_name);
    else
        % Sort by rating (handle NaN by moving to end)
        match_ratings = data.Rating(matches);
        match_ratings(isnan(match_ratings)) = -1;  % Move NaN to end
        [~, sort_idx] = sort(match_ratings, 'descend');
        matches = matches(sort_idx);
        
        fprintf('\nFound %d game(s) in price range %s:\n\n', length(matches), range_name);
        fprintf('%-4s %-45s %-8s %-10s %7s\n', 'No.', 'Game', 'Price', 'Rating', 'Reviews');
        fprintf('%s\n', repmat('─', 1, 85));
        
        for i = 1:min(25, length(matches))  % Show top 25
            idx = matches(i);
            game_name = truncate_string(data.Name{idx}, 45);
            price = data.Price(idx);
            rating = data.Rating(idx);
            reviews = data.TotalReviews(idx);
            
            fprintf('%-4d %-45s $%7.2f %8.1f%% %7s\n', ...
                    i, game_name, price, rating, format_number(reviews));
        end
        
        if length(matches) > 25
            fprintf('\n... and %d more results (sorted by rating)\n', length(matches) - 25);
        end
    end
    
    pause_continue();
end

function dataset_stats(data)
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║              DATASET STATISTICS SUMMARY                ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    fprintf('GENERAL INFORMATION\n');
    fprintf('%s\n', repmat('─', 1, 60));
    fprintf('  Total games in dataset:     %d\n', data.count);
    fprintf('  Data source:                Famous games (curated)\n');
    fprintf('  Data columns:               %d\n', 8);
    
    fprintf('\nPRICE STATISTICS\n');
    fprintf('%s\n', repmat('─', 1, 60));
    prices = data.Price;
    prices(isnan(prices)) = 0;
    fprintf('  Average price:              $%.2f\n', mean(prices));
    fprintf('  Median price:               $%.2f\n', median(prices));
    fprintf('  Min price:                  $%.2f\n', min(prices));
    fprintf('  Max price:                  $%.2f\n', max(prices));
    fprintf('  Free games:                 %d (%.1f%%)\n', sum(prices == 0), 100*sum(prices == 0)/data.count);
    fprintf('  Paid games:                 %d (%.1f%%)\n', sum(prices > 0), 100*sum(prices > 0)/data.count);
    
    fprintf('\nRATING STATISTICS\n');
    fprintf('%s\n', repmat('─', 1, 60));
    ratings = data.Rating;
    valid_ratings = ratings(~isnan(ratings));
    fprintf('  Average rating:             %.2f%%\n', mean(valid_ratings));
    fprintf('  Median rating:              %.2f%%\n', median(valid_ratings));
    fprintf('  Std deviation:              %.2f%%\n', std(valid_ratings));
    fprintf('  Min rating:                 %.2f%%\n', min(valid_ratings));
    fprintf('  Max rating:                 %.2f%%\n', max(valid_ratings));
    fprintf('  Games with 90%%+ rating:     %d (%.1f%%%%)\n', sum(valid_ratings >= 90), 100*sum(valid_ratings >= 90)/length(valid_ratings));
    
    fprintf('\nREVIEW STATISTICS\n');
    fprintf('%s\n', repmat('─', 1, 60));
    reviews = data.TotalReviews;
    fprintf('  Total reviews (all games):  %s\n', format_number(sum(reviews)));
    fprintf('  Average reviews per game:   %s\n', format_number(mean(reviews)));
    fprintf('  Median reviews:             %s\n', format_number(median(reviews)));
    fprintf('  Max reviews:                %s\n', format_number(max(reviews)));
    fprintf('  Positive reviews:           %s (%.1f%%)\n', format_number(sum(data.Positive)), 100*sum(data.Positive)/sum(reviews));
    fprintf('  Negative reviews:           %s (%.1f%%)\n', format_number(sum(data.Negative)), 100*sum(data.Negative)/sum(reviews));
    
    fprintf('\nCONTENT STATISTICS\n');
    fprintf('%s\n', repmat('─', 1, 60));
    unique_devs = unique(data.Developers);
    unique_genres = unique(data.Genres);
    fprintf('  Unique developers:          %d\n', length(unique_devs));
    fprintf('  Unique genre combinations:  %d\n', length(unique_genres));
    fprintf('  Avg games per developer:    %.1f\n', data.count / length(unique_devs));
    
    % Top developer
    dev_counts = zeros(length(unique_devs), 1);
    for i = 1:length(unique_devs)
        dev_counts(i) = sum(strcmp(data.Developers, unique_devs{i}));
    end
    [max_count, max_idx] = max(dev_counts);
    fprintf('  Most prolific developer:    %s (%d games)\n', unique_devs{max_idx}, max_count);
    
    % Find most reviewed game
    [max_reviews, max_rev_idx] = max(reviews);
    fprintf('\nHIGHLIGHTS\n');
    fprintf('%s\n', repmat('─', 1, 60));
    fprintf('  Most reviewed game:         %s\n', data.Name{max_rev_idx});
    fprintf('                              %s reviews\n', format_number(max_reviews));
    
    % Find highest rated (with min 100 reviews)
    high_review_idx = reviews >= 100;
    if any(high_review_idx)
        valid_ratings_hr = ratings(high_review_idx);
        [max_rating, max_rat_idx] = max(valid_ratings_hr);
        high_review_indices = find(high_review_idx);
        fprintf('  Highest rated (100+ reviews): %s\n', data.Name{high_review_indices(max_rat_idx)});
        fprintf('                                %.1f%% rating\n', max_rating);
    end
    
    % Find most expensive
    [max_price, max_price_idx] = max(prices);
    fprintf('  Most expensive game:        %s\n', data.Name{max_price_idx});
    fprintf('                              $%.2f\n', max_price);
    
    fprintf('\n');
    pause_continue();
end

% ========== UTILITY FUNCTIONS ==========

function result = safe_mean_rating(data, idx)
    % Calculate mean rating safely (handle NaN and empty)
    if ~any(idx)
        result = NaN;
        return;
    end
    
    ratings = data.Rating(idx);
    ratings = ratings(~isnan(ratings));
    
    if isempty(ratings)
        result = NaN;
    else
        result = mean(ratings);
    end
end

function str = truncate_string(str, max_len)
    % Truncate string to max length with ellipsis
    if length(str) > max_len
        str = [str(1:max_len-3) '...'];
    end
end

function str = format_number(num)
    % Format large numbers with K/M suffixes
    if num >= 1000000
        str = sprintf('%.1fM', num / 1000000);
    elseif num >= 1000
        str = sprintf('%.1fK', num / 1000);
    else
        str = sprintf('%d', round(num));
    end
end

function pause_continue()
    % Wait for user to continue
    fprintf('\n');
    input('Press Enter to return to menu...', 's');
end

% ========== STUDIO COMPARISON FUNCTION ==========

function studio_comparison()
    fprintf('\n');
    fprintf('╔════════════════════════════════════════════════════════╗\n');
    fprintf('║        STUDIO COMPARISON: INDIE vs MID-TIER vs AAA     ║\n');
    fprintf('╚════════════════════════════════════════════════════════╝\n\n');
    
    fprintf('This analysis compares successful games from:\n');
    fprintf('  • Indie studios (101 games)\n');
    fprintf('  • Mid-tier studios (40 games)\n');
    fprintf('  • AAA studios (199 games)\n\n');
    
    fprintf('Available visualizations:\n');
    fprintf('  1. Pricing Strategy Comparison\n');
    fprintf('  2. Quality & Engagement Metrics\n');
    fprintf('  3. Playtime & Content Features\n');
    fprintf('  4. Platform Support Strategy\n');
    fprintf('  5. View All Panels\n');
    fprintf('  0. Back to Main Menu\n\n');
    
    sub_choice = input('Your choice (0-5): ');
    
    if isempty(sub_choice) || ~isnumeric(sub_choice)
        fprintf('\nInvalid input!\n');
        return;
    end
    
    image_paths = {
        '../../outputs/images/studio_panel1_pricing.png',
        '../../outputs/images/studio_panel2_quality.png',
        '../../outputs/images/studio_panel3_content.png',
        '../../outputs/images/studio_panel4_platforms.png'
    };
    
    titles = {
        'Panel 1: Pricing Strategy (Indie vs Mid-tier vs AAA)',
        'Panel 2: Quality & Engagement Metrics',
        'Panel 3: Playtime & Content Features',
        'Panel 4: Platform Support Strategy'
    };
    
    if sub_choice == 0
        return;
    elseif sub_choice >= 1 && sub_choice <= 4
        % Show single panel
        if exist(image_paths{sub_choice}, 'file')
            fprintf('\nDisplaying %s...\n', titles{sub_choice});
            img = imread(image_paths{sub_choice});
            figure('Position', [100, 100, 1400, 900], 'Name', titles{sub_choice});
            imshow(img);
            title(titles{sub_choice}, 'FontSize', 16, 'FontWeight', 'bold');
        else
            fprintf('\n⚠️  Image not found: %s\n', image_paths{sub_choice});
            fprintf('Please run: octave --eval "run_studio_panels" from octave/ directory\n');
        end
    elseif sub_choice == 5
        % Show all panels
        fprintf('\nDisplaying all studio comparison panels...\n');
        for i = 1:4
            if exist(image_paths{i}, 'file')
                img = imread(image_paths{i});
                figure('Position', [100 + (i-1)*50, 100 + (i-1)*50, 1400, 900], 'Name', titles{i});
                imshow(img);
                title(titles{i}, 'FontSize', 16, 'FontWeight', 'bold');
            else
                fprintf('⚠️  Missing: %s\n', titles{i});
            end
        end
    else
        fprintf('\nInvalid choice!\n');
    end
    
    pause_continue();
end
