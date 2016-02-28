function test_import_params_schema()
%TEST_IMPORT_PARAMS_SCHEMA test that import params schema works.
%
%   Please run ``generate_params_schema_cases.py`` before this.

n = 10000;
import cdttable.read_import_params
import cdttable.add_rm_dependency
add_rm_dependency('add')
for i = 1:n
    filename_good = fullfile('good_import_params', sprintf('%05d.json',i));
    filename_bad = fullfile('bad_import_params', sprintf('%05d.json',i));
    [~, isValid] = read_import_params(filename_good);
    assert(isValid);
    [~, isValid] = read_import_params(filename_bad);
    assert(~isValid);
    if rem(i,100) == 0
        disp(i);
    end
end
add_rm_dependency('rm')
end

