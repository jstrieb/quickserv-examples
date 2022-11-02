#!python3

import subprocess
import sys

# Read multipart form data
raw = sys.stdin.buffer.read()
boundary = raw.splitlines()[0]


def trim(f):
    # Strip all headers
    i = f.find(b"\r\n\r\n") + 4
    return f[i:]


files = [trim(f) for f in raw.split(boundary)[1:-1]]


# Compress file and write out
pdfdata = files[0]

compressed = subprocess.run(
    (
        "gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 "
        "-dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=- -"
    ).split(),
    input=pdfdata,
    capture_output=True,
)

sys.stdout.buffer.write(compressed.stdout)
sys.stderr.buffer.write(compressed.stderr)
