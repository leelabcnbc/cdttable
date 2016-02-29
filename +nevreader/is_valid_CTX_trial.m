function [ flag ] = is_valid_CTX_trial( ctx_trial )
%IS_VALID_CTX_TRIAL Summary of this function goes here
%   Detailed explanation goes here
flag = true;

if ~isfield(ctx_trial,'header') || ~isfield(ctx_trial,'record')
    flag = false;
    return;
end

if ~isfield(ctx_trial.record, 'event_time') || ~isfield(ctx_trial.record, 'event_code') || ~isfield(ctx_trial.record, 'epp_channels')...
        || ~isfield(ctx_trial.record, 'epp') || ~isfield(ctx_trial.record, 'eog')
    flag = false;
    return;
end

if ~all(size(ctx_trial.record.event_time)==size(ctx_trial.record.event_code))
    flag = false;
    return;
end

if isempty(ctx_trial.record.event_time)
    flag = false;
    return;
end


end

