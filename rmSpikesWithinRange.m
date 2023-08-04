function [spike_times_removed] = rmSpikesWithinRange(locs_ms, spike_times, blanking_s)
%     Create a vector of bin edges with locs_ms and locs_ms+25000
    bin_edges = sort([locs_ms(:); locs_ms(:)+blanking_s]);

    % Use histc to determine which bin each spike_time falls into
    [~, bin_indices] = histc(spike_times, bin_edges);

    % Find spike_times that fall into even-numbered bins (these are within the ranges)
    is_within_range = mod(bin_indices, 2) == 1;

    % Remove the spike_times within the range
    spike_times_removed = spike_times(is_within_range);
end