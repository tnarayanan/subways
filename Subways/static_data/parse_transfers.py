from collections import defaultdict

d = defaultdict(set)

with open('transfers.txt', 'r') as f:

    for i, line in enumerate(f):
        if i == 0:
            continue
        sp = line.split(',')
        if sp[0] == sp[1]:
            continue

        mn, mx = min(sp[0], sp[1]), max(sp[0], sp[1])
        d[mn].add(mx)

while True:
    valid = True
    update_pair = None
    for k in d:
        if not valid:
            break
        for v in d[k]:
            if not valid:
                break
            if v in d:
                update_pair = (k, v)
                valid = False

    if update_pair is None:
        break
    k, v = update_pair
    d[k].update(d[v])
    del d[v]

for k in d:
    print('case ', end='')
    for i, v in enumerate(d[k]):
        if i > 0:
            print(', ', end='')
        print(f'"{v}"', end='')
    print(':')
    print(f'\t"{k}"')
