function [ CDTTableRow ] = import_one_trial_getevents( CDTTableRow,trial_struct )
%IMPORT_ONE_TRIAL_GETEVENTS get event times of a trial.
%
%   :param CDTTableRow: CDTTableRow passed by
%                       :mat:func:`+cdttable.import_one_trial`.
%   :param trial_struct: trial_struct from :mat:func:`+cdttable.import_one_trial`
%
% notice that these are all open intervals, consistent with Corentin's
% old program.

eventWindowIndex = trial_struct.EventTimes < CDTTableRow.trialEndTime & ...
    trial_struct.EventTimes > CDTTableRow.trialStartTime;
CDTTableRow.eventCodes = trial_struct.EventCodes(eventWindowIndex);

% now that we know the trial start time, we shift event times with it.
CDTTableRow.eventTimes = ...
    trial_struct.EventTimes(eventWindowIndex) - CDTTableRow.trialStartTime;

end

