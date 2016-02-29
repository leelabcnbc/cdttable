function [ flag ] = is_reasonable_CTX_trial( ctx_trial )
%IS_VALID_CTX_TRIAL Summary of this function goes here
%   Detailed explanation goes here
import nevreader.ctx_prune_criteria

flag = true;

prune_criteria = ctx_prune_criteria('reasonable_trial');

if isfield(prune_criteria, 'maxEventCode')
    flag = flag & (max(ctx_trial.record.event_code)<=prune_criteria.maxEventCode);
end

if isfield(prune_criteria, 'maxTimestamp')
    flag = flag & (max(ctx_trial.record.event_time)<=prune_criteria.maxTimestamp);
end

if isfield(prune_criteria, 'isTimestampSorted')
    flag = flag & (issorted(ctx_trial.record.event_time)==prune_criteria.isTimestampSorted);
end

end

