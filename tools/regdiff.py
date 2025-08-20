#!/usr/bin/env python3
import sys

def read_lines(p):
    with open(p, 'r', encoding='utf-8', errors='ignore') as f:
        return [l.strip() for l in f if l.strip()]

def main():
    if len(sys.argv) != 3:
        print("Usage: regdiff.py <fileA> <fileB>")
        sys.exit(1)
    a = read_lines(sys.argv[1])
    b = read_lines(sys.argv[2])
    n = max(len(a), len(b))
    for i in range(n):
        la = a[i] if i < len(a) else "<EOF>"
        lb = b[i] if i < len(b) else "<EOF>"
        if la != lb:
            print(f"[DIFF] line {i+1}:\n  A: {la}\n  B: {lb}")
            sys.exit(2)
    print("No difference.")
    sys.exit(0)

if __name__ == "__main__":
    main()
