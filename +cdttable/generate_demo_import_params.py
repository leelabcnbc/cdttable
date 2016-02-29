""" generate the template import params for import_trials.
"""
from __future__ import print_function, unicode_literals, division, absolute_import
import json
import copy
import os
from collections import OrderedDict

baseline_import_params = {
    "comment": "",
    "subtrials": [],
    "trial_to_condition_func": "(codes, idx) codes(1)+idx",
}


def generate_import_params_edge_test():
    import_params = OrderedDict()
    import_params['comment'] = "params for experiment edge_test, in Corentin's data"
    import_params['subtrials'] = []
    import_params['subtrials'].append(OrderedDict([('start_code', 25), ('end_code', 26)]))
    import_params['subtrials'].append(OrderedDict([('start_code', 27), ('end_code', 28)]))
    import_params['subtrials'].append(OrderedDict([('start_code', 29), ('end_code', 30)]))
    import_params['trial_to_condition_func'] = "(NEV_code, idx) (NEV_code(6)-192)*64+(NEV_code(7)-192)+1"
    import_params['margin_before'] = 0.3
    import_params['margin_after'] = 0.3
    return import_params


def main():
    filename = os.path.join("demo_import_params", "edge_test.json")
    with open(filename, 'wt') as f:
        json.dump(generate_import_params_edge_test(), f, indent=2, separators=(',', ':'))


if __name__ == '__main__':
    main()
