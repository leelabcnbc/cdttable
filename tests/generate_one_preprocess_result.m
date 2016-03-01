function [preprocess_result, eventTimesTruth, spikeTimesTruth, spikeLocationsTruth] = ...
    generate_one_preprocess_result(maxMargin, maxTrialLength, maxTrialEndTimeVariation)

if nargin < 1 || isempty(maxMargin)
    maxMargin = 1;
end

if nargin < 2 || isempty(maxTrialLength)
    maxTrialLength = 1;
end

if nargin < 3 || isempty(maxTrialEndTimeVariation)
    maxTrialEndTimeVariation = 1;
end

% maxMargin is the maximum padding that would be chosen by the testing
% program. I need to have greater margin.

% randomly generate one preprocess result, plus the ground truth.
preprocess_result = struct();

%% 1. choose a code template with distinct codes and random size.
numCode = randi([10, 20]);
codeRange = -100:100;
eventCodesPerTrial = codeRange(randperm(numel(codeRange), numCode));
%% 2. choose number of trials. must be >=1 by design.
numTrial = randi([1,500]);
preprocess_result.event_codes = repmat({eventCodesPerTrial(:)},numTrial,1);

%% 3. randomly compute the duration of each trial, and assign event codes with the markers.
trialLengthUnpadded = rand([numTrial, 1])*maxTrialLength;
% trials are between 0 to maxTrialLength seconds.
% I will simply allow trial_end_time to be from almost maxTrialLength to
% (almost maxTrialLength)+maxTrialEndTimeVariation, so I need an additional
% padding of maxTrialLength+maxTrialEndTimeVariation for padding after.

eventTimesTruth = cell(numTrial,1);

for iTrial = 1:numTrial
    eventTimesTruth{iTrial} = [0; sort(rand([numCode-1, 1]))*trialLengthUnpadded(iTrial)];
end

%% 4. compute two paddings for before and after each trial, time zero at first code
% a padding of 1 to 2 seconds on both sides.
% I will make sure that when testing, the window to extract will be at most
% 1 sec away from start codes of the whole trial, so that the ground truth
% can give me the spikes in the padding, without fear that some is lost.

trialPaddingBefore = rand([numTrial, 1])+maxMargin;
trialPaddingAfter = rand([numTrial, 1])+maxMargin+maxTrialEndTimeVariation+maxTrialLength;
trialLengthPadded = trialLengthUnpadded + trialPaddingBefore + trialPaddingAfter;
%% 5. generate some spikes within each trial's padded window, each with random electrode and unit.
spikeTimesTruth = cell(numTrial,1);
spikeLocationsTruth = cell(numTrial,1);
% TODO: in the reader program, check shape of spike_locations.
% must be [xxx, 2] and xxx > 0.
for iTrial = 1:numTrial
    numSpikeThis = randi([1,1000]);
    if rand() < 0.2
        % so there's high probability of no spike.
        numSpikeThis = 0;
    end
    spikeTimesTruth{iTrial} = rand([numSpikeThis,1])*trialLengthPadded(iTrial) - trialPaddingBefore(iTrial);
    spikeLocationsTruth{iTrial} = randi([-2,2],[numSpikeThis,2]);
end
preprocess_result.spike_times = cell2mat(spikeTimesTruth);
preprocess_result.spike_locations = cell2mat(spikeLocationsTruth);
%% 6. cumsum the length of each trial to get the actual input to import_one_file.
accTrialLength = cumsum(trialLengthPadded);
accTrialLength = accTrialLength(:);
accTrialLength = [0; accTrialLength(1:end-1)];
event_times = eventTimesTruth;
spike_times = spikeTimesTruth;
for iTrial = 1:numTrial
    event_times{iTrial} = event_times{iTrial} + accTrialLength(iTrial) + trialPaddingBefore(iTrial);
    spike_times{iTrial} = spike_times{iTrial} + accTrialLength(iTrial) + trialPaddingBefore(iTrial);
end
preprocess_result.event_times = event_times;
preprocess_result.spike_times = cell2mat(spike_times);

% shuffle spikes.
numSpikeTotal = numel(preprocess_result.spike_times);
p = randperm(numSpikeTotal);
preprocess_result.spike_times = preprocess_result.spike_times(p);
preprocess_result.spike_locations = preprocess_result.spike_locations(p,:);
end