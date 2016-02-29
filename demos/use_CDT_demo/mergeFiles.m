function cdt = mergeFiles(CDTTables)
    cdt = struct('condition',[],'starttime',[],'stoptime',[],'spikeElectrode',[],...
        'spikeUnit',[],'spikeTimes',[],'eventCodes',[],'eventTimes',[]);
    for i = 1:numel(CDTTables),
        cdt.condition = [cdt.condition; CDTTables{i}.condition];
        cdt.starttime = [cdt.starttime; CDTTables{i}.starttime];
        cdt.stoptime = [cdt.stoptime; CDTTables{i}.stoptime];
        cdt.spikeElectrode = [cdt.spikeElectrode; CDTTables{i}.spikeElectrode];
        cdt.spikeUnit = [cdt.spikeUnit; CDTTables{i}.spikeUnit];
        cdt.spikeTimes = [cdt.spikeTimes; CDTTables{i}.spikeTimes];
        cdt.eventCodes = [cdt.eventCodes; CDTTables{i}.eventCodes];
        cdt.eventTimes = [cdt.eventTimes; CDTTables{i}.eventTimes];
    end
    
end