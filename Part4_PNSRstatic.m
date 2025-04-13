% Non-linear Frequency Warping (NFW) Decompression
% Author: [Đào Hữu Mão]
% Description: Compare PNSR value between NFW and MP3

input_file = 'recorded.wav';
compare_compression_quality(input_file);

function compare_compression_quality(input_file)
    try
        %% 1. Load Original Audio
        [original, fs] = audioread(input_file);
        original = original(:,1);  % Convert to mono if stereo
        
        %% 2. Load NFW Compressed Audio
        % Load decompressed NFW audio
        decompressed_nfw_file = 'decompressed.wav';
        if ~exist(decompressed_nfw_file, 'file')
            error('File giải nén NFW không tồn tại. Vui lòng chạy hàm decompress_NFW trước.');
        end
        [nfw_audio, ~] = audioread(decompressed_nfw_file);
        nfw_audio = nfw_audio(:,1);  % Convert to mono if stereo
        
        %% 3. Load MP3 Audio       
        % Load MP3 audio
        mp3_file = 'recorded.mp3';
        [mp3_audio, ~] = audioread(mp3_file);
        mp3_audio = mp3_audio(:,1);  % Convert to mono if stereo
        
        %% 4. Ensure All Audio Signals Have Same Length
        min_length = min([length(original), length(nfw_audio), length(mp3_audio)]);
        original = original(1:min_length);
        nfw_audio = nfw_audio(1:min_length);
        mp3_audio = mp3_audio(1:min_length);
        
        %% 5. Calculate PSNR
        % Calculate PSNR for NFW
        nfw_mse = mean((original - nfw_audio).^2);
        if nfw_mse == 0
            nfw_psnr = Inf;
        else
            nfw_psnr = 10 * log10(1 / nfw_mse);
        end
        
        % Calculate PSNR for MP3
        mp3_mse = mean((original - mp3_audio).^2);
        if mp3_mse == 0
            mp3_psnr = Inf;
        else
            mp3_psnr = 10 * log10(1 / mp3_mse);
        end
        
        %% 6. Calculate Compression Ratios
        % Original file size
        original_info = dir(input_file);
        original_size = original_info.bytes * 8;  % Convert to bits
        
        % NFW compressed size
        compressed_nfw_file = 'compressed_data.mat';
        if ~exist(compressed_nfw_file, 'file')
            error('File nén NFW không tồn tại. Vui lòng chạy hàm compress_NFW trước.');
        end
        nfw_info = dir(compressed_nfw_file);
        nfw_size = nfw_info.bytes * 8;  % Convert to bits
        nfw_ratio = original_size / nfw_size;
        
        % MP3 compressed size
        mp3_info = dir(mp3_file);
        mp3_size = mp3_info.bytes * 8;  % Convert to bits
        mp3_ratio = original_size / mp3_size;
        
        %% 7. Display Results
        fprintf('=== Compression Quality Comparison ===\n');
        fprintf('Original file: %s\n', input_file);
        fprintf('Original size: %d bits\n', original_size);
        fprintf('\n');
        
        fprintf('NFW Compression:\n');
        fprintf('  Compressed size: %d bits\n', nfw_size);
        fprintf('  Compression ratio: %.2f:1\n', nfw_ratio);
        fprintf('  PSNR: %.2f dB\n', nfw_psnr);
        fprintf('\n');
        
        fprintf('MP3 Compression:\n');
        fprintf('  Compressed size: %d bits\n', mp3_size);
        fprintf('  Compression ratio: %.2f:1\n', mp3_ratio);
        fprintf('  PSNR: %.2f dB\n', mp3_psnr);
        
        % So sánh kết quả
        fprintf('\n=== Comparison Summary ===\n');
        if nfw_psnr > mp3_psnr
            fprintf('NFW has better quality (PSNR: %.2f dB > %.2f dB)\n', nfw_psnr, mp3_psnr);
        elseif mp3_psnr > nfw_psnr
            fprintf('MP3 has better quality (PSNR: %.2f dB > %.2f dB)\n', mp3_psnr, nfw_psnr);
        else
            fprintf('Both methods have the same quality (PSNR: %.2f dB)\n', nfw_psnr);
        end
        
        if nfw_ratio > mp3_ratio
            fprintf('NFW has better compression ratio (%.2f:1 > %.2f:1)\n', nfw_ratio, mp3_ratio);
        elseif mp3_ratio > nfw_ratio
            fprintf('MP3 has better compression ratio (%.2f:1 > %.2f:1)\n', mp3_ratio, nfw_ratio);
        else
            fprintf('Both methods have the same compression ratio (%.2f:1)\n', nfw_ratio);
        end
        
        %% 8. Visual Comparison
        % Create time-domain plots
        figure;
        subplot(3,1,1);
        plot(original);
        title('Original Audio');
        xlabel('Sample');
        ylabel('Amplitude');
        
        subplot(3,1,2);
        plot(nfw_audio);
        title('NFW Compressed Audio');
        xlabel('Sample');
        ylabel('Amplitude');
        
        subplot(3,1,3);
        plot(mp3_audio);
        title('MP3 Compressed Audio');
        xlabel('Sample');
        ylabel('Amplitude');
        
        % Create frequency-domain plots
        figure;
        subplot(3,1,1);
        plot_spectrum(original, fs);
        title('Original Audio Spectrum');
        
        subplot(3,1,2);
        plot_spectrum(nfw_audio, fs);
        title('NFW Compressed Audio Spectrum');
        
        subplot(3,1,3);
        plot_spectrum(mp3_audio, fs);
        title('MP3 Compressed Audio Spectrum');
        
        % Create error plots
        figure;
        subplot(2,1,1);
        plot(original - nfw_audio);
        title('Error: Original - NFW');
        xlabel('Sample');
        ylabel('Amplitude');
        
        subplot(2,1,2);
        plot(original - mp3_audio);
        title('Error: Original - MP3');
        xlabel('Sample');
        ylabel('Amplitude');
        
        %% 9. Play Audio for Comparison
        %disp('Playing original audio...');
        %sound(original, fs);
        %pause(length(original)/fs + 1);
        
        %disp('Playing NFW compressed audio...');
        %sound(nfw_audio, fs);
        %pause(length(nfw_audio)/fs + 1);
        
        %disp('Playing MP3 compressed audio...');
        %sound(mp3_audio, fs);
        
    catch ME
        fprintf('Error in comparison: %s\n', ME.message);
        fprintf('Stack trace:\n');
        disp(ME.stack);
        rethrow(ME);
    end
end

function plot_spectrum(x, fs)
    % Calculate spectrum
    N = length(x);
    X = fft(x);
    f = linspace(0, fs/2, N/2+1);
    
    % Plot magnitude spectrum
    plot(f, 2*abs(X(1:N/2+1))/N);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    xlim([0 min(20000, fs/2)]);
end
