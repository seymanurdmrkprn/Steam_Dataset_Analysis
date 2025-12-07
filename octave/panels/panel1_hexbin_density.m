% PANEL 1: HEXBIN YOĞUNLUK HARİTASI
% Fiyat-Positive Rate ilişkisinin yoğunluk analizi

clear all; close all; clc;

% Gerekli paketleri yükle
pkg load statistics;

% Veriyi yükle
data = csvread('octave_data.csv', 1, 0);  % İlk satırı (header) atla

Price = data(:, 1);
PositiveRate = data(:, 2);

fprintf('Panel 1: Price vs Success Rate visualization...\n');
fprintf('Total data points: %d\n', length(Price));

% Basit scatter plot (daha anlaşılır)
figure('Position', [100, 100, 1400, 900]);

% Arka plan rengi (hafif gri)
set(gcf, 'Color', [0.97, 0.97, 0.97]);

% Scatter plot - daha güzel renkler
scatter(Price, PositiveRate, 25, [0.2, 0.4, 0.75], 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none');
hold on;

% Ortalama çizgileri ekle (daha estetik renkler)
mean_price = mean(Price);
mean_rate = mean(PositiveRate);

% Dikey çizgi (ortalama fiyat) - turuncu
plot([mean_price, mean_price], [0, 105], '--', 'Color', [0.9, 0.5, 0.1], 'LineWidth', 2.5, 'DisplayName', sprintf('Avg. Price: $%.2f', mean_price));

% Yatay çizgi (ortalama başarı) - mor
plot([0, 80], [mean_rate, mean_rate], '--', 'Color', [0.6, 0.2, 0.7], 'LineWidth', 2.5, 'DisplayName', sprintf('Avg. Score: %.1f%%', mean_rate));

% Korelasyon hesapla
correlation = corr(Price, PositiveRate);

% Başlık ve etiketler
title(sprintf('Price vs Success Rate - %s Steam Games', num2str(length(Price), '%d')), ...
      'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
xlabel('Price (USD)', 'FontSize', 17, 'FontWeight', 'bold');
ylabel('Success Rate (% Positive Reviews)', 'FontSize', 17, 'FontWeight', 'bold');

set(gca, 'FontSize', 14);
set(gca, 'Color', [1, 1, 1]);  % Beyaz grafik arka planı
set(gca, 'LineWidth', 1.5);

% Grid - estetik
grid on;
set(gca, 'GridAlpha', 0.15);
set(gca, 'GridLineStyle', '-');

ylim([0, 105]);
xlim([0, 80]);  % 0-80 dolar arası

% Legend - daha şık
leg = legend('Location', 'southeast', 'FontSize', 13);
set(leg, 'Box', 'on');
set(leg, 'EdgeColor', [0.7, 0.7, 0.7]);

% Kaydet
print -dpng -r300 'panel1_hexbin_density.png';
fprintf('✅ Panel 1 saved: panel1_hexbin_density.png\n');
fprintf('   Correlation: %.3f\n', correlation);

% Ana bulgular
fprintf('\n📊 ANALYSIS RESULTS:\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('• Average price: $%.2f\n', mean_price);
fprintf('• Average success: %.1f%%\n', mean_rate);
fprintf('• Correlation: %.3f\n', correlation);
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

if correlation > 0.10
    fprintf('✓ Price increases → Success increases (weak positive)\n');
elseif correlation < -0.10
    fprintf('✓ Price increases → Success decreases (negative)\n');
else
    fprintf('→ No significant correlation between price and success\n');
end
fprintf('\n');
