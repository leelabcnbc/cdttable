function [ CDTTable ] = import_one_file( preprocess_result, import_params )
%IMPORT_ONE_FILE get CDT table for one file
%
%   :params preprocess_result: the canonical preprocessed result with 
%           event_codes, event_times, spike_times, and spike_locations.
%   :params import_params: Java object representing import params obtained
%           via :mat:func:`+cdttable.read_import_params`.
%   :return: one CDTTable.
%
% .. seealso:: :mat:func:`+cdttable.import_one_trial`,

import cdttable.import_one_trial

NEV_code = preprocess_result.event_codes;
NEV_time = preprocess_result.event_times;
TimeStamps = preprocess_result.spike_times;
spikeElecUnit = preprocess_result.spike_locations;


%% for cellfun applying processing function to each trial.
tmp_struct = cell(numel(NEV_code),1);
% pre-process all needed spike information for each trial.
for jTrial = 1:numel(NEV_code)
    start_time_trial = NEV_time{jTrial}(1);
    end_time_trial = NEV_time{jTrial}(end);
    
    % notice that these are all open intervals, consistent with Corentin's
    % old program.
    selectIdx = ( (TimeStamps > start_time_trial-import_params_margin_before) ...
        & (TimeStamps < end_time_trial+import_params_margin_after) );
    
    tmp_struct{jTrial}.Electrode = spikeElecUnit(selectIdx,1);
    tmp_struct{jTrial}.Unit = spikeElecUnit(selectIdx,2);
    tmp_struct{jTrial}.TimeStamps = TimeStamps(selectIdx);
    tmp_struct{jTrial}.EventCodes = NEV_code{jTrial};
    tmp_struct{jTrial}.EventTimes = NEV_time{jTrial};
    tmp_struct{jTrial}.trialIdx = jTrial;
end

% CDTTableByTrials = cellfun(@(x) import_NEV_trial(x, import_params), ...
%     tmp_struct, 'UniformOutput', false);

%% parallel processing of trials. Should try out to see which is better.
CDTTableByTrials = cell(numel(NEV_code),1);
parfor iTrial = 1:numel(NEV_code)
    CDTTableByTrials{iTrial} = import_one_trial(tmp_struct{iTrial}, import_params)
end

%% create a cell array for each column in the whole table.
CDTTable = struct();
numTrial = numel(NEV_code);
CDTTable.condition = zeros(numTrial,1);
CDTTable.starttime = cell(numTrial,1); % later to be represented as matrix.
CDTTable.stoptime = cell(numTrial,1); % later to be represented as matrix.
CDTTable.spikeElectrode = cell(numTrial,1);
CDTTable.spikeUnit = cell(numTrial,1);
CDTTable.spikeTimes = cell(numTrial,1);
CDTTable.eventCodes = cell(numTrial,1);
CDTTable.eventTimes = cell(numTrial,1);


for iTrial = 1:numTrial
    CDTTableThisRow = CDTTableByTrials{iTrial};
    CDTTable.condition(iTrial) = CDTTableThisRow.condition;
    CDTTable.starttime{iTrial} = CDTTableThisRow.starttime(:)'; % make them row
    CDTTable.stoptime{iTrial} = CDTTableThisRow.stoptime(:)'; % make them row.
    CDTTable.spikeElectrode{iTrial} = CDTTableThisRow.spikeElectrode;
    CDTTable.spikeUnit{iTrial} = CDTTableThisRow.spikeUnit;
    CDTTable.spikeTimes{iTrial} = CDTTableThisRow.spikeTimes;
    CDTTable.eventCodes{iTrial} = CDTTableThisRow.eventCodes;
    CDTTable.eventTimes{iTrial} = CDTTableThisRow.eventTimes;
end

CDTTable.starttime = cell2mat(CDTTable.starttime);
CDTTable.stoptime = cell2mat(CDTTable.stoptime);

end

