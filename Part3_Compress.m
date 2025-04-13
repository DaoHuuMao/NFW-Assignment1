% Non-linear Frequency Warping (NFW) Compression
% Author: [Lê Hoàng Anh]
% Description: Audio compression using NFW algorithm

% Ví dụ sử dụng
input_file = 'recorded.wav';  % File âm thanh đầu vào
output_file = 'compressed_data.mat';  % File nén đầu ra

compress_NFW(input_file, output_file);

function compress_NFW(input_file, output_file)
    try
        %% 1. Read audio and STFT
        [x, fs] = audioread(input_file);
        x = x(:,1); % mono

        % STFT parameters
        frame_length = 2048;
        hop_length = frame_length / 2;
        window = hamming(frame_length, 'periodic');

        num_frames = floor((length(x) - frame_length)/hop_length) + 1;
        stft_matrix = zeros(frame_length, num_frames);

        for i = 1:num_frames
            idx = (i-1)*hop_length + 1;
            frame = x(idx : idx + frame_length -1);
            X = fft(frame .* window);
            stft_matrix(:,i) = X;
        end

        %% 2. Non-linear Frequency Warping (Mel)
        half_len = frame_length/2 + 1;
        f = linspace(0, fs/2, half_len);
        mel_f = 2595 * log10(1 + f/700);
        mel_f_norm = mel_f / max(mel_f) * half_len;
        warped_idx = round(mel_f_norm);
        warped_idx(warped_idx < 1) = 1;

        mag_matrix = abs(stft_matrix(1:half_len,:));
        phase_matrix = angle(stft_matrix(1:half_len,:));

        mel_mag = zeros(half_len, num_frames);
        mel_counts = zeros(half_len, 1);

        for i = 1:num_frames
            temp = zeros(half_len,1);
            counts = zeros(half_len,1);
            for j = 1:half_len
                idx = warped_idx(j);
                temp(idx) = temp(idx) + mag_matrix(j,i);
                counts(idx) = counts(idx) + 1;
            end
            counts(counts==0) = 1;
            mel_mag(:,i) = temp ./ counts;
        end

        %% 3. Quantization
        mag_bits = 6; phase_bits = 4;
        mag_levels = 2^mag_bits;
        phase_levels = 2^phase_bits;

        max_mag = max(mel_mag(:));
        Q_mag = uint8(round(mel_mag / max_mag * (mag_levels - 1)));
        Q_phase = uint8(round((phase_matrix + pi) / (2*pi) * (phase_levels - 1)));

        %% 4. Save compressed
        compressed.Q_mag = Q_mag;
        compressed.Q_phase = Q_phase;
        compressed.max_mag = max_mag;
        compressed.fs = fs;
        compressed.frame_length = frame_length;
        compressed.hop_length = hop_length;
        compressed.mag_bits = mag_bits;
        compressed.phase_bits = phase_bits;

        save(output_file, '-struct', 'compressed', '-v7');

        %% 5. Compression ratio
        original_bits = length(x) * 16; % 16-bit PCM
        compressed_bits = numel(Q_mag)*mag_bits + numel(Q_phase)*phase_bits;
        compression_ratio = original_bits / compressed_bits;

        fprintf("=== Compression Information ===\n");
        fprintf("Original size: %d bits\n", original_bits);
        fprintf("Compressed size: %d bits\n", compressed_bits);
        fprintf("Compression ratio: %.2f:1\n", compression_ratio);

    catch ME
        fprintf("Error in compression: %s\n", ME.message);
    end
end
