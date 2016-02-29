""" generate the preprocessing params for demo purpose.
"""
from __future__ import print_function, unicode_literals, division, absolute_import
import json
import collections
import os
import sys

baseline_template = collections.OrderedDict()
baseline_template['comment'] = "default preprocessing params for NEV/CTX reading"
baseline_template['spike_no_secondary_unit'] = True
baseline_template['spike_no_255_unit'] = True
baseline_template['spike_no_0_unit'] = False
baseline_template['throw_high_byte'] = True
baseline_template['fix_nev'] = True


def write_json(jsondict, filename):
    with open(os.path.join(sys.path[0],'demo_preprocessing_params',filename), 'wt') as f:
        f.write((json.dumps(jsondict, indent=2, separators=(',', ':'))))


def main():
    write_json(baseline_template, 'default.json')

if __name__ == '__main__':
    main()