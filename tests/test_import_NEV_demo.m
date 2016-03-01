function test_import_NEV_demo()
%TEST_IMPORT_NEV_DEMO Summary of this function goes here
%   Detailed explanation goes here
%% compare results
demoResultDir = fullfile(root_dir(),'demos','import_NEV_demo_results');
referenceResultDir = fullfile(root_dir(),'tests','test_import_NEV_demo');
referenceResultFileList = {...
    'v1_2012_1105_003.mat';
    'v1_2012_1105_004.mat';
    };
CDTTables = load(fullfile(demoResultDir, 'import_NEV_demo_result.mat'));
CDTTables = CDTTables.CDTTables;
assert(numel(referenceResultFileList)==numel(CDTTables));

for iFile = 1:numel(CDTTables)
    oldMatThis = ...
        load(fullfile(referenceResultDir,referenceResultFileList{iFile}));
    % compare oldMatThis.cdt and CDTTables{iFile}.
    cdtOld = oldMatThis.cdt;
    cdtNew = CDTTables{iFile};
    compare_old_and_new_CDT(cdtOld,cdtNew);
end


end


function compare_old_and_new_CDT(cdtOld,cdtNew)

tol = 1e-10;
% make sure cnd index and cnd itself are exchangeable.
assert(isequal(cdtOld.exp_param.condition_list(:)', ...
    1:numel(cdtOld.exp_param.condition_list)));

%% check trial orders by conditions.
assert(isequal(cdtOld.order(:,1),cdtNew.condition));

%% check events,spikes,times.
trialCount = cdtOld.trial_count;
conditionTotal = size(cdtOld.event,1);

for iCondition = 1:conditionTotal
    
    %% events.
    eventCodesNew = cdtNew.eventCodes(cdtNew.condition==iCondition);
    eventTimesNew = cdtNew.eventTimes(cdtNew.condition==iCondition);
    
    assert(numel(eventCodesNew)==trialCount(iCondition));
    assert(numel(eventTimesNew)==trialCount(iCondition));
    
    for iTrial = 1:trialCount(iCondition)
        eventThisOld = cdtOld.event{iCondition,iTrial};
        eventThisNew = [eventCodesNew{iTrial},eventTimesNew{iTrial}];
        assert(max(abs(eventThisOld(:)-eventThisNew(:)))<tol); % in case there's some round off errors on event times.
    end
    
    %% spikes
    spikeElecNew = cdtNew.spikeElectrode(cdtNew.condition==iCondition);
    spikeUnitNew = cdtNew.spikeUnit(cdtNew.condition==iCondition);
    spikeTimesNew = cdtNew.spikeTimes(cdtNew.condition==iCondition);
    
    
    
    for iTrial = 1:trialCount(iCondition)
        spikeElecNewThis = spikeElecNew{iTrial};
        spikeUnitNewThis = spikeUnitNew{iTrial};
        spikeTimesNewThis = spikeTimesNew{iTrial};
        
        spikeTimesOldThis = cdtOld.spike(:,iCondition,iTrial);
        
        % go over by maps.
        for iUnit = 1:size(cdtOld.map,1)
            spikeTimesThisUnitNew = spikeTimesNewThis(...
                spikeElecNewThis==cdtOld.map(iUnit,1) & spikeUnitNewThis==cdtOld.map(iUnit,2));
            if isempty(spikeTimesThisUnitNew)
                assert(isempty(spikeTimesOldThis{iUnit}));
            else
                assert(numel(spikeTimesThisUnitNew)==1);
                assert(max(abs(spikeTimesOldThis{iUnit}(:)-spikeTimesThisUnitNew{1}(:)))<tol);
            end
        end
    end
    
    
    %% times.
    starttimeNew = cdtNew.starttime(cdtNew.condition==iCondition,:);
    stoptimeNew = cdtNew.stoptime(cdtNew.condition==iCondition,:);
    
    for iTrial = 1:trialCount(iCondition)
        starttimeThisOld = cdtOld.time.start_time{iCondition,iTrial};
        stoptimeThisOld = cdtOld.time.stop_time{iCondition,iTrial};
        starttimeThisNew = starttimeNew(iTrial,:);
        stoptimeThisNew = stoptimeNew(iTrial,:);
        assert(max(abs(starttimeThisOld(:)-starttimeThisNew(:)))<tol);
        assert(max(abs(stoptimeThisOld(:)-stoptimeThisNew(:)))<tol);
    end
    
end

end


