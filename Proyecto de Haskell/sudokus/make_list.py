import sys
r = open(sys.argv[1])
s = r.readlines()
sol = []
for x in s: sol += x.split()
s = [int(x) for x in sol]

w = open("sudoku_to_list.txt",mode='w')
w.write(str(s))
w.close()
r.close()

print(type(s[0]))