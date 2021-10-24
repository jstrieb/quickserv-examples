# Typeset Markdown

Typeset Markdown and generate PDF files. Depends on: 

- MLton
- Pandoc
- LaTeX

Compile `typeset` with `make` once the dependencies are installed.

## Example

This markdown:

`````markdown
---
title: Some Title
author: Your Name Here
emailname: emailprefix
emaildomain: gmail.com
...

\maketitle
\newpage

# First section

Enter your markdown here!

It works with inline math $\left(\frac 1 x + 2 = \alpha \cdot \beta\right)$ and math evironments:

$$ x + y = \sum_{n = 0}^\infty \frac {2n} {n!} \cdot \sin n = \int_0^\infty \frac {\ln 3x} x ~dx $$

## First subsection

There is also support for footnotes, inline links, etc.^[See! Check out this link! <https://example.com>]

---

Furthermore, there is support for code syntax highlighting:

``` python
import random

"""
The code below does some stuff
"""

def test(f, g):
    # Now we will apply f to g
    print(f(g))

if __name__ == "__main__":
    test(lambda x: x + 10, 20)
```

---

Now your *typeset* documents will look **just** like my ~~high school~~ college math homework!
`````

Creates this PDF:

<div align="center">
<img src="https://user-images.githubusercontent.com/7355528/138580069-914bb6d3-41b2-4182-beb8-ca725b5406f4.png" width="75%">
</div>
