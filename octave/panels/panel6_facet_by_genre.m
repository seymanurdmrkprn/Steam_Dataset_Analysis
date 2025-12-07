% PANEL 6: ANALYSIS BY GENRE
% Price-success relationship by game genre

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('octave_data.csv', 1, 0);

Price = data(:, 1);
PositiveRate = data(:, 2);
PriceCategory = data(:, 3);
MainGenre = data(:, 4);

fprintf('Panel 6: Genre Comparison Analysis...\n');

% Genre names
genre_labels = {'Indie', 'Action', 'Casual', 'Adventure'};

% Color palette
color_palette = [
    120, 100, 200;
    100, 160, 225;
    200, 150, 100;
    150, 180, 120
] / 255;

% Create 2x2 grid
figure('Position', [100, 100, 1400, 1100]);
set(gcf, 'Color', [0.97, 0.97, 0.97]);

% Analyze first 4 genres
for g = 1:4
    subplot(2, 2, g);
    
    % Filter data for this genre
    genre_mask = (MainGenre == (g-1));
    genre_price = Price(genre_mask);
    genre_rate = PositiveRate(genre_mask);
    
    if length(genre_price) > 10
        % Filter to 0-80 USD range
        price_mask = genre_price <= 80;
        genre_price = genre_price(price_mask);
        genre_rate = genre_rate(price_mask);
        
        % Scatter plot
        scatter(genre_price, genre_rate, 15, color_palette(g,:), ...
               'filled', 'MarkerFaceAlpha', 0.4);
        hold on;
        
        % Smooth trend line
        n_points = 50;
        price_smooth = linspace(0, 80, n_points);
        rate_smooth = zeros(size(price_smooth));
        
        window_size = max(10, length(genre_price) * 0.15);
        
        for i = 1:n_points
            distances = abs(genre_price - price_smooth(i));
            [~, sorted_idx] = sort(distances);
            window_idx = sorted_idx(1:min(round(window_size), length(genre_price)));
            rate_smooth(i) = mean(genre_rate(window_idx));
        end
        
        % Plot trend
        plot(price_smooth, rate_smooth, '-', 'Color', color_palette(g,:), 'LineWidth', 3);
        
        % Calculate correlation
        correlation = corr(genre_price, genre_rate);
        
        % Title
        title(sprintf('%s Games (r=%.2f, n=%d)', genre_labels{g}, correlation, length(genre_price)), ...
              'FontSize', 15, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
        
        xlabel('Price (USD)', 'FontSize', 13, 'FontWeight', 'bold');
        ylabel('Success Rate (%)', 'FontSize', 13, 'FontWeight', 'bold');
        
        xlim([0, 80]);
        ylim([0, 105]);
        grid on;
        set(gca, 'GridAlpha', 0.15);
        set(gca, 'FontSize', 12);
        set(gca, 'Color', [1, 1, 1]);
        set(gca, 'LineWidth', 1.5);
        
        fprintf('  %12s: Correlation=%.3f, N=%d\n', genre_labels{g}, correlation, length(genre_price));
    else
        title(sprintf('%s (Insufficient Data)', genre_labels{g}), 'FontSize', 15);
        text(0.5, 0.5, 'N < 10', 'HorizontalAlignment', 'center', ...
             'FontSize', 16, 'Color', 'red');
    end
end

% Add overall title using annotation
annotation('textbox', [0, 0.95, 1, 0.05], ...
           'String', 'Price-Success Relationship by Game Genre', ...
           'EdgeColor', 'none', ...
           'HorizontalAlignment', 'center', ...
           'FontSize', 22, ...
           'FontWeight', 'bold', ...
           'Color', [0.2, 0.2, 0.2]);

% Save
print -dpng -r300 'panel6_genre_comparison.png';
fprintf('✅ Panel 6 saved: panel6_genre_comparison.png\n');
