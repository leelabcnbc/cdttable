function [ criteria ] = ctx_prune_criteria(scenario)
%CTX_PRUNE_CRITERIA return the criteria for pruning ctx.
%   Now only three rules; more can be added.

%   Yimeng Zhang, 09/17/2013
%   Pittsburgh, PA

if nargin < 1
    scenario = 'reasonable_trial';
end

switch scenario
    case 'reasonable_trial'
        criteria.maxEventCode = 255; % can't go bigger than this.
        criteria.maxTimestamp = 10000; 
        criteria.isTimestampSorted = true;
    case 'rewarded_trial' % I think this part is never used...
        criteria.isRewardGiven = true;
        criteria.maxEventCode = 255; % can't go bigger than this.
        criteria.maxTimestamp = 10000; 
        criteria.isTimestampSorted = true;
end

end

