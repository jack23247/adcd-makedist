# adcd_makedist

Converts an OS/390 ADCD disk image set into an Hercules distribution

> *Caveat*
>
> `makedist` is intended as a tool for mainframe hobbyists, not for software
pirates: thus, this repository does not contain the disk images required to use
this software, as they are property of IBM.
> Before using this script you should understand that OS/390 ADCD is not
licensed to run on anything other than a P/390 or an R/390 system, and running
the distribution derived from this script constitutes a violation of IBM's
license agreement.

## Files

- `v1r2/` - Files specific to the V1R2 distribution
    - `p390.cnf` - Configuration file for V1R2 based on DEVMAP.NME from the
                   OS/390 ADCD V1R2 image set
    - `run.sh` - Convenience script that sets up a tunnel and runs Hercules
- `v2r10/` - Files specific to the V2R10 distribution
- `makedist.sh` - The main script that checks the images' checksums and
                  performs the conversion
- `README.md` - This file

## Prerequisites

### Supported OSes

The script has been developed and tested on Ubuntu and Fedora Linux, and should
work on any distribution that has `bash` and `hercules` without issues. I plan
to make it `sh`-compatible in the future to allow it to run on more OSes.

### Dependencies

- `makedist.sh` - Mandatory
    - `bash`
    - `sudo`
    - `md5sum`
    - `unzip`
    - `dasdcopy` (part of Hercules)
- `run.sh` - Mandatory
    - `bash`
    - `sudo`
    - `hercules`
. `run.sh`
    - `c3270`
    - `tmux`
    - `x3270`- Only for Desktop Mode

## Usage

### Syntax

`./makedist -d DISTNAME -f IMGFILE [ OPTIONS ]`

### Options

- `DISTNAME` - Either `v1r2` or `v2r10` (the former is currently unsupported due to a regression)
- `IMGFILE` - The path to the disk image
- `OPTIONS`
    - `-o` - Overwrites an existing distribution
    - `-h` - Display help

### Example

```
$ chmod +x makedist.sh
$ ./makedist.sh -d v2r10 -D path/to/isos -o
```

Creates a v2r10 distribution from disk images located into `./path/to/isos` overwriting existing distribution files.

> Please note that the script does not copy over the convenience files:
you should do that manually as they define important Hercules operating
parameters that you may want to edit before running on your system

## TODOs

In order of importance:

- [ ] Fixing v1r2
- [x] Testing on different Linux distributions
- [ ] Adding an option to choose a different target directory
- [x] Adding support for v2r10 (mainly ISO checksums, DASD conversion strategies
    and the translation of DEVMAP.NME)
- [ ] Allow using `/tmp` as cache
- [ ] Adding checksums and strategies for converting different distributions,
    such as VM/ESA ADCD
- [ ] Adding an interactive configurator (for `p390.cnf` and `run.sh`)

## Contributing

Tickets and PRs for bugs or feature requests are very welcome, if anyone wants
to tackle something that's on the TODO list just open a ticket and we'll set up
a roadmap together
