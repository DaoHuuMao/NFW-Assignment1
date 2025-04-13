[y1, fs1] = audioread('recorded.wav');
[y2, fs2] = audioread('midi_output.wav');

% Chuyển về mono nếu cần
if size(y1,2) > 1
    y1 = mean(y1, 2);
end
if size(y2,2) > 1
    y2 = mean(y2, 2);
end

% Cắt đến độ dài nhỏ nhất
min_len = min(length(y1), length(y2));
y1 = y1(1:min_len);
y2 = y2(1:min_len);

% Mix với hệ số 0.5 để tránh clipping
mixed = y1 + 0.5 * y2;
mixed = mixed / max(abs(mixed)); % Chuẩn hóa

audiowrite('jazz_mix.wav', mixed, fs1);
fprintf("✅ Đã tạo thành công jazz_mix.wav\n");
