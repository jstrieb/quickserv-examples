#!/usr/bin/env python3

import subprocess
import sys
import tempfile

# Read multipart form data
raw = sys.stdin.buffer.read()
boundary = raw.splitlines()[0]


def trim(f):
    # Strip all headers
    i = f.find(b"\r\n\r\n") + 4
    return f[i:]


files = [trim(f) for f in raw.split(boundary)[1:-1]]

tempfiles = []
for f in files:
    tempfiles.append(tempfile.NamedTemporaryFile())
    tempfiles[-1].write(f)

outfile = tempfile.NamedTemporaryFile()

converted = subprocess.run(
    ["pdfunite", *map(lambda f: f.name, tempfiles), outfile.name], capture_output=True
)

sys.stdout.buffer.write(outfile.read())

sys.stderr.buffer.write(converted.stdout)
sys.stderr.buffer.write(converted.stderr)

outfile.close()
for f in tempfiles:
    f.close()
