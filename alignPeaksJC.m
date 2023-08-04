function [spikeTimes, spikeWaveforms] = alignPeaksJC(spikeTimes, trace, win,...
    artifactFlg, varargin)

waveform_width = 25;
minThr = -inf; maxThr = inf; posThr = inf;
traceLength = length(trace);

if artifactFlg
    minThr = varargin{1}; % e.g. -7 uV
    maxThr = varargin{2}; % e.g. -100 uV
    posThr = varargin{3}; % % e.g. 100 uV
end

% Filter out spikeTimes too close to the borders
validSpikes = (spikeTimes+win<traceLength-1) & (spikeTimes-win>1);
spikeTimes = spikeTimes(validSpikes);

% Array to store spikes and waveforms
spikeWaveforms = zeros(length(spikeTimes),waveform_width*2+1);
sFr = zeros(length(spikeTimes),1);

% Calculate bins for all spikes at once
bins = arrayfun(@(s) trace(s-win:s+win), spikeTimes, 'UniformOutput', false);

% For each bin
for i = 1:length(bins)
    bin = bins{i};
    negativePeak = min(bin);
    positivePeak = max(bin);
    pos = find(bin == negativePeak, 1, 'first');

    if artifactFlg && (negativePeak < minThr || positivePeak > posThr || negativePeak > maxThr)
        continue
    end

    newSpikeTime = spikeTimes(i)+pos-win;

    if newSpikeTime+waveform_width < traceLength && newSpikeTime-waveform_width > 1
        waveform = trace(newSpikeTime-waveform_width:newSpikeTime+waveform_width);
        sFr(i) = newSpikeTime;
        spikeWaveforms(i, :) = waveform;
    end
end

% remove zero entries
validIdx = sFr ~= 0;
spikeTimes = sFr(validIdx);
spikeWaveforms = spikeWaveforms(validIdx,:);

end
