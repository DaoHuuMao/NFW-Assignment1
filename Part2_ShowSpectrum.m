% Audio Spectrum Analysis Script
% Author: [Phạm Thị Thanh Trúc]
% Description: Script for analyzing audio spectrum and compression

%% 1. Load Audio File
[y, fs] = audioread('recorded.wav');
y = y(:,1);  % Convert to mono if stereo

%% 2. Spectrum Analysis
% Calculate FFT
N = length(y);
Y = fft(y);
f = linspace(0, fs, N);

% Create figure with subplots
figure('Name', 'Audio Spectrum Analysis', 'Position', [100 100 1200 800]);

% Plot 1: Time Domain Signal
subplot(2,1,1);
t = (0:N-1)/fs;
plot(t, y);
xlabel('Thời gian (s)');
ylabel('Biên độ');
title('Tín hiệu âm thanh gốc');
grid on;

% Plot 2: Frequency Spectrum
subplot(2,1,2);
plot(f(1:N/2), abs(Y(1:N/2)));
xlabel('Tần số (Hz)');
ylabel('Biên độ');
title('Phổ tần số của tín hiệu âm thanh');
grid on;

%% 3. Frequency Band Analysis
% Define frequency bands
bands = [0 100; 100 500; 500 2000; 2000 8000; 8000 fs/2];
band_names = {'0-100 Hz', '100-500 Hz', '500-2000 Hz', '2000-8000 Hz', '8000+ Hz'};
energy_bands = zeros(length(bands), 1);

% Calculate energy in each band
for i = 1:length(bands)
    band_indices = f >= bands(i,1) & f <= bands(i,2);
    energy_bands(i) = sum(abs(Y(band_indices)).^2);
end

% Normalize energy
energy_bands = energy_bands / sum(energy_bands) * 100;

% Display energy distribution
disp('=== Phân bố năng lượng theo dải tần ===');
for i = 1:length(bands)
    fprintf('%s: %.2f%%\n', band_names{i}, energy_bands(i));
end

