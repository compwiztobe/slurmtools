import sys
import os
from collections import defaultdict

#if len(sys.argv) != 2:
#    print("Usage: python {} {}".format(os.path.basename(sys.argv[0]), 'FilePath'))
#    exit

#f = open(sys.argv[1], 'r')
lines = sys.stdin.readlines()
#lines = f.readlines()
pending=defaultdict(int)
runGPU=defaultdict(int)
runNode=defaultdict(int)

for i, line in enumerate(lines):
    if i == 0: continue
    elif line.startswith('JOBID'): continue
    line = line.strip().split()
    if line[2] == 'PENDING':
        GPU = line[5]
        numGPU = int(line[9].split(':')[-1])
        pending[GPU] += numGPU
    else:
        nodeNum = line[7]
        GPU = line[5]
        numGPU = int(line[9].split(':')[-1])
        runNode[nodeNum] += numGPU
        runGPU[GPU] += numGPU
#f.close()

print("****  [PENDING STATUS]  **** ")
for GPU, num in sorted(pending.items()):
    print("- {:<8}: {}".format(GPU, num))

print("\n****  [RUNNING STATUS]  **** ")
print(">> running gpus:")
for GPU, num in sorted(runGPU.items()):
    print("- {:<8}: {}".format(GPU, num))
print("\n>> running nodes:")
for node, num in sorted(runNode.items()):
    print("- {:<4}: {}".format(node, num))
