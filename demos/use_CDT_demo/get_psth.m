function psth = get_psth(spike_times,xAxisLength,sigma)
    
    ntrials = numel(spike_times);
    
    spike_times = cell2mat(spike_times(:)');  % collapse into a long row vector
    spike_times = spike_times*1000;  % convert seconds into ms
    psth = histc(spike_times,0:xAxisLength);
    psth = psth(1:end-1);

    %smoothing
    psth = gaussSmooth(psth,sigma);
    psth = psth/ntrials;
end
