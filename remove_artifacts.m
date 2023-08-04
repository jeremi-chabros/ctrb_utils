addpath(genpath(pwd))
addpath(genpath("/Users/jjc/MEA-NAP/OutputData10Jul2023spkmake/1_SpikeDetection/1A_SpikeDetectedData"))
addpath(genpath("/Users/jjc/MEA-NAP"))
%%
clearvars; clc;
addpath(genpath('/Users/jjc/Controllability/'));
files = dir('/Users/jjc/Controllability/Data/Raw/*.mat');
file = 3;
% for file = 1:length(files)
filename = files(file).name;
load(filename, '');
if contains(filename, 'baseline', 'ignorecase', true)
    %     This is a hack to avoid loading 'thresholds' variable for further
    %     recordings
    load([filename(1:end-4), '_spikes.mat']);
else
    load([filename(1:end-4), '_spikes.mat']);
    %     load([filename(1:end-4), '_spikes.mat'], 'spikeTimes', 'spikeWaveforms');
end
method = "thr5";

lowpass = 100;
highpass = 500;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
trace = filtfilt(b, a, double(dat));

ssplit = split(filename, '_');
stim_elec_id = str2num(ssplit{4}(end-1:end));

elid = find(channels==stim_elec_id);
[locs, ~] = findStims(trace(:,elid));
locs_ms = locs/25000;
blanking_s = 0.01; % Refractory period in [s]

spike_times_removed = cell(length(channels),1);
for i = 1:length(channels)
    spike_times = spikeTimes{i}.(method);
    rm_id = rmSpikesWithinRange(locs_ms, spike_times, blanking_s);
    spikeTimes{i}.(method) = setxor(spike_times, rm_id);
end

%%
save(['spikes/' filename(1:end-4), '_spikes.mat'], 'spikeTimes', 'channels', 'spikeDetectionResult', 'spikeWaveforms', 'thresholds', 'locs_ms');



