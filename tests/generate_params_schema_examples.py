""" generate the template import params for import_trials.
"""
from __future__ import print_function, unicode_literals, division, absolute_import
import json
import copy
from generate_params_schema_cases import generate_subtrial_endcode, generate_subtrial_endtime

baseline_import_params = {
    "comment": "",
    "subtrials": [],
    "trial_to_condition_func": "(codes, idx) codes(1)+idx",
}


def generate_valid_import_params_example():
    import_params = copy.deepcopy(baseline_import_params)
    import_params['subtrials'].append(generate_subtrial_endcode())
    import_params['subtrials'].append(generate_subtrial_endtime())
    return import_params


def main():
    filename = "import_params_example.json"
    with open(filename, 'wt') as f:
        json.dump(generate_valid_import_params_example(), f, indent=2, separators=(',', ':'))


if __name__ == '__main__':
    main()
