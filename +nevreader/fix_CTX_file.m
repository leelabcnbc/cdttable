function [CTX_codes_new, CTX_times_new, ...
    rewarded_trials,false_rewarded_trials,...
    fixed_rewarded_trials,reasonable_trials,CTX_struct]=...
    fix_CTX_file(CTX_file_name, trial_template)
%FIX_CTX_FILE fix CTX file.
%   fix_time_count is a vector recording number of fixes applied to each
%   trial.
%   Yimeng Zhang, 09/17/2013
%   Pittsburgh, PA


% return values.
% CTX_codes_new, CTX_times_new: fixed trial codes and times.
% rewarded_trials: index of all fixed trials.
% fixed_rewarded_trials: index of all fixed trials that are broken before
% fixing.
% reasonable_trials: index of all "reasonable" trials, that is, trials
% worth considering.
% false_rewarded_trials: index of trials that looks like a good trial
% before fixing.
% CTX_struct: the struct storing the content of the CTX file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
import nevreader.ctx2mat_new
import nevreader.fix_NEV_trial_TM
import nevreader.is_valid_CTX_trial
import nevreader.is_reasonable_CTX_trial
import nevreader.prune_ctx_trial_corentin

%% read CTX file.
CTX_struct=ctx2mat_new(CTX_file_name);


%% init arrays.

CTX_codes_new = {};
CTX_times_new = {};

reasonable_trials = [];
rewarded_trials = [];
false_rewarded_trials = [];
fixed_rewarded_trials = [];

%% get reward code
rewardcode = double(trial_template.get('reward_code'));

%% for loop over trials.

for i = 1:length(CTX_struct)
    %fprintf('fixing trial %d...\n',i);
    
    CTX_trial_struct = CTX_struct{i};
    
    if is_valid_CTX_trial(CTX_trial_struct) && is_reasonable_CTX_trial(CTX_trial_struct) % we only consider reasonable trial...
        
        reasonable_trials(end+1) = i;
        
        CTX_trial_event = [CTX_trial_struct.record.event_code, CTX_trial_struct.record.event_time];
        % is this necessary? I don't think so. TODO: try runing ON/OFF this
        % option.
        CTX_trial_event = prune_ctx_trial_corentin(CTX_trial_event); %pre process... remove spikes
        
        if ismember(rewardcode, CTX_trial_event(:,1)) % fixing a perhaps good trial (yes, sometimes ctx can get corruptted..)
            %fprintf('fixing a perhaps good trial...\n');
            [CTX_trial_event_new, fixable] = fix_NEV_trial_TM(CTX_trial_event, trial_template.get('codes'));
            if fixable
                rewarded_trials(end+1) = i;
                % put them back as cells... or I need some other formats?
                CTX_codes_new{end+1} = CTX_trial_event_new(:,1);
                CTX_times_new{end+1} = CTX_trial_event_new(:,2);
                
                if ~isequal(CTX_trial_event_new,CTX_trial_event)
                    fixed_rewarded_trials(end+1) = i;
                end
            else
                false_rewarded_trials(end+1) = i;
            end
        end
    end
end

CTX_codes_new = CTX_codes_new(:);
CTX_times_new = CTX_times_new(:);
rewarded_trials = rewarded_trials(:);
false_rewarded_trials = false_rewarded_trials(:);
fixed_rewarded_trials = fixed_rewarded_trials(:);
reasonable_trials = reasonable_trials(:);

fprintf('in total, %d rewarded trials from CTX\n', length(rewarded_trials));

end