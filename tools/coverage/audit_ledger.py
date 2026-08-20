#!/usr/bin/env python3
"""Self-audit the ledger: for every row it calls MISSING, does a plausibly-named
file exist anyway? Every hit is a POSSIBLE join failure to check by hand -- this
is deliberately noisy, because a false MISSING is the dangerous direction (it
invents work) and a silent false 'implemented' is worse (it hides work).
Run this whenever build_ledger.py changes."""
import re, os, glob, sys
ROOT=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
def core(s):
    s=re.sub(r'\([^)]*\)','',s); s=s.split('/')[0]; s=s.replace('_',' ')
    s=re.sub(r'\b(a|an|the)\b',' ',s,flags=re.I)
    return re.sub(r'[^a-z0-9]','',s.lower())
rows=[l.rstrip('\n').split('\t') for l in open(os.path.join(ROOT,'tools/coverage/data/ledger.tsv'))][1:]
missing=[r for r in rows if r[2]=='MISSING']
base={p: core(os.path.basename(p)[:-4]) for p in glob.glob(os.path.join(ROOT,'scripts/**/*.lua'), recursive=True)}
hits=[]
for r in missing:
    k=core(r[0])
    if len(k)<9: continue
    for p,b in base.items():
        if len(b)>=9 and (k in b or b in k) and abs(len(k)-len(b))<=6:
            hits.append((r[0], os.path.relpath(p,ROOT))); break
print(f'{len(missing)} MISSING rows, {len(hits)} with a similarly-named file (check by hand):')
for q,p in sorted(hits): print(f'  {q[:36]:38s} {p}')
