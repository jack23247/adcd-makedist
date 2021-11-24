# adcd_makedist

Converts an OS/390 ADCD disk image set into an Hercules distribution

> *Caveat*
>
> - OS/390 ADCD is not licensed to run on anything other than a P/390 or an R/390 system
> - This repository does not contain the disk images required to use this software, as they are property of IBM

## Files

- `v1r2/` - Files specific to the V1R2 distribution
    - `p390.cnf` - Configuration file for V1R2 based on DEVMAP.NME from the OS/390 ADCD V1R2 image set
    - `run.sh` - Convenience script that sets up a tunnel and runs Hercules
<!--- `v2r10/` - Files specific to the V2R10 distribution (proposed)-->
- `makedist.sh` - The main script that checks the images' checksums and does the conversion
- `README.md` - This file

## Prerequisites

### Supported OSes

The script has been developed and tested on Ubuntu Linux, and should work on any Debian-based distro without change

### Dependencies

- `makedist.sh` - Mandatory
    - `bash`
    - `sudo`
    - `md5sum`
    - `unzip`
    - `dasdcopy` (part of Hercules)
- `run.sh` - Optional
    - `bash`
    - `sudo`
    - `hercules`
    - `c3270`
    - `tmux`
    - `x3270`- Only for Desktop Mode

## Usage

### Syntax

`./makedist -d DISTNAME -f IMGFILE [ OPTIONS ]`

### Options

- `DISTNAME` - Either `v1r2` or `v2r10` (the latter is currently unsupported)
- `IMGFILE` - The path to the disk image
- `OPTIONS`
    - `-o` - Overwrites an existing distribution
    - `-h` - Display help

### Example

```
$ chmod +x makedist.sh
$ ./makedist.sh -d v1r2 -f disk1.iso -f disk2.iso -o
```

Creates a V1R2 distribution from disk images disk1.iso and disk2.iso, overwriting existing distribution files

> *Caveat*
>
> The script does not copy over the convenience files from `v1r2/`: you should do that manually as they define important Hercules operating parameters that you may want to edit before running on your system.

## TODOs

In order of importance: 

- Testing on different Linux distributions
- Adding an option to choose a different target directory
- Adding support for V2R10 (mainly ISO checksums, DASD conversion strategies and the translation of DEVMAP.NME)
- Adding checksums and strategies for converting different images (if they exist)
- Adding an interactive configurator (for `p390.cnf` and `run.sh`)

## Contributing

Tickets and PRs for bugs or feature requests are very welcome, if anyone wants to tackle something that's on the TODO list just open a ticket and we'll set up a roadmap together
