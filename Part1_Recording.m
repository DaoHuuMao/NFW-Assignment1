% Audio Recording Script
% Author: [Your Name]
% Date: [Current Date]
% Description: Script for recording 4-minute audio with team members' information

%% Recording Parameters
fs = 44100;           % Sample rate (Hz)
duration = 5;       % Duration in seconds (4 minutes)
nBits = 16;           % Bit depth
nChannels = 1;        % Mono recording
outputFileName = 'team_recording.wav';

%% Create Recording Object
recObj = audiorecorder(fs, nBits, nChannels);

%% Recording Process
try
    % Display countdown
    disp('=== TEAM RECORDING SESSION ===');
    disp('Preparing to record in:');
    for i = 5:-1:1
        disp(num2str(i));
        pause(1);
    end
    
    % Start recording
    disp('=== RECORDING STARTED ===');
    disp('Please speak in the following order:');
    disp('1. Full Name');
    disp('2. Student ID');
    disp('3. Assigned Tasks');
    disp('4. Achievements');
    disp('--------------------------------');
    
    % Record audio
    recordblocking(recObj, duration);
    
    % Stop recording
    disp('=== RECORDING COMPLETED ===');
    
    % Get audio data
    audioData = getaudiodata(recObj);
    
    % Save recording
    audiowrite(outputFileName, audioData, fs);
    disp(['Audio saved as: ' outputFileName]);
    
    % Verify recording
    [y, fs] = audioread(outputFileName);
    disp(['Recording duration: ' num2str(length(y)/fs) ' seconds']);
    disp(['Sample rate: ' num2str(fs) ' Hz']);
    disp(['Number of samples: ' num2str(length(y))]);
    
catch ME
    % Error handling
    disp('Error occurred during recording:');
    disp(ME.message);
    disp('Stack trace:');
    disp(ME.stack);
end

%% Audio Quality Check
% Check for silence or very low volume
if max(abs(audioData)) < 0.01
    warning('Warning: Audio level is very low. Please check your microphone.');
end

% Check for clipping
if max(abs(audioData)) > 0.99
    warning('Warning: Audio is clipping. Please reduce input volume.');
end

%% Display Recording Information
disp('=== RECORDING INFORMATION ===');
disp(['File name: ' outputFileName]);
disp(['Sample rate: ' num2str(fs) ' Hz']);
disp(['Bit depth: ' num2str(nBits) ' bits']);
disp(['Channels: ' num2str(nChannels)]);
disp(['Duration: ' num2str(duration) ' seconds']);
disp(['File size: ' num2str(length(audioData)*nBits/8/1024) ' KB']);

%% Optional: Play back recording
disp('Playing back recording...');
play(recObj);