function [ CDTTableRow ] = import_one_trial_trial_start_stop_time( CDTTableRow,...
    trial_struct,import_params )
%IMPORT_ONE_TRIAL_TRIAL_START_STOP_TIME find start and stop times the trial
%
%   :param CDTTableRow: CDTTableRow passed by
%                       :mat:func:`+cdttable.import_one_trial`.
%   :param trial_struct: trial_struct from :mat:func:`+cdttable.import_one_trial`
%   :param import_params: import_params from :mat:func:`+cdttable.import_one_trial`
%
% .. seealso:: :mat:func:`+cdttable.find_event_times_given_codes`,

import cdttable.find_event_times_given_codes

if import_params.containsKey('trial_start_code')
    trialStartAlignCode = double(import_params.get('trial_start_code'));
else
    trialStartAlignCode = CDTTableRow.startAlignCodes(1); % otherwise use first start code in subtrial level.
end
trialStartTime = find_event_times_given_codes(...
    trialStartAlignCode,trial_struct.EventCodes,trial_struct.EventTimes);
% work on end time.
% this block gives the unpadded trial end time.

if import_params.containsKey('trial_start_code') % if this exists, then the following two must exist by schema.
    if import_params.containsKey('trial_end_code')
        trialEndTime = find_event_times_given_codes(...
            double(import_params.get('trial_end_code')),...
            trial_struct.EventCodes,trial_struct.EventTimes);
    elseif import_params.containsKey('trial_end_time') % time based
        trialEndTime = trialStartTime + ...
            double(import_params.get('trial_end_time'));
    else
        error('not implemented! check import params schema errors!');
    end
else
    % take last time
    trialEndTime = CDTTableRow.stoptime(end);
end

% trial end must be bigger than trial start.
assert(trialStartTime < trialEndTime);

% these are the final products of this block.
% pad margin
CDTTableRow.trialEndTime = trialEndTime + double(import_params.get('margin_after'));
% pad margin. This can't be done before, since otherwise the end time will
% be wrong...
CDTTableRow.trialStartTime = trialStartTime - double(import_params.get('margin_before'));

%% assert that all subtrial times are greater than trialStartTime and smaller than trialEndTime
assert(all(CDTTableRow.starttime >= CDTTableRow.trialStartTime));
assert(all(CDTTableRow.stoptime <= CDTTableRow.trialEndTime));

end

