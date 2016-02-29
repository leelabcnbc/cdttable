function [ CDTTableRow ] = import_one_trial( trial_struct, import_params )
%IMPORT_ONE_TRIAL import one trial
%
%    :param trial_struct: intermediate format storing all info needed for
%           this trial
%    :param import_params: Java object representing import params obtained
%           via :mat:func:`+cdttable.read_import_params`.
%    :return: one row in CDT Table.
%
% .. seealso:: :mat:func:`+cdttable.import_one_trial_startstoptime`,
%              :mat:func:`+cdttable.import_one_trial_trial_start_stop_time`,
%              :mat:func:`+cdttable.import_one_trial_getevents`,
%              :mat:func:`+cdttable.import_one_trial_getspikes`,

import cdttable.import_one_trial_startstoptime
import cdttable.import_one_trial_trial_start_stop_time
import cdttable.import_one_trial_getevents
import cdttable.import_one_trial_getspikes
% get the function mapping trial event codes + idx to condition.
% this means you can write lambda function as well... say set
% trial_to_condition_func_str to '(codes,idx) codes(3) + 2'...
trial_to_condition_func_str = char(import_params.get('trial_to_condition_func'));
trial_to_condition_func = eval(['@' trial_to_condition_func_str]);


CDTTableRow = struct();
% should have:
% condition number % condition number.
% starttime % time of 'start' markers.
% stoptime % time of 'end' markers.
% spikeElectrode % column vector of all spikes' electrode.
% spikeUnit % column vector of all spikes' unit.
% spikeTimes % cell array of all spikes in that electrode/unit combination.
% eventCodes % column vector of all event codes during the given window.
% eventTimes % column vector of all event times during the given window.

% all times are w.r.t. the time of trial start time, which should be
% usually the time of first start marker, shifted by the margin_before.
% So we shouldn't get any negative time (assuming every other marker
% happens after first start marker).

% this definition of time is consistent with my previous implementations.

%% get CDTTableRow.condition
CDTTableRow.condition = trial_to_condition_func(trial_struct.EventCodes,trial_struct.trialIdx);
%% get CDTTableRow.starttime/stoptime
CDTTableRow = import_one_trial_startstoptime(CDTTableRow,trial_struct,import_params);
%% work on getting the window for extracting spikes and events.
CDTTableRow = import_one_trial_trial_start_stop_time(...
    CDTTableRow,trial_struct,import_params);


%% get spikes in this window ( [trialStartTime,trialEndTime] ).
CDTTableRow = import_one_trial_getspikes(CDTTableRow,trial_struct);
%% get events in this window
CDTTableRow = import_one_trial_getevents(CDTTableRow,trial_struct);


%% shift start and stop times with CDTTableRow.trialStartTime as start point.
CDTTableRow.starttime = CDTTableRow.starttime - CDTTableRow.trialStartTime;
CDTTableRow.stoptime = CDTTableRow.stoptime - CDTTableRow.trialStartTime;


%% remove aux fields which users shouldn't care about.
CDTTableRow = rmfield(CDTTableRow,{'startAlignCodes','trialStartTime',...
    'trialEndTime'});

end

