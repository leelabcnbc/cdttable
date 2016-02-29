function prototxt = tm_cnd_pair_to_prototxt(tm_file_name, cnd_file_name)
% TM_CND_PAIR_TO_PROTOTXT convert pair of tm and cnd file names to prototxt
%
%   This can be only guranteed to work with Corentin's data for the fix NEV
%   project.
%
%   new projects should not use this file, rather, directly specify the
%   prototxt file
%
% Yimeng Zhang
% Computer Science Department, Carnegie Mellon University
% zym1010@gmail.com

%% DATE      : 22-Jul-2015 09:33:32 $
%% DEVELOPED : 8.3.0.532 (R2014a)
%% FILENAME  : tm_cnd_pair_to_prototxt.m

assert(~isempty(tm_file_name));
assert(~isempty(cnd_file_name));

switch lower(tm_file_name)
    case {'3ec_or.tm','3ec_ora.tm','3ec_a.tm','3ec.tm'}
        switch lower(cnd_file_name)
            case 'edge_or.cnd'
                prototxt = '3ec_edge_or.json';
            case 'images.cnd'
                prototxt = '3ec_images.json';
            case 'edge_pos.cnd'
                prototxt = '3ec_edge_pos.json';
            case 'gratings.cnd'
                prototxt = '3ec_gratings.json';
            case 'edge_or0.cnd'
                prototxt = '3ec_edge_or0.json';
            case 'edge_cal.cnd'
                prototxt = '3ec_edge_cal.json';
            otherwise
                error('no matching condition file');
        end
    case {'cg.tm'}
        prototxt = 'cg.json';
    case {'contrast.tm'}
        switch lower(cnd_file_name)
            case 'contrast.cnd'
                prototxt = 'contrast.json';
            otherwise
                error('no matching condition file');
        end
    otherwise
        error('no matching timing file');
end

end








% Created with NEWFCN.m by Frank González-Morphy
% Contact...: frank.gonzalez-morphy@mathworks.de
% ===== EOF ====== [tm_cnd_pair_to_prototxt.m] ======
