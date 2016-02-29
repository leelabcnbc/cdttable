function [ ctx_trial ] = prune_ctx_trial_corentin( ctx_trial )
%PRUNE_CTX_TRIAL_CORENTIN Summary of this function goes here
%   Detailed explanation goes here
% remove spikes (with event code 1)
    nonspike_idx = ctx_trial(:,1)~=1;
    ctx_trial = ctx_trial(nonspike_idx,:);
    
    % YIMENG: I don't think this is necessary, since we can indeed have multiple 96 (multiple rewards in a successful trial)
    % remove 96 96 % however, sometimes a third 96 can happen.. well,
    % that's very rare, anyway.
%     reward_idx = find(ctx_trial == 96);
%     
%     if length(reward_idx)==2
%         if (reward_idx(2)-reward_idx(1)==1)
%             ctx_trial(reward_idx(2),:) = [];
%         end
%     end

end

