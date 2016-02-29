function test_import_one_file()
%TEST_IMPORT_ONE_FILE testing of :mat:func:`+cdttable.import_one_file`.
%
% the template file ``import_params_example.json`` is obtained by running
% ``generate_params_schema_examples.py``.

import cdttable.read_import_params
import cdttable.add_rm_dependency

add_rm_dependency('add');
% ObjectMapper and File are used to write back JSON file.
% mapper.writeValue(new File("user-modified.json"), user);

% first, let's get the example import params.
[import_params_example, isValid] = read_import_params('import_params_example.json');
assert(isValid);
subTrialEndCodeExample = import_params_example.get('subtrials').get(0).clone();
subTrialEndTimeExample = import_params_example.get('subtrials').get(1).clone();
import_params_example.get('subtrials').clear()

n = 100;
maxMargin = 1;
maxTrialLength = 5;
maxTrialEndTimeVariation = 2;
rng(0,'twister');
for iFile = 1:n
    tic;
    [preprocess_result, eventTimesTruth, spikeTimesTruth, spikeLocationsTruth] = ...
        generate_one_preprocess_result(maxMargin, maxTrialLength, maxTrialEndTimeVariation);
    % this is shallow copy, and subtrials are shared. so remember to clear
    % subtrials before testing.
    
    % margin must be smaller than 1, see ``generate_one_preprocess_result``
    margin_before_this = rand()*maxMargin;
    margin_after_this = rand()*maxMargin;
    import_params_example.put('margin_before', margin_before_this);
    import_params_example.put('margin_after', margin_after_this);
    
    
    
    eventCodesPerTrial = preprocess_result.event_codes{1};
    subTrialCount = randi([1,3]);
    % the additional 2 is for trial marker.
    codesForUseIdx = sort(randperm(numel(eventCodesPerTrial), subTrialCount*2 + 2));
    
    % case 1, no trial marker
    % choose subTrialCount*2 numbers
    codesForUseIdxNoTrialMarker = ...
        codesForUseIdx(sort(randperm(numel(codesForUseIdx),subTrialCount*2)));
    % this will return subTrialCount*2 - 1 numbers, returning the minimum
    % time between adjacent codes over all trials.
    import_params_this = get_import_params_subtrials(...
        codesForUseIdxNoTrialMarker, eventTimesTruth, eventCodesPerTrial,...
        import_params_example.clone(), subTrialEndCodeExample, subTrialEndTimeExample);
    
    
    check_result(import_params_this, preprocess_result, eventTimesTruth, spikeTimesTruth, spikeLocationsTruth);
    
    
    % case 2, with trial marker, end code
    import_params_this = get_import_params_subtrials(...
        codesForUseIdx(2:end-1), eventTimesTruth, eventCodesPerTrial,...
        import_params_example.clone(), subTrialEndCodeExample, subTrialEndTimeExample);
    
    
    trial_start_code = eventCodesPerTrial(codesForUseIdx(1));
    trial_end_code = eventCodesPerTrial(codesForUseIdx(end));
    % add trial start code
    % add trial end code
    import_params_this.put('trial_start_code', int32(trial_start_code));
    import_params_this.put('trial_end_code', int32(trial_end_code));
    check_result(import_params_this, preprocess_result, eventTimesTruth, spikeTimesTruth, spikeLocationsTruth);
    
    % case 3, with trial marker, end time.
    
    % add trial end time
    import_params_this.remove('trial_end_code');
    trial_end_time = findMaxTimeSpanBetweenCodes(codesForUseIdx([1,end]), eventTimesTruth);
    trial_end_time = rand()*maxTrialEndTimeVariation + trial_end_time;
    assert(isscalar(trial_end_time));
    import_params_this.put('trial_end_time', trial_end_time);
    check_result(import_params_this, preprocess_result, eventTimesTruth, spikeTimesTruth, spikeLocationsTruth);
    
    disp(iFile);
    toc;
end

add_rm_dependency('rm');

end

function check_result(import_params_this, preprocess_result, eventTimesTruth, spikeTimesTruth, spikeLocationsTruth)
% we need to get the start time and end time window of each trial.
import cdttable.import_one_file
CDTTable = import_one_file(preprocess_result, import_params_this);
disp(numel(CDTTable.condition));
end


function import_params_this = get_import_params_subtrials(...
    codesForUseIdxNoTrialMarker, eventTimesTruth, eventCodesPerTrial,...
    import_params_this, subTrialEndCodeExample, subTrialEndTimeExample)
import_params_this.get('subtrials').clear();
subTrialCount = numel(codesForUseIdxNoTrialMarker)/2;
minTimeSpanBetweenCodes = ...
    findMinTimeSpanBetweenCodes(codesForUseIdxNoTrialMarker, eventTimesTruth);
minTimeSpanBetweenCodes = [minTimeSpanBetweenCodes(:)', 0];
assert(numel(minTimeSpanBetweenCodes)==2*subTrialCount);
maxEndTimeForSubTrials = sum(reshape(minTimeSpanBetweenCodes,[2,subTrialCount]),1);
assert(numel(maxEndTimeForSubTrials)==subTrialCount);
% as long as we sample end_time with this constraint, we are safe.
% simplest way being that the end_time not greater than
% minTimeSpanBetweenCodes(2*i-1:2*i) for ith subtrial.
for iSubTrial = 1:subTrialCount
    start_code_this = ...
        eventCodesPerTrial(codesForUseIdxNoTrialMarker(2*iSubTrial-1));
    if rand() < 0.5
        % do code.
        end_code_this = eventCodesPerTrial(codesForUseIdxNoTrialMarker(2*iSubTrial));
        subtrial_to_add = subTrialEndCodeExample.clone();
        subtrial_to_add.put('start_code', int32(start_code_this));
        subtrial_to_add.put('end_code', int32(end_code_this));
    else
        % do time
        end_time_this = rand()*maxEndTimeForSubTrials(iSubTrial);
        subtrial_to_add = subTrialEndTimeExample.clone();
        subtrial_to_add.put('start_code', int32(start_code_this));
        subtrial_to_add.put('end_time', end_time_this);
    end
    import_params_this.get('subtrials').add(subtrial_to_add);
end


end

function minTimeSpanBetweenCodes= findMinTimeSpanBetweenCodes(codesForUseIdxNoTrialMarker, eventTimesTruth)
minTimeSpanBetweenCodes = cellfun(@(x) diff(x(codesForUseIdxNoTrialMarker)), eventTimesTruth,'UniformOutput',false);
minTimeSpanBetweenCodes = cellfun(@(x) x(:)', minTimeSpanBetweenCodes,'UniformOutput',false);
minTimeSpanBetweenCodes = cell2mat(minTimeSpanBetweenCodes);
minTimeSpanBetweenCodes = min(minTimeSpanBetweenCodes,[],1);
end

function maxTimeSpanBetweenCodes= findMaxTimeSpanBetweenCodes(codesForUseIdxNoTrialMarker, eventTimesTruth)
maxTimeSpanBetweenCodes = cellfun(@(x) diff(x(codesForUseIdxNoTrialMarker)), eventTimesTruth,'UniformOutput',false);
maxTimeSpanBetweenCodes = cellfun(@(x) x(:)', maxTimeSpanBetweenCodes,'UniformOutput',false);
maxTimeSpanBetweenCodes = cell2mat(maxTimeSpanBetweenCodes);
maxTimeSpanBetweenCodes = max(maxTimeSpanBetweenCodes,[],1);
end


function [preprocess_result, eventTimesTruth, spikeTimesTruth, spikeLocationsTruth] = ...
    generate_one_preprocess_result(maxMargin, maxTrialLength, maxTrialEndTimeVariation)

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

end
