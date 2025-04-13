% Non-linear Frequency Warping (NFW) Decompression
% Author: [Lê Hoàng Anh]
% Description: Reconstruct audio from NFW-compressed .mat file

%% ================= MAIN ==================
input_file = 'compressed_data.mat';
output_file = 'decompressed.wav';

decompress_NFW(input_file, output_file);

% Nghe thử âm thanh
[original, fs] = audioread('recorded.wav');
[recon, ~] = audioread(output_file);

disp('Playing original audio...');
sound(original, fs);
pause(length(original)/fs + 1);

disp('Playing decompressed audio...');
sound(recon, fs);

%% ================= FUNCTION =================
function decompress_NFW(input_file, output_file)
    try
        %% 1. Load compressed data
        data = load(input_file);

        Q_mag = double(data.Q_mag);
        Q_phase = double(data.Q_phase);
        fs = data.fs;
        frame_length = data.frame_length;
        hop_length = data.hop_length;
        mag_bits = data.mag_bits;
        phase_bits = data.phase_bits;
        max_mag = data.max_mag;

        [num_bins, num_frames] = size(Q_mag);  % num_bins = half_len (i.e. frame_length/2+1)

        %% 2. Dequantize magnitude and phase
        mag_levels = 2^mag_bits;
        phase_levels = 2^phase_bits;
        
        % Dequantization theo lượng tử hóa đã áp dụng trong nén
        mag = Q_mag / (mag_levels - 1) * max_mag;
        phase = Q_phase / (phase_levels - 1) * 2*pi - pi;

        %% 3. Inverse warping (De-warping)
        % Tái tạo lại mapping đã dùng trong quá trình nén
        half_len = frame_length/2 + 1;
        f = linspace(0, fs/2, half_len);
        mel_f = 2595 * log10(1 + f/700);              % Chuyển sang thang Mel
        mel_f_norm = mel_f / max(mel_f) * half_len;     % Chuẩn hóa (lưu ý: ở compress bạn dùng nhân với half_len)
        warped_idx = round(mel_f_norm);                 % Lấy chỉ số đã warping
        warped_idx(warped_idx < 1) = 1;                  % Đảm bảo không có giá trị nhỏ hơn 1

        % Vì trong quá trình nén, đối với mỗi frame, các giá trị FFT (mag & phase)
        % của từng bin tuyến tính được gộp lại theo chỉ số warping.
        % Ở bước giải nén, ta sẽ "nội suy" lại một vector kích thước ban đầu (half_len)
        % từ dữ liệu đã warping.
        linear_mag = zeros(half_len, num_frames);
        linear_phase = zeros(half_len, num_frames);
        % Ta dùng nội suy: với trục x gốc là 1:half_len và giá trị là warped_idx,
        % ta tìm vị trí liên tục ứng với mỗi bin tuyến tính (j)
        for i = 1:num_frames
            for j = 1:half_len
                % Xác định vị trí warped tương ứng với bin thứ j
                warped_coord = interp1(1:half_len, warped_idx, j, 'linear', 'extrap');
                % Nội suy biên độ và pha từ dữ liệu đã nén
                linear_mag(j,i) = interp1(1:half_len, mag(:,i), warped_coord, 'linear', 'extrap');
                linear_phase(j,i) = interp1(1:half_len, phase(:,i), warped_coord, 'linear', 'extrap');
            end
        end

        %% 4. Reconstruct full spectrum for ISTFT
        spec_half = linear_mag .* exp(1j * linear_phase);
        full_len = (half_len - 1) * 2;
        % Duy trì tính chất đối xứng phức (Conjugate symmetry) của FFT cho tín hiệu thực
        spec_full = [spec_half; conj(flipud(spec_half(2:end-1,:)))];

        %% 5. Inverse STFT using Overlap-Add
        window = hamming(frame_length, 'periodic');
        output_len = (num_frames - 1) * hop_length + frame_length;
        y = zeros(output_len, 1);
        win_sum = zeros(output_len, 1);

        for i = 1:num_frames
            frame = real(ifft(spec_full(:,i)));   % Lấy phần thực của IFFT
            frame = frame .* window;                % Áp dụng window
            idx = (i - 1) * hop_length + 1;
            y(idx:idx + frame_length - 1) = y(idx:idx + frame_length - 1) + frame;
            win_sum(idx:idx + frame_length - 1) = win_sum(idx:idx + frame_length - 1) + window;
        end

        y = y ./ (win_sum + 1e-6);  % Tránh chia cho 0, chuẩn hóa tín hiệu
        y = y / max(abs(y));        % Chuẩn hóa biên độ để tránh clipping

        %% 6. Save decompressed audio to file
        audiowrite(output_file, y, fs);

        %% 7. Print decompression info
        fprintf('=== Decompression Information ===\n');
        fprintf('Input file: %s\n', input_file);
        fprintf('Output file: %s\n', output_file);
        fprintf('Sampling frequency: %d Hz\n', fs);
        fprintf('Frames: %d | Frame length: %d | Hop: %d\n', num_frames, frame_length, hop_length);
        fprintf('Magnitude bits: %d | Phase bits: %d\n', mag_bits, phase_bits);
        fprintf('Output duration: %.2f sec\n', length(y)/fs);

    catch ME
        fprintf('❌ Error in decompression: %s\n', ME.message);
        disp(ME.stack);
    end
end
