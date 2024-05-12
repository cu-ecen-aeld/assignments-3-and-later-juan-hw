#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    
    #git apply ../fix_patch.patch

    # TODO: Add your kernel build steps here
    echo "Running make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    
    echo "Running make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    
    echo "Running make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all"
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    
    echo "Running make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    
    echo "Running make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
    
    cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "Creating rootfs directory at ${OUTDIR}/rootfs"
mkdir ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
	make distclean
	make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
make distclean
make defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} 
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a ../rootfs/bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a ../rootfs/bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "Add program interpreter"

#cp $HOME/Documents/aarch_arm/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1 \
#	$HOME/Documents/Linux_Programming_Embedded_Course/Linux_System_Programming_Buildroot/assignment-3-juan-hw/finder-app/rootfs/lib

#cp $HOME/Documents/aarch_arm/aarch64-none-linux-gnu/libc/lib64/libm.so.6 \
#	$HOME/Documents/Linux_Programming_Embedded_Course/Linux_System_Programming_Buildroot/assignment-3-juan-hw/finder-app/rootfs/lib64
	
#cp $HOME/Documents/aarch_arm/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 \
#	$HOME/Documents/Linux_Programming_Embedded_Course/Linux_System_Programming_Buildroot/assignment-3-juan-hw/finder-app/rootfs/lib64
	
#cp $HOME/Documents/aarch_arm/aarch64-none-linux-gnu/libc/lib64/libc.so.6 \
#	$HOME/Documents/Linux_Programming_Embedded_Course/Linux_System_Programming_Buildroot/assignment-3-juan-hw/finder-app/rootfs/lib64

# TODO: Make device nodes
cd $OUTDIR/rootfs
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 666 dev/ttyS0 c 5 1

cd "$OUTDIR"

# TODO: Clean and build the writer utility
echo "Cleaning previous writer compilations" 
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean

echo "Recompiling writer application for arch=$ARCH"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} default

echo "Copying writer application into file system"
cp writer $OUTDIR/rootfs/home

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs

cp finder.sh  finder-test.sh $OUTDIR/rootfs/home
mkdir $OUTDIR/rootfs/home/conf
cp conf/username.txt conf/assignment.txt $OUTDIR/rootfs/home/conf

cd $OUTDIR/rootfs/home

echo "Modifying reference to assignment.txt"

# Define the file to modify
file="finder-test.sh"

# Define the line to replace
old_line="assignment=\`cat ../conf/assignment.txt\`"
new_line="assignment=\`cat conf/assignment.txt\`"

# Use sed to replace the old line with the new line in the file
sed -i "s|$old_line|$new_line|g" "$file"

echo "Replacement complete."

cd "$OUTDIR"

echo "Copying Copy the autorun-qemu.sh script into the rootfs"
cp autorun-qemu.sh $OUTDIR/rootfs/home/

cd "$OUTDIR/rootfs"

# TODO: Chown the root directory
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio

# TODO: Create initramfs.cpio.gz
cd "$OUTDIR"
gzip -f initramfs.cpio

echo "Building Linux Kernel and RootFS completed succesfully."
