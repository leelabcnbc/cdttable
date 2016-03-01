function test_import_one_file(n)
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

if nargin < 1 || isempty(n)
    n = 100;
end

for iFile = 1:n
    tic;

    maxMargin = rand()*5; % 0-5
    maxTrialLength = rand()*5+5;  % 5-10
    maxTrialEndTimeVariation = rand()*5;  % 0-5

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
import cdttable.import_one_trial
CDTTable = import_one_file(preprocess_result, import_params_this);

% basically, do the same thing in import_one_trial, but on ground truth.
trialNum = numel(eventTimesTruth);
assert(trialNum == numel(CDTTable.condition));

epsTol = 1e-10;
for iTrial = 1:trialNum
    tmp_struct = struct();
    tmp_struct.Electrode = spikeLocationsTruth{iTrial}(:,1);
    tmp_struct.Unit = spikeLocationsTruth{iTrial}(:,2);
    tmp_struct.TimeStamps = spikeTimesTruth{iTrial};
    tmp_struct.EventCodes = preprocess_result.event_codes{iTrial};
    tmp_struct.EventTimes = eventTimesTruth{iTrial};
    tmp_struct.trialIdx = iTrial;
    CDTTableThisRow = import_one_trial(tmp_struct, import_params_this);
    
    % check
    assert(isequal(CDTTable.condition(iTrial),CDTTableThisRow.condition));
    assert(max(abs(CDTTable.starttime(iTrial,:)-CDTTableThisRow.starttime(:)'))<epsTol);
    assert(max(abs(CDTTable.stoptime(iTrial,:)-CDTTableThisRow.stoptime(:)'))<epsTol);
    assert(isequal(CDTTable.spikeElectrode{iTrial}, CDTTableThisRow.spikeElectrode));
    assert(isequal(CDTTable.spikeUnit{iTrial}, CDTTableThisRow.spikeUnit));
    
    assert(numel(CDTTable.spikeTimes{iTrial})==numel(CDTTableThisRow.spikeTimes));
    for i = 1:numel(CDTTable.spikeTimes{iTrial})
        assert(max(abs(sort(CDTTable.spikeTimes{iTrial}{i})-sort(CDTTableThisRow.spikeTimes{i})))<epsTol);
    end
    
    assert(isequal(CDTTable.eventCodes{iTrial}, CDTTableThisRow.eventCodes));
    assert(max(abs(CDTTable.eventTimes{iTrial}-CDTTableThisRow.eventTimes))<epsTol);
end



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
        if rand() < 0.5
            subtrial_to_add.put('end_code', int32(end_code_this));
        else
            subtrial_to_add.put('end_code', int32(start_code_this));
        end
    else
        % do time
        end_time_this = rand()*maxEndTimeForSubTrials(iSubTrial);
        if rand() < 0.5
            end_time_this = 0;
        end
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
