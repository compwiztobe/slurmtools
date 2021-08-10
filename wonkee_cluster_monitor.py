#!/usr/bin/python

import json
import os
import sys
from collections import Counter, OrderedDict

with open(os.path.expanduser("~")+"/sinfo.json") as f:
    sinfo = json.load(f, object_pairs_hook=OrderedDict)

lines = sys.stdin.readlines()

pending=Counter()
running=Counter()
nodes=Counter()

me = os.getlogin()
mypending=Counter()
myrunning=Counter()
mynodes=Counter()

for line in lines:
    if line.startswith('JOBID'):
        continue
    line = line.strip().split()
    user = line[3]
    GPU = line[5]
    numGPU = line[9].split(':')[-1]
    try:
        numGPU = int(numGPU)
    except:
        numGPU = 0
    if line[2] == 'PENDING':
        pending[GPU] += numGPU
        if user == me:
            mypending[GPU] += numGPU
    else:
        running[GPU] += numGPU
        nodeNum = line[7]
        nodes[nodeNum] += numGPU
        if user == me:
            myrunning[GPU] += numGPU
            mynodes[nodeNum] += numGPU

import re

def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(item):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''
    return [ atoi(c) for c in re.split(r'(\d+)', item[0]) ]

print("**** [GPUs reserved] ****")
print("   me / all jobs / total  -> available ( / pending )")
print("")
for GPU, num in sinfo['GPUs'].items():
    print("- {:<8}: {:>2} / {:>2} / {:>2}  -> {:>2} / {:>2}".format(GPU, myrunning[GPU], running[GPU], num, num - running[GPU], pending[GPU]))
print("")
print("per node:")
for node, num in sorted(sinfo['nodes'].items(),key=natural_keys):
    print("- {:<4}: {:>2} / {:>2} / {:>2}  -> {:>2}".format(node, mynodes[node], nodes[node], num, num - nodes[node]))
