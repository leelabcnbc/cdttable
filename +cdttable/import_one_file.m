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

import cdttable.read_import_params
import cdttable.import_one_trial
import cdttable.check_preprocess_result

% check preprocess result
assert(check_preprocess_result(preprocess_result));

event_codes = preprocess_result.event_codes;
event_times = preprocess_result.event_times;
spike_times = preprocess_result.spike_times;
spike_locations = preprocess_result.spike_locations;


import_params_margin_before = double(import_params.get('margin_before'));
import_params_margin_after = double(import_params.get('margin_after'));

% ``additionalPadding`` accounts for max additional padding due to
% ``end_time`` in subtrials and the trial.
additionalPadding = 0;
if import_params.containsKey('trial_end_time') % time based
    additionalPadding = double(import_params.get('trial_end_time'));
end

% also cycle over subtrials to find any end_time, and take the max of it
% with trialEndTimePadding.

numPairMarker = double(import_params.get('subtrials').size());
assert(numPairMarker>=1); % at least one pair.
% create a ref to subtrials for ease of access.
subtrialsRef = import_params.get('subtrials');
for iAlignCode = 1:numPairMarker
    if subtrialsRef.get(iAlignCode-1).containsKey('end_time')
        additionalPadding = max(additionalPadding, ...
            subtrialsRef.get(iAlignCode-1).get('end_time'));
    end
end

%% for cellfun applying processing function to each trial.
tmp_struct = cell(numel(event_codes),1);
% pre-process all needed spike information for each trial.
for jTrial = 1:numel(event_codes)
    start_time_trial = event_times{jTrial}(1);
    end_time_trial = event_times{jTrial}(end);
    
    % notice that these are all open intervals, consistent with Corentin's
    % old program.
    selectIdx = ( (spike_times > start_time_trial-import_params_margin_before) ...
        & (spike_times < (end_time_trial+import_params_margin_after+additionalPadding)));
    
    tmp_struct{jTrial}.Electrode = spike_locations(selectIdx,1);
    tmp_struct{jTrial}.Unit = spike_locations(selectIdx,2);
    tmp_struct{jTrial}.TimeStamps = spike_times(selectIdx);
    tmp_struct{jTrial}.EventCodes = event_codes{jTrial};
    tmp_struct{jTrial}.EventTimes = event_times{jTrial};
    tmp_struct{jTrial}.trialIdx = jTrial;
end

% CDTTableByTrials = cellfun(@(x) import_NEV_trial(x, import_params), ...
%     tmp_struct, 'UniformOutput', false);

%% parallel processing of trials. Should try out to see which is better.
CDTTableByTrials = cell(numel(event_codes),1);
parfor iTrial = 1:numel(event_codes)
    CDTTableByTrials{iTrial} = import_one_trial(tmp_struct{iTrial}, import_params);
end

%% create a cell array for each column in the whole table.
CDTTable = struct();
numTrial = numel(event_codes);
CDTTable.condition = zeros(numTrial,1);
CDTTable.starttime = cell(numTrial,1); % later to be represented as matrix.
CDTTable.stoptime = cell(numTrial,1); % later to be represented as matrix.
CDTTable.spikeElectrode = cell(numTrial,1);
CDTTable.spikeUnit = cell(numTrial,1);
CDTTable.spikeTimes = cell(numTrial,1);
CDTTable.eventCodes = cell(numTrial,1);
CDTTable.eventTimes = cell(numTrial,1);
CDTTable.trialStartTime = zeros(numTrial,1);
CDTTable.trialEndTime = zeros(numTrial,1);
CDTTable.trialLength = zeros(numTrial,1);

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
    CDTTable.trialStartTime(iTrial) = CDTTableThisRow.trialStartTime;
    CDTTable.trialEndTime(iTrial) = CDTTableThisRow.trialEndTime;
    CDTTable.trialLength(iTrial) = CDTTableThisRow.trialLength;
end

CDTTable.starttime = cell2mat(CDTTable.starttime);
CDTTable.stoptime = cell2mat(CDTTable.stoptime);

end

