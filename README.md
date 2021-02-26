# lifespans

This repo is currently a mess.

| File          | Status        | Purpose                                                       |
|---------------|---------------|---------------------------------------------------------------|
| `bmp.c`       |               | Read .bmp file, output pixel data                             |
| `diff2.pl`    |               | Produce initial `var data`                                    |
| `diff.pl`     |               | Read from `bmp`, output compressed diff, `var patch`          |
| `makeptm.sh`  |               | Uses `bmp`, `diff2.pl`, `diff.pl` ; png -> bmp -> js          |
| `patch.html`  |               | Tests out rendering a diff (no .js file used)                 |
| `patch2.html` |               | Uses patch3.js                                                |
| `patch3.js`   |               | Data file                                                     |
| `index.html`  |               | Displays lifespans of famous people                           |
| `rank.pl`     |               | Used to put names of people in index.html into rows           |
| `patch.js`    | Not used      | Data file                                                     |
| `format.pl`   | Not used      | ?                                                             |
| `diff.c`      | Not used      | Output diff between two images from `bmp`                     |

`makeptm.sh` combines the useful programs and scripts.
`Makefile` was made later to make it easier to build and run, but has some redundancy with `makeptm.sh`
