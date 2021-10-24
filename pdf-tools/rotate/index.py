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


# Compress file and write out
rotation = str(files[0].strip(), "utf-8")
pdfdata = files[1]

with tempfile.NamedTemporaryFile() as f:
    f.write(pdfdata)
    converted = subprocess.run(
        ["qpdf", "--rotate=%s" % rotation, f.name, "-"], capture_output=True
    )

sys.stdout.buffer.write(converted.stdout)
sys.stderr.buffer.write(converted.stderr)
