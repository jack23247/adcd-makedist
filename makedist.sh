#!/bin/bash
# makedist.sh
# Converts an OS/390 ADCD disk image set into an Hercules distribution

# XXX I'm 100% sure there is a regression in V1R2! The behavior of the
# functions has changed too much

# TODO add prefix directory, and a switch to keep it intact in 
# case of a failed run

# md_funct

md_getpid() {
    # https://stackoverflow.com/a/39420186
    pgid=$( ps -q $$ -o pgid= )
    sid=$( ps -q $$ -o sid= )
    if [[ $pgid == $sid ]]; then
        echo 0
    else
        echo $pgid
    fi
}

md_abend() {
    echo $1
    rm -rf os390
    rm -rf docs
    md_cleanup
    kill $( md_getpid )
}

md_cleanup() {
    rm -rf tmp
    echo "Attempting to unmount a residual image..."
    sudo umount /mnt >/dev/null 2>&1
}

md_usage() (
    printf "Converts an OS/390 ADCD disk image set into an Hercules distribution.\nUsage:\t./makedist -d DISTNAME -D IMGDIR [ OPTIONS ]\nWhere:\tDISTNAME = {v1r2 | v2r10}\n\tIMGDIR = Path of the directory contining the disk images\n\tOPTIONS = {-o[verwrite] | -h[elp]}\n"
)

# md_check_sudo

if [[ "$EUID" == 0 ]]; then
    echo "This script will automatically request superuser privileges when"
    echo "they are required."
    exit
fi

# md_check_deps

hash sudo 2>/dev/null || {
    echo "Please install \"sudo\" before running makedist."
    exit
}
hash md5sum 2>/dev/null || {
    echo "Please install \"md5sum\" before running makedist."
    exit
}
hash unzip 2>/dev/null || {
    echo "Please install \"unzip\" before running makedist."
    exit
}
hash dasdcopy 2>/dev/null || {
    echo "Cannot find \"dasdcopy\": please install Hercules."
    exit
}

# md_getopts

while getopts ":d:D:h:o" opt; do
    case $opt in
    d) distrib=("$OPTARG") ;;
    D) images_dir=("$OPTARG") ;;
    h) md_usage && exit ;;
    o) overwrite=1 ;;
    *) md_usage && exit ;;
    esac
done
shift $((OPTIND - 1))

# md_check_distrib_valid

if [ ! $distrib ]; then
    echo "No distribution specified."
    exit
elif [ $distrib == "v1r2" ]; then
    echo "Building v1r2 is currently disabled due to regressions."
    exit
elif [ $distrib == "v2r10" ]; then
    echo "Attempting to build distribution \"$distrib\"."
else
    echo "Unknown distribution \"$distrib\"."
    exit
fi

# md_check_dirs

if [ ! $images_dir ]; then
    echo "No source directory specified."
    exit
elif [ ! -d $images_dir ]; then
    echo "The specified source directory does not exist."
    exit
fi

# md_make_dirs

if [ -d "os390/" ]; then
    if [[ $overwrite != 1 ]]; then
        echo "The destination directory is not empty."
        exit
    else
        echo "Overwriting previous distribution..."
        rm -rf os390/
    fi
fi

mkdir -p tmp/
if [ ! -d "tmp/" ]; then
    printf "Unable to create the temporary directory."
    md_cleanup && exit
fi

mkdir -p os390/
if [ ! -d "os390/" ]; then
    printf "Unable to create the destination directory."
    md_cleanup && exit
fi

mkdir -p docs/
if [ ! -d "docs/" ]; then
    printf "Unable to create the destination directory."
    md_cleanup && exit
fi

# md_check_disk_images

for image_file in $images_dir/*.iso; do
    if [ ! -f $image_file ]; then
        echo "Error opening \"$image_file\": no such file or directory."
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
        image_file_md5=$(md5sum $image_file | cut -f1 -d" ")
        if [ $image_file_md5 == "c7bc86fb9aa849ba939eb22ce102fd67" ]; then
            printf "OS390RA001, "
            v2r10_cd1=$image_file
        elif [ $image_file_md5 == "e1147ad4d712f6c4b0c54ef83979fee9" ]; then
            printf "OS390RA002, "
            v2r10_cd2=$image_file
        elif [ $image_file_md5 == "dce04c2c4067518ea87da6148bbed671" ]; then
            printf "OS390RA003, "
            v2r10_cd3=$image_file
        elif [ $image_file_md5 == "ada34247fe241b32fbfbb2148ba0bd89" ]; then
            printf "OS390RA004, "
            v2r10_cd4=$image_file
        elif [ $image_file_md5 == "7078e98a87d63ca7412635c6d4590695" ]; then
            printf "OS390RA005,\n"
            v2r10_cd5=$image_file
        elif [ $image_file_md5 == "277c27f03259e019f084c061141938e5" ]; then
            printf "OS390RA006, "
            v2r10_cd6=$image_file
        elif [ $image_file_md5 == "0cf68db9bd172341705d63332fae58bf" ]; then
            printf "OS390RA007, "
            v2r10_cd7=$image_file
        elif [ $image_file_md5 == "9c4ca5e21ea0c06503d79704ead6d69b" ]; then
            printf "OS390RA008, "
            v2r10_cd8=$image_file
        elif [ $image_file_md5 == "0e9452acb9305ef732ecf75830eddffc" ]; then
            printf "OS390RA009, "
            v2r10_cd9=$image_file
        elif [ $image_file_md5 == "b78540d3a1fe1072f3c3c45f18c2949b" ]; then
            printf "OS390RA010,\n"
            v2r10_cd10=$image_file
        elif [ $image_file_md5 == "b3994aa15152bbbdab2fc7a49fdc4224" ]; then
            printf "OS390RA011, "
            v2r10_cd11=$image_file
        elif [ $image_file_md5 == "fec1c7ed18533650311e6bac7d7915d1" ]; then
            printf "OS390RA012, "
            v2r10_cd12=$image_file
        elif [ $image_file_md5 == "80d98edbed3c52ee60f7b24e7ad17f0e" ]; then
            printf "OS390RA013, "
            v2r10_cd13=$image_file
        else
            md_abend "Invalid image file for distribution \"$distrib\"."
        fi
    else
        md_abend "Unhandled exception."
    fi
done

echo "OK."

if [[ $distrib == "v1r2" && ($v1r2_cd1 == "" || $v1r2_cd2 == "") ]]; then
    md_abend "One or more required disk image files missing or unspecified."
fi

if [[ $distrib == "v2r10" && (
    $v2r10_cd1 == "" || $v2r10_cd2 == "" || $v2r10_cd3 == "" ||
    $v2r10_cd4 == "" || $v2r10_cd5 == "" || $v2r10_cd6 == "" ||
    $v2r10_cd7 == "" || $v2r10_cd8 == "" || $v2r10_cd9 == "" ||
    $v2r10_cd10 == "" || $v2r10_cd11 == "" || $v2r10_cd12 == "" ||
    $v2r10_cd13 == "") ]]; then
    md_abend "One or more required disk image files are missing."

fi

# md_make_v1r2

# if [ $distrib == "v1r2" ]; then
#     sudo mount -o loop -r $v1r2_cd1 /mnt
#     printf "Unpacking image \"OS/390 V1R2 ADCD CD1\":\n"
#     cp /mnt/readme.mvs readme-mvs.txt
#     chmod 664 readme-mvs.txt
#     unzip -joL /mnt/mvswk1.zip -d tmp
#     if [[ ! -f "tmp/MVSWK1.122" ]]; then
#         printf "\nAn error occurred while unpacking the image."
#         md_cleanup && exit
#     fi
#     unzip -joL /mnt/pr39r2.zip -d tmp
#     if [[ ! -f "tmp/PR39R2_1.260" ]] || [[ ! -f "tmp/PR39R2_2.260" ]]; then
#         printf "\nAn error occurred while unpacking the image."
#         md_cleanup && exit
#     fi
#     sudo umount /mnt

#     sudo mount -o loop -r $v1r2_cd2 /mnt
#     printf "\nUnpacking image \"OS/390 V1R2 ADCD CD2\":\n"
#     unzip -joL /mnt/pr39d2.zip -d tmp
#     if [[ ! -f "tmp/PR39D2_1.261" ]] || [[ ! -f "tmp/PR39D2_2.261" ]]; then
#         printf "\nAn error occurred while unpacking the image."
#         md_cleanup && exit
#     fi
#     sudo umount /mnt

#     mkdir -p os390/
#     if [[ ! -d "os390/" ]]; then
#         printf "\nUnable to create the destination directory."
#         md_cleanup && exit
#     fi

#     printf "\nConverting DASD \"MVSWK1.122\":\n"
#     dasdcopy -bz2 tmp/MVSWK1.122 os390/mvswk1.122
#     if [[ ! -f "os390/mvswk1.122" ]]; then
#         printf "\nAn error occurred while processing the DASD."
#         md_abend
#     fi

#     printf "\nConverting DASD \"PR39R2.260\":\n"
#     dasdcopy -bz2 tmp/PR39R2_1.260 os390/pr39r2.260
#     if [[ ! -f "os390/pr39r2.260" ]]; then
#         printf "\nAn error occurred while processing the DASD."
#         md_abend
#     fi

#     printf "\nConverting DASD \"PR39D2.261\":\n"
#     dasdcopy -bz2 tmp/PR39D2_1.261 os390/pr39d2.261
#     if [[ ! -f "os390/pr39d2.261" ]]; then
#         printf "\nAn error occurred while processing the DASD."
#         md_abend
#     fi
# fi

# Disk image and DASD Processing functions

md_chkmrkr() {
    ext=$1
    if [ ! -f "/mnt/os390ra.${ext}" ]; then
        md_abend "An error occurred while mounting the image."
    fi
    echo "Processing:"
    cat /mnt/os390ra.${ext}
}

md_unpack() {
    fullname=$1
    ext=$2
    unzip -joLL /mnt/os390/${fullname} -d tmp
    if [ ! -f "tmp/${fullname}.${ext}" ] &&
       [ ! -f "tmp/${fullname}_1.${ext}" ] &&
       [ ! -f "tmp/${fullname}_2.${ext}" ]; then
        md_abend "An error occurred while unpacking the image."
    fi
}

md_process() {
    fullname=$1
    ext=$2
    dasdcopy -bz2 tmp/${fullname}.${ext} os390/${fullname}.${ext}
    rm tmp/*.${ext}
    if [ ! -f "os390/${fullname}.${ext}" ]; then
        md_abend "An error occurred while processing the DASD."
    fi
}

md_unpack2() {
    basename=$1
    ext=$2
    unzip -joLL /mnt/os390/${basename} -d tmp
    if [ ! -f "tmp/${basename}_1.${ext}" ] ||
       [ ! -f "tmp/${basename}_2.${ext}" ]; then
        md_abend "An error occurred while unpacking the image."
    fi
}

md_process2() { # TODO can be rewritten as a call to md_process
    basename=$1
    ext=$2
    dasdcopy -bz2 tmp/${basename}_1.${ext} os390/${basename}_1.${ext}
    rm tmp/*.${ext}
    if [ ! -f "os390/${basename}_1.${ext}" ]; then
        md_abend "An error occurred while processing the DASD."
    fi
}

# md_make_v2r10

if [ $distrib == "v2r10" ]; then

    # CD1 ##################################################################

    sudo mount -o loop -r $v2r10_cd1 /mnt
    md_chkmrkr "001"
    # Miscellanea
    cp /mnt/os390ra.pac docs/
    cp /mnt/readme.mvs docs/
    cp /mnt/os390/devmap.nme docs/
    # OS39RA_{1,2}.A80
    md_unpack2 "os39ra" "a80"
    md_process2 "os39ra" "a80"
    sudo umount /mnt

    # CD2 ##################################################################

    sudo mount -o loop -r $v2r10_cd2 /mnt
    md_chkmrkr "002"
    # OS3RAA_{1,2}.A81
    md_unpack2 "os3raa" "a81"
    md_process2 "os3raa" "a81"
    sudo umount /mnt

    # CD3 ##################################################################

    sudo mount -o loop -r $v2r10_cd3 /mnt
    md_chkmrkr "003"
    # OS39M1_{1,2}.A82
    md_unpack2 "os39m1" "a82"
    md_process2 "os39m1" "a82"
    # OS39DA_2.A85 (DASDCOPY delayed to when we actually have _1)
    md_unpack "os39da_2" "a85"
    sudo umount /mnt

    # CD4 ##################################################################

    sudo mount -o loop -r $v2r10_cd4 /mnt
    md_chkmrkr "004"
    # OS39HA.A87
    md_unpack "os39ha" "a87"
    md_process "os39ha" "a87"
    sudo umount /mnt

    # CD5 ##################################################################

    sudo mount -o loop -r $v2r10_cd5 /mnt
    md_chkmrkr "005"
    # OS39DA_2.A85 (Finally!)
    md_unpack "os39da" "a85"
    md_process2 "os39da" "a85"
    sudo umount /mnt

    # CD6 ##################################################################

    sudo mount -o loop -r $v2r10_cd6 /mnt
    md_chkmrkr "006"
    # OS3DAA_{1,2}.A86
    md_unpack2 "os3daa" "a86"
    md_process2 "os3daa" "a86"
    sudo umount /mnt

    # CD7 ##################################################################

    sudo mount -o loop -r $v2r10_cd7 /mnt
    md_chkmrkr "007"
    # OS3DAB.A88
    md_unpack "os3dab" "a88"
    md_process "os3dab" "a88"
    sudo umount /mnt

    # CD8 ##################################################################

    sudo mount -o loop -r $v2r10_cd8 /mnt
    md_chkmrkr "008"
    # OS39PA.A83
    md_unpack "os39pa" "a83"
    md_process "os39pa" "a83"
    sudo umount /mnt

    # CD9 ##################################################################

    sudo mount -o loop -r $v2r10_cd9 /mnt
    md_chkmrkr "009"
    # OS3PAA.A88
    md_unpack "os3paa" "a84"
    md_process "os3paa" "a84"
    sudo umount /mnt

    # CD10 #################################################################

    sudo mount -o loop -r $v2r10_cd10 /mnt
    md_chkmrkr "010"
    # OS3PAB.A89
    md_unpack "os3pab" "a89"
    md_process "os3pab" "a89"
    sudo umount /mnt

    # CD11 #################################################################

    sudo mount -o loop -r $v2r10_cd11 /mnt
    md_chkmrkr "011"
    # OS3PAC_{1,2}.A8A
    md_unpack2 "os3pac" "a8a"
    md_process2 "os3pac" "a8a"
    sudo umount /mnt

    # CD12 #################################################################

    sudo mount -o loop -r $v2r10_cd12 /mnt
    md_chkmrkr "012"
    # OS3PAD_{1,2}.A8B
    md_unpack2 "os3pad" "a8b"
    md_process2 "os3pad" "a8b"
    sudo umount /mnt

    # CD13 #################################################################

    # CD13 is the documentation CD so the process is different
    sudo mount -o loop -r $v2r10_cd13 /mnt
    echo "Processing the documentation CD-ROM."
    if [ ! -f "/mnt/faq/index.html" ]; then
        md_abend "An error occurred while mounting the image."
    fi
    sudo cp -r /mnt docs/
    sudo umount /mnt

fi

# md_done

echo "Distribution successfully built."
md_cleanup && exit
