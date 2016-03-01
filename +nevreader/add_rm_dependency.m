function add_rm_dependency( choice )
%ADD_RM_DEPENDENCY add or remove java class dependency
%
%   Detailed explanation goes here
import nevreader.root_dir
javalibPath = fullfile(root_dir(), 'json-schema-validator-2.2.6-lib.jar');
currentJavaClassPath = javaclasspath('-dynamic');
currentJavaClassPathStatic = javaclasspath('-static');

% it's already in the static path.
if any(strcmp(currentJavaClassPathStatic,javalibPath))
    return
end

if isequal(choice, 'add')
    if any(strcmp(currentJavaClassPath,javalibPath))
        return
    else
        javaaddpath(javalibPath);
    end
elseif isequal(choice, 'rm')
    if all(~strcmp(currentJavaClassPath,javalibPath))
        return
    else
        javarmpath(javalibPath);
    end
else
    error('the option must be add or rm!');
end
end

