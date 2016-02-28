function [ CDTTableRow ] = import_one_trial_startstoptime( CDTTableRow,trial_struct,import_params )
%IMPORT_ONE_TRIAL_STARTSTOPTIME find start and stop times of subtrials
%   
%   :param CDTTableRow: CDTTableRow passed by
%                       :mat:func:`+cdttable.import_one_trial`.
%   :param trial_struct: trial_struct from :mat:func:`+cdttable.import_one_trial`
%   :param import_params: import_params from :mat:func:`+cdttable.import_one_trial`
%
% .. seealso:: :mat:func:`+cdttable.find_event_times_given_codes`,

import cdttable.find_event_times_given_codes

%% get number of subtrials
numPairMarker = double(import_params.get('subtrials').size());
assert(numPairMarker>=1); % at least one pair.

% create a ref to subtrials for ease of access.
subtrialsRef = import_params.get('subtrials');

%% first, let's find the time of start markers.
startAlignCodes = nan(numPairMarker,1);
for iAlignCode = 1:numPairMarker
    startAlignCodes(iAlignCode) = ...
        subtrialsRef.get(iAlignCode-1).get('start_code');
end

CDTTableRow.starttime = find_event_times_given_codes(...
    startAlignCodes,trial_struct.EventCodes,trial_struct.EventTimes);

%% second, find the time of end markers.
CDTTableRow.stoptime = nan(numPairMarker,1);
for iAlignCode = 1:numPairMarker
    if subtrialsRef.get(iAlignCode-1).containsKey('end_code')
        CDTTableRow.stoptime(iAlignCode) = find_event_times_given_codes(...
            subtrialsRef.get(iAlignCode-1).get('end_code'),...
            trial_struct.EventCodes,trial_struct.EventTimes);
    elseif subtrialsRef.get(iAlignCode-1).containsKey('end_time')
        CDTTableRow.stoptime(iAlignCode) = CDTTableRow.starttime(iAlignCode) + ...
            subtrialsRef.get(iAlignCode-1).get('end_time');
    else
        error('not implemented! check import params schema errors!');
    end
end


% check no NaN, which indicates not found. This is just doublecheck, since
% find_event_times_given_codes should already complain if this happens.
assert(all(~isnan(CDTTableRow.starttime)));
assert(all(~isnan(CDTTableRow.stoptime)));
assert(all(CDTTableRow.starttime-CDTTableRow.stoptime<=0));

% save codes for easier access.
CDTTableRow.startAlignCodes = startAlignCodes;

end

