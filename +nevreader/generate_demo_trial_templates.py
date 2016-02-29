""" generate the trial templates for Corentin's old experiments.
"""
from __future__ import print_function, unicode_literals, division, absolute_import
import json
import collections
import copy
import os
import sys

baseline_template_codes = [
    {'type': 'SINGLE', 'code': 9},
    {'type': 'SINGLE', 'code': 10},
    {'type': 'SINGLE', 'code': 15},
    {'type': 'SINGLE', 'code': 100},
    {'type': 'SINGLE', 'code': 16},
    {'type': 'SINGLE', 'code': 23},
    {'type': 'SINGLE', 'code': 8},
    {'type': 'SINGLE', 'code': 25},
    {'type': 'SINGLE', 'code': 26},
    {'type': 'SINGLE', 'code': 27},
    {'type': 'SINGLE', 'code': 28},
    {'type': 'SINGLE', 'code': 29},
    {'type': 'SINGLE', 'code': 30},
    {'type': 'RANGE', 'min_value': 121, 'max_value': 124, 'missable': False},
    {'type': 'SINGLE', 'code': 120},
    {'type': 'SINGLE', 'code': 8},
    {'type': 'SINGLE', 'code': 24},
    {'type': 'SINGLE', 'code': 17},
    {'type': 'SINGLE', 'code': 0},
    {'type': 'SINGLE', 'code': 101},
    {'type': 'SINGLE', 'code': 96},
    {'type': 'SINGLE', 'code': 18},
]


cg_template_codes = [
    {'type': 'SINGLE', 'code': 9},
    {'type': 'SINGLE', 'code': 10},
    {'type': 'SINGLE', 'code': 15},
    {'type': 'SINGLE', 'code': 100},
    {'type': 'SINGLE', 'code': 16},
    {'type': 'RANGE', 'min_value': 192, 'max_value': 195, 'missable': False},
    {'type': 'RANGE', 'min_value': 192, 'max_value': 255, 'missable': True},
    {'type': 'SINGLE', 'code': 23},
    {'type': 'SINGLE', 'code': 8},
    {'type': 'SINGLE', 'code': 25},
    {'type': 'SINGLE', 'code': 26},
    {'type': 'SINGLE', 'code': 27},
    {'type': 'SINGLE', 'code': 28},
    {'type': 'SINGLE', 'code': 29},
    {'type': 'SINGLE', 'code': 30},
    {'type': 'RANGE', 'min_value': 121, 'max_value': 124, 'missable': False},
    {'type': 'SINGLE', 'code': 120},
    {'type': 'SINGLE', 'code': 8},
    {'type': 'SINGLE', 'code': 24},
    {'type': 'SINGLE', 'code': 17},
    {'type': 'SINGLE', 'code': 0},
    {'type': 'SINGLE', 'code': 101},
    {'type': 'SINGLE', 'code': 96},
    {'type': 'SINGLE', 'code': 18},
]

contrast_template_codes = [
    {'type': 'SINGLE', 'code': 9},
    {'type': 'SINGLE', 'code': 10},
    {'type': 'SINGLE', 'code': 15},
    {'type': 'RANGE', 'min_value': 140, 'max_value': 171, 'missable': False},
    {'type': 'SINGLE', 'code': 100},
    {'type': 'SINGLE', 'code': 16},
    {'type': 'SINGLE', 'code': 23},
    {'type': 'SINGLE', 'code': 8},
    {'type': 'SINGLE', 'code': 33},
    {'type': 'SINGLE', 'code': 31},
    {'type': 'RANGE', 'min_value': 121, 'max_value': 123, 'missable': False},
    {'type': 'SINGLE', 'code': 120},
    {'type': 'SINGLE', 'code': 11},
    {'type': 'SINGLE', 'code': 8},
    {'type': 'SINGLE', 'code': 31},
    {'type': 'SINGLE', 'code': 24},
    {'type': 'SINGLE', 'code': 17},
    {'type': 'SINGLE', 'code': 101},
    {'type': 'SINGLE', 'code': 96},
    {'type': 'SINGLE', 'code': 18},
]


baseline_template = collections.OrderedDict()
baseline_template['comment'] = ""
baseline_template['startcode'] = 9
baseline_template['stopcode'] = 18
baseline_template['rewardcode'] = 96
baseline_template['codes'] = baseline_template_codes

def write_json(jsondict, filename):
    with open(os.path.join(sys.path[0],'demo_trial_templates',filename), 'wt') as f:
        f.write((json.dumps(jsondict, indent=2, separators=(',', ':'))))

def main():
    _3ec_edge_cal = copy.deepcopy(baseline_template)
    _3ec_edge_cal['codes'].insert(4, {'type': 'RANGE', 'min_value': 192, 'max_value': 192, 'missable': False})
    _3ec_edge_cal['codes'].insert(5, {'type': 'RANGE', 'min_value': 192, 'max_value': 255, 'missable': True})
    _3ec_edge_cal['comment'] = "trial template for 3ec_xxx tm file and edge_cal cnd file"
    write_json(_3ec_edge_cal, '3ec_edge_cal.json')

    _3ec_edge_or = copy.deepcopy(baseline_template)
    _3ec_edge_or['codes'].insert(4, {'type': 'RANGE', 'min_value': 192, 'max_value': 198, 'missable': False})
    _3ec_edge_or['codes'].insert(5, {'type': 'RANGE', 'min_value': 192, 'max_value': 255, 'missable': True})
    _3ec_edge_or['comment'] = "trial template for 3ec_xxx tm file and edge_or cnd file"
    write_json(_3ec_edge_or, '3ec_edge_or.json')

    _3ec_edge_or0 = copy.deepcopy(baseline_template)
    _3ec_edge_or0['codes'].insert(4, {'type': 'RANGE', 'min_value': 192, 'max_value': 198, 'missable': False})
    _3ec_edge_or0['codes'].insert(5, {'type': 'RANGE', 'min_value': 192, 'max_value': 255, 'missable': True})
    _3ec_edge_or0['comment'] = "trial template for 3ec_xxx tm file and edge_or0 cnd file"
    write_json(_3ec_edge_or0, '3ec_edge_or0.json')

    _3ec_edge_pos = copy.deepcopy(baseline_template)
    _3ec_edge_pos['codes'].insert(4, {'type': 'RANGE', 'min_value': 192, 'max_value': 199, 'missable': False})
    _3ec_edge_pos['codes'].insert(5, {'type': 'RANGE', 'min_value': 192, 'max_value': 255, 'missable': True})
    _3ec_edge_pos['comment'] = "trial template for 3ec_xxx tm file and edge_pos cnd file"
    write_json(_3ec_edge_pos, '3ec_edge_pos.json')

    _3ec_gratings = copy.deepcopy(baseline_template)
    _3ec_gratings['codes'].insert(4, {'type': 'RANGE', 'min_value': 192, 'max_value': 192, 'missable': False})
    _3ec_gratings['codes'].insert(5, {'type': 'RANGE', 'min_value': 192, 'max_value': 207, 'missable': True})
    _3ec_gratings['comment'] = "trial template for 3ec_xxx tm file and gratings cnd file"
    write_json(_3ec_gratings, '3ec_gratings.json')

    _3ec_images = copy.deepcopy(baseline_template)
    _3ec_images['codes'].insert(4, {'type': 'RANGE', 'min_value': 192, 'max_value': 192, 'missable': False})
    _3ec_images['codes'].insert(5, {'type': 'RANGE', 'min_value': 192, 'max_value': 208, 'missable': True})
    _3ec_images['comment'] = "trial template for 3ec_xxx tm file and images cnd file"
    write_json(_3ec_images, '3ec_images.json')

    cg = copy.deepcopy(baseline_template)
    cg['codes'] = cg_template_codes
    cg['comment'] = "trial template for cg tm file"
    write_json(cg, 'cg.json')

    contrast = copy.deepcopy(baseline_template)
    contrast['codes'] = contrast_template_codes
    contrast['comment'] = "trial template for contrast tm file and contrast cnd file"
    write_json(contrast, 'cg.json')

if __name__ == '__main__':
    main()