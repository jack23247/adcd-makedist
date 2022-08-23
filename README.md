# adcd_makedist

![makedist.png](makedist.png)

Converts an OS/390 ADCD disk image set into an Hercules distribution

> *Caveat*
>
> `makedist` is intended as a tool for mainframe hobbyists, not for software pirates: thus, this repository does not contain the disk images required to use this software, as they are property of IBM.
> Before using this script you should understand that the ADCDs supported by `makedist` are not licensed to run on anything other than a P/390 or an R/390 system, and running the distribution derived from this script constitutes a violation of IBM's license agreement.

## Files

- `cnf/` - Configuration files for Hercules
    - `os390_v1r2.cnf` - Translation of `DEVMAP.NME` from the OS/390 V1R2 ADCD disk image set
	- `os390_v2r10.cnf` - Translation of `DEVMAP.NME` from the OS/390 V2R10 ADCD disk image set
- `makedist.sh` - The main script that checks the images' checksums and performs the conversion
- `README.md` - This file

## Prerequisites

### Supported OSes

The script has been developed and tested on `bash` under Ubuntu and Fedora Linux, and should work on any distribution that has `bash` and `hercules` without issues.

### Dependencies

- `makedist.sh` - Mandatory
    - `bash`
    - `sudo`
    - `md5sum`
    - `unzip`
    - `dasdcopy` (part of Hercules)

## Usage

### Example

```
$ chmod +x makedist
$ ./makedist -d v2r10 -D path/to/isos -t local/prefix -o
```

Creates an OS/390 V2R10 ADCD distribution into `./local/prefix` from disk images located into `./path/to/isos` overwriting existing distribution files.

> Please note that the script does not copy over the configuration files: you should do that manually as they define important Hercules operating parameters that you may want to edit before running on your system

## TODOs

In order of importance:

- [x] Fixing v1r2
- [x] Testing on different Linux distributions
- [ ] Adding an option to choose a different target directory
- [x] Adding support for v2r10 (mainly ISO checksums, DASD conversion strategies and the translation of DEVMAP.NME)
- [x] Allow using `/tmp` as cache
- [ ] Adding checksums and strategies for converting VM/ESA V2R4 ADCD and VSE/ESA V2R4 ADCD

## Contributing

Tickets and PRs for bugs or feature requests are very welcome, if anyone wants to tackle something that's on the TODO list just open a ticket and we'll set up a roadmap together
