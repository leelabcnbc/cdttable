function [ CDTTableRow ] = import_one_trial_getspikes( CDTTableRow,trial_struct )
%IMPORT_ONE_TRIAL_GETSPIKES get spike times of a trial.
%
%   :param CDTTableRow: CDTTableRow passed by
%                       :mat:func:`+cdttable.import_one_trial`.
%   :param trial_struct: trial_struct from :mat:func:`+cdttable.import_one_trial`
%
% notice that these are all open intervals, consistent with Corentin's
% old program.

spikeWindowIndex = trial_struct.TimeStamps < CDTTableRow.trialEndTime & ...
    trial_struct.TimeStamps > CDTTableRow.trialStartTime;

ElectrodeWindow = trial_struct.Electrode(spikeWindowIndex);
UnitWindow = trial_struct.Unit(spikeWindowIndex);
TimeStampsWindow = trial_struct.TimeStamps(spikeWindowIndex);

assert(numel(ElectrodeWindow) == numel(UnitWindow));
% handle the degenerate case where there's no spike at all.
% in that case, ``unique`` would fail.
if numel(ElectrodeWindow) > 0
    elecUnitMapLocal = unique([ElectrodeWindow, UnitWindow],'rows');
else
    elecUnitMapLocal = zeros(0,2);
end
assert(size(elecUnitMapLocal,2)==2);
numUnitLocal = size(elecUnitMapLocal,1);

CDTTableRow.spikeElectrode = elecUnitMapLocal(:,1);
CDTTableRow.spikeUnit = elecUnitMapLocal(:,2);
CDTTableRow.spikeTimes = cell(numUnitLocal,1);

for iUnit = 1:numUnitLocal % create an cell of spike times for each unit.
    electrodeThis = elecUnitMapLocal(iUnit,1);
    unitThis = elecUnitMapLocal(iUnit,2);
    spikeIndexThisUnit = ...
        (ElectrodeWindow==electrodeThis) & (UnitWindow==unitThis);
    CDTTableRow.spikeTimes{iUnit} = ... % now time origin corrected.
        TimeStampsWindow(spikeIndexThisUnit) - CDTTableRow.trialStartTime;
    CDTTableRow.spikeTimes{iUnit} = CDTTableRow.spikeTimes{iUnit}(:)'; 
    % make spike times row vector for better compatibility with other
    % tools which accept row vectors.
end

end

