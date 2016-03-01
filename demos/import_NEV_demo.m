function import_NEV_demo()
% IMPORT_NEV_DEMO ...
%
%   a demo showing importing NEV files using import_NEV package.
%
% Yimeng Zhang
% Computer Science Department, Carnegie Mellon University
% zym1010@gmail.com

%% DATE      : 23-Jul-2015 16:45:15 $
%% DEVELOPED : 8.3.0.532 (R2014a)
%% FILENAME  : import_NEV_demo.m

import cdttable.import_files


%% load file list.
basePathNEV = fullfile(root_dir(),'demos','import_NEV_demo_data');
basePathCTX = fullfile(root_dir(),'demos','import_NEV_demo_data');

NEV_list = {
    fullfile(basePathNEV,'v1_2012_1105_003.nev');
    fullfile(basePathNEV,'v1_2012_1105_004.nev');
    };

CTX_list = {
    fullfile(basePathCTX,'GA110512.3');
    fullfile(basePathCTX,'GA110512.4');
    };

%% get path for parameters
templatePath = fullfile(nevreader.root_dir(), 'demo_trial_templates', '3ec_edge_or.json');
preprocessParamsPath = fullfile(nevreader.root_dir(), 'demo_preprocessing_params', 'default.json');
importParamsPath = fullfile(cdttable.root_dir(), 'demo_import_params', 'edge_test.json');

argList = cell(numel(NEV_list),1);

for iFile = 1:numel(argList)
    argList{iFile} = cell(4,1);
    argList{iFile}{1} = NEV_list{iFile};
    argList{iFile}{2} = preprocessParamsPath;
    argList{iFile}{3} = templatePath;
    argList{iFile}{4} = CTX_list{iFile};
end

%% do the actual conversion.
CDTTables = import_files(@nevreader.preprocessing_func, argList, importParamsPath);



%% save the result.
saveDir = fullfile(root_dir(),'demos','import_NEV_demo_results');
saveFileName = 'import_NEV_demo_result'; % no extension, which will be appended automatically.
% a custom meta field. set metaInfo = [] or just don't pass it into
% save_CDTTable if you don't need it.
metaInfo = struct();
metaInfo.NEV_list = NEV_list;
metaInfo.CTX_list = CTX_list;
metaInfo.timestamp = datestr(now,30);

save_CDTTable(fullfile(saveDir,saveFileName),CDTTables,metaInfo);

end

function save_CDTTable(savePath, CDTTables, metaInfo)
% demo function to save result. maybe it's good to change it into a
% standalone function.

if nargin < 4 || isempty(metaInfo)
    metaInfo = [];
end

save([savePath '.mat'],'CDTTables','savePath','metaInfo');


end




% Created with NEWFCN.m by Frank González-Morphy
% Contact...: frank.gonzalez-morphy@mathworks.de
% ===== EOF ====== [import_NEV_demo.m] ======
