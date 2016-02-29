function hack_javapath()

matlabPrefDir = prefdir();
javalibPathToInsert = fullfile(cdttable.root_dir(), 'json-schema-validator-2.2.6-lib.jar');
currentJavaClassPathStatic = javaclasspath('-static');
% it's already in the static path.
if any(strcmp(currentJavaClassPathStatic,javalibPathToInsert))
    fprintf('hack is already done!');
    return
end

% otherwise, let's hack it.
classpassFilePath = fullfile(matlabPrefDir, 'javaclasspath.txt');
classpassFilePathBAK = fullfile(matlabPrefDir, 'javaclasspath.txt.bak');
if exist(classpassFilePath,'file') == 2
    fprintf('javaclasspath.txt already exist under %s\n', matlabPrefDir);
    fprintf('I will rename it to javaclasspath.txt.bak\n')
    assert(exist(classpassFilePathBAK,'file')==0,'the backup file should not exist');
    movefile(classpassFilePath, classpassFilePathBAK);
    assert(exist(classpassFilePathBAK,'file')==2,'the backup file should be there now');
    assert(exist(classpassFilePathBAK,'file')==2,'the original file should not exist now');
end

f = fopen(classpassFilePath, 'wt');
fprintf(f,'<before>\n');
fprintf(f,'%s\n',javalibPathToInsert);
fclose(f);
fprintf('done!\n');
end