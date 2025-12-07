% PLAYTIME PANEL 4: FACETED BY GENRE
% Playtime-Success relationship across different genres (similar style to price panel 6)

clear all; close all; clc;

% Load required packages
pkg load statistics;

% Load data
data = csvread('playtime_data.csv', 1, 0);

Playtime = data(:, 1);
PositiveRate = data(:, 2);
LogPlaytime = data(:, 3);
GenreCategory = data(:, 5);

fprintf('Playtime Panel 4: Faceted by Genre...\n');

% Filter to 0-2000 hours
mask = Playtime <= 2000;
Playtime_filt = Playtime(mask);
PositiveRate_filt = PositiveRate(mask);
LogPlaytime_filt = LogPlaytime(mask);
GenreCategory_filt = GenreCategory(mask);

% Genre labels
genre_labels = {'Indie', 'Action', 'Adventure', 'Casual'};
genres = [0, 1, 2, 3];

% Create figure with 2x2 subplot
figure('Position', [100, 100, 1400, 1000]);
set(gcf, 'Color', [0.97, 0.97, 0.97]);

% Colors for each genre
colors = [
    0.3, 0.6, 0.9;   % Indie - blue
    0.9, 0.3, 0.3;   % Action - red
    0.3, 0.8, 0.5;   % Adventure - green
    0.9, 0.6, 0.2    % Casual - orange
];

for i = 1:length(genres)
    subplot(2, 2, i);
    
    % Filter data for this genre
    genre_mask = GenreCategory_filt == genres(i);
    genre_playtime = LogPlaytime_filt(genre_mask);
    genre_rate = PositiveRate_filt(genre_mask);
    
    if length(genre_playtime) > 50
        % Scatter plot
        scatter(genre_playtime, genre_rate, 20, colors(i,:), 'filled', ...
                'MarkerFaceAlpha', 0.4, 'MarkerEdgeColor', 'none');
        hold on;
        
        % Calculate trend line (bin-based median)
        n_bins = 30;
        bin_edges = linspace(min(genre_playtime), max(genre_playtime), n_bins);
        trend_x = [];
        trend_y = [];
        
        for j = 1:(n_bins-1)
            bin_mask = genre_playtime >= bin_edges(j) & genre_playtime < bin_edges(j+1);
            if sum(bin_mask) >= 10
                trend_x(end+1) = mean(genre_playtime(bin_mask));
                trend_y(end+1) = median(genre_rate(bin_mask));
            end
        end
        
        if length(trend_x) > 3
            % Smooth and plot trend
            if length(trend_y) >= 5
                trend_y_smooth = movmean(trend_y, 5);
                plot(trend_x, trend_y_smooth, '-', 'Color', colors(i,:), 'LineWidth', 3.5);
            else
                plot(trend_x, trend_y, '-', 'Color', colors(i,:), 'LineWidth', 3.5);
            end
        end
        
        % Refund zone marker
        refund_log = log10(2 + 1);
        plot([refund_log, refund_log], [0, 100], '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 2);
        
        % Correlation
        r = corr(genre_playtime, genre_rate);
        text(min(genre_playtime) + 0.2, 10, sprintf('r = %.3f', r), ...
             'FontSize', 11, 'FontWeight', 'bold', 'BackgroundColor', 'white', ...
             'EdgeColor', 'black', 'LineWidth', 1);
        
        % Subplot title
        title(sprintf('%s Games (n=%d)', genre_labels{i}, length(genre_playtime)), ...
              'FontSize', 16, 'FontWeight', 'bold', 'Color', colors(i,:));
        
        % Labels
        xlabel('Median Playtime (log scale)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Success Rate (%)', 'FontSize', 12, 'FontWeight', 'bold');
        
        % Format x-axis
        xticks_pos = get(gca, 'XTick');
        xticks_lab = {};
        for k = 1:length(xticks_pos)
            hours = round(10^xticks_pos(k) - 1);
            if hours < 1
                xticks_lab{k} = '<1h';
            else
                xticks_lab{k} = sprintf('%dh', hours);
            end
        end
        set(gca, 'XTickLabel', xticks_lab);
        
        % Styling
        grid on;
        set(gca, 'GridAlpha', 0.15);
        set(gca, 'FontSize', 11);
        set(gca, 'Color', [1, 1, 1]);
        set(gca, 'LineWidth', 1.5);
        ylim([0, 100]);
        
        fprintf('  %s: r=%.3f, n=%d\n', genre_labels{i}, r, length(genre_playtime));
    end
end

% Overall title
annotation('textbox', [0.1, 0.96, 0.8, 0.03], ...
           'String', 'Playtime vs Success Rate by Genre (0-2000h)', ...
           'EdgeColor', 'none', 'FontSize', 18, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center');

% Save
print -dpng -r300 'playtime_panel4_facet_by_genre.png';
fprintf('✅ Playtime Panel 4 saved: playtime_panel4_facet_by_genre.png\n');

% Analysis
fprintf('\n📊 GENRE COMPARISON:\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('• Different genres show different playtime patterns\n');
fprintf('• Correlations vary by genre\n');
fprintf('• Refund zone impact differs across genres\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
