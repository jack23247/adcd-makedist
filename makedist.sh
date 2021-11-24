#!/bin/bash
# makedist.sh
# Converts an OS/390 ADCD disk image set into an Hercules distribution

# md_funct

md_abend () {
    rm -rf p390
    rm readme-mvs.txt
    md_cleanup
}

md_cleanup () {
    rm -rf tmp
    sudo umount /mnt >/dev/null 2>&1
    echo
}

md_usage () (
    printf "Converts an OS/390 ADCD disk image set into an Hercules distribution.\nUsage:\t./makedist -d DISTNAME -f IMGFILE [ OPTIONS ]\nWhere:\tDISTNAME = {v1r2 | v2r10}\n\tIMGFILE = Path of the disk image (one per each flag)\n\tOPTIONS = {-o[verwrite] | -h[elp]}\n"
)

# md_check_sudo

if [[ "$EUID" == 0 ]]; then
  printf "This script will automatically request superuser privileges when\n they are required.\n"
  exit
fi

# md_check_deps

hash sudo 2>/dev/null || { echo "Please install \"sudo\" before running makedist."; exit; }
hash md5sum 2>/dev/null || { echo "Please install \"md5sum\" before running makedist."; exit; }
hash unzip 2>/dev/null || { echo "Please install \"unzip\" before running makedist."; exit; }
hash dasdcopy 2>/dev/null || { echo "Cannot find \"dasdcopy\": please install Hercules."; exit; }

# md_getopts

while getopts ":d:f:h:o" opt; do
    case $opt in
        d) distrib=("$OPTARG");;
        f) image_files+=("$OPTARG");;
        h) md_usage && exit;;
        o) overwrite=1;;
        *) md_usage && exit;;
    esac
done
shift $((OPTIND -1))

# md_check_distrib_valid

if [ ! $distrib ]; then
    echo "No distribution specified."
    exit
elif [ $distrib == "v1r2" ] || [ $distrib == "v2r10" ]; then
    echo "Attempting to build distribution \"$distrib\"."
else
    echo "Unknown distribution \"$distrib\"."
    exit
fi

# md_check_disk_images_v1r2

for image_file in "${image_files[@]}"; do
    if [[ ! -f $image_file ]]; then
        echo "Error opening \"$image_file\: no such file or directory."
        exit
    elif [ $distrib == "v1r2" ]; then
        image_file_md5=$(md5sum $image_file | cut -f1 -d" ")
        if [ $image_file_md5 == "bfdc6219a72df802e5df2a40ca24d331" ]; then
            echo "Found image \"OS/390 V1R2 ADCD CD1\"."
            v1r2_cd1=$image_file
        elif [ $image_file_md5 == "8bf8870839e3b54b1519b2a93dc184ba" ]; then
            echo "Found image \"OS/390 V1R2 ADCD CD2\"."
            v1r2_cd2=$image_file
        else
            echo "Invalid image file for distribution \"v1r2\"."
            exit
        fi
    elif [ $distrib == "v2r10" ]; then
        echo "This distribution is not supported in the current release."
        exit
    else
        echo "Unhandled exception."
        exit
    fi
done

if [[ $distrib == "v1r2" && ( $v1r2_cd1 == "" || $v1r2_cd2 == "" ) ]]; then
    printf "One or more required disk image files missing or unspecified.\n"
    exit
fi

# md_check_existing_dist_v1r2

if [[ $distrib == "v1r2" && -d "os390/" ]]; then
    if [[ $overwrite != 1 && -f "os390/mvswk1.122" && -f "os390/pr39r2.260" && -f "os390/pr39d2.261" ]]; then
        echo "A valid distribution already exists."
        exit
    else
        echo "Overwriting previous distribution..."
        rm -rf os390/
    fi
fi

# md_make_tmp

mkdir -p tmp/ 
if [[ ! -d "tmp/" ]]; then
    printf "Unable to create the temporary directory."
    md_cleanup && exit
fi

 # md_make_v1r2

if [ $distrib == "v1r2" ]; then
    sudo mount -o loop -r $v1r2_cd1 /mnt
    printf "Unpacking image \"OS/390 V1R2 ADCD CD1\":\n"
    cp /mnt/readme.mvs readme-mvs.txt
    chmod 664 readme-mvs.txt
    unzip -joL /mnt/mvswk1.zip -d tmp
    if [[ ! -f "tmp/MVSWK1.122" ]]; then
        printf "\nAn error occurred while unpacking the image."
        md_cleanup && exit
    fi
    unzip -joL /mnt/pr39r2.zip -d tmp
    if [[ ! -f "tmp/PR39R2_1.260" ]] || [[ ! -f "tmp/PR39R2_2.260" ]]; then
        printf "\nAn error occurred while unpacking the image."
        md_cleanup && exit
    fi
    sudo umount /mnt

    sudo mount -o loop -r $v1r2_cd2 /mnt
    printf "\nUnpacking image \"OS/390 V1R2 ADCD CD2\":\n"
    unzip -joL /mnt/pr39d2.zip -d tmp
    if [[ ! -f "tmp/PR39D2_1.261" ]] || [[ ! -f "tmp/PR39D2_2.261" ]]; then
        printf "\nAn error occurred while unpacking the image."
        md_cleanup && exit
    fi
    sudo umount /mnt

    mkdir -p os390/
    if [[ ! -d "os390/" ]]; then
        printf "\nUnable to create the destination directory."
        md_cleanup && exit
    fi

    printf "\nConverting DASD \"MVSWK1.122\":\n"
    dasdcopy -bz2 tmp/MVSWK1.122 os390/mvswk1.122
    if [[ ! -f "os390/mvswk1.122" ]]; then
        printf "\nAn error occurred while processing the DASD."
        md_abend && exit
    fi

    printf "\nConverting DASD \"PR39R2.260\":\n"
    dasdcopy -bz2 tmp/PR39R2_1.260 os390/pr39r2.260
    if [[ ! -f "os390/pr39r2.260" ]]; then
        printf "\nAn error occurred while processing the DASD."
        md_abend && exit
    fi

    printf "\nConverting DASD \"PR39D2.261\":\n"
    dasdcopy -bz2 tmp/PR39D2_1.261 os390/pr39d2.261
    if [[ ! -f "os390/pr39d2.261" ]]; then
        printf "\nAn error occurred while processing the DASD."
        md_abend && exit
    fi
fi

# md_done

printf "\nDistribution successfully built."
md_cleanup && exit