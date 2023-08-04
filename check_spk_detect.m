addpath(genpath(pwd))
addpath(genpath("/Users/jjc/MEA-NAP/OutputData10Jul2023spkmake/1_SpikeDetection/1A_SpikeDetectedData"))
addpath(genpath("/Users/jjc/MEA-NAP"))
%%
clearvars; clc;

% recname = 'MEC220425_2A_DIV40_BASELINE.mat';
recname = 'MEC220425_2A_DIV40_HUB65_4UA.mat';
load(recname);
load([recname(1:end-4), '_spikes.mat']);

lowpass = 600;   % TODO: look into this
highpass = 8000; % and this
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3; % Used to be smth different, dunno anymore
[b, a] = butter(filterOrder, wn);
trace = filtfilt(b, a, double(dat));

%%
method = "thr5";
elid = find(channels==65);
eltrace = trace(:, elid);
plot(eltrace);

%%
[locs, stim_interval] = findStims(eltrace);

spk_times = spikeTimes{elid}.(method);

% plot(eltrace, '-v','MarkerIndices',locs,...
%     'MarkerFaceColor','red',...
%     'MarkerSize',5)

plot(eltrace, 'color', 'black');

mst=1;
hold on
rectangle('Position',[locs(1) -20 225*25 40], 'edgecolor','red')
hold on
plot(round(spk_times*fs), ones(length(spk_times),1)+20, '-v', 'markerfacecolor', 'red')
set(gca, 'xlim', [locs(1)-1000 locs(1)+50000])

%%
mst = 1;

% plot(eltrace(locs(1):locs(1)+(mst*fs)))
% hold on
rectangle('Position',[locs(1) -20 locs(1)+(mst*fs) 20])

%%

win = 25;
artifactFlg = 0;

for i = 1:60
elec = i;

data_el = trace(:,elec);

spkTimes = round(spikeTimes{elec}.(method)*fs);
[spikeTimes_aligned, spikeWaveforms_aligned] = alignPeaks(spkTimes, trace, win,artifactFlg);

newthr = thresholds{elec}.thr5/5*6;

spikeWaveforms_aligned = spikeWaveforms_aligned(spikeWaveforms_aligned(:,25)<newthr,:);

plot(spikeWaveforms_aligned');

savename = sprintf("elect_%d.png", i);
exportgraphics(gcf, savename)
end