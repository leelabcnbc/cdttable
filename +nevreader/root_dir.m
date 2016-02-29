function [ rootDir ] = root_dir()
%ROOT_DIR return directory of package root.
%
%   this is convenient for getting locations of various files in the
%   package.

[rootDir,~,~] = fileparts(mfilename('fullpath'));

end

