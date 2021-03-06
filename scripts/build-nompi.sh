#!/bin/bash -le



# BASH verbose mode
set -x 
currdir=$PWD
reponame=hicma-dev
# Check if we are already in hicma repo dir or not.
if git -C $PWD remote -v | grep -q "https://github.com/ecrc/$reponame"
then
	# we are, lets go to the top dir (where .git is)
	until test -d $PWD/.git ;
	do
		cd ..
	done;
else
	#we are not, we need to clone the repo
	git clone https://github.com/ecrc/$reponame.git
	cd $reponame
fi
module purge
if [ "$HOSTNAME" == "thana" ]; then
	. ./scripts/power8.modules
else
    echo "Loading intel modules"
	. ./scripts/modules-ecrc.sh

fi
module list
git config --global credential.helper 'cache --timeout=36000'


# Update submodules
HICMADEVDIR=$PWD 
git submodule update --init --recursive

# STARS-H
cd stars-h
rm -rf build
mkdir -p build/installdir
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PWD/installdir -DMPI=OFF -DOPENMP=OFF -DSTARPU=OFF -DGSL=OFF
make clean
make -j
make install
export PKG_CONFIG_PATH=$PWD/installdir/lib/pkgconfig:$PKG_CONFIG_PATH

# STARS-H-CORE
#cd $HICMADEVDIR
#cd stars-h-core
#rm -rf build
#mkdir -p build/installdir
#cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=$PWD/installdir 
#make -j install
#export PKG_CONFIG_PATH=$PWD/installdir/lib/pkgconfig:$PKG_CONFIG_PATH

# CHAMELEON
cd $HICMADEVDIR
cd chameleon
rm -rf build
mkdir -p build/installdir
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCHAMELEON_USE_MPI=OFF  -DCMAKE_INSTALL_PREFIX=$PWD/installdir
make clean
make -j
make install
export PKG_CONFIG_PATH=$PWD/installdir/lib/pkgconfig:$PKG_CONFIG_PATH

# HICMA
cd $HICMADEVDIR
rm -rf build
mkdir -p build/installdir
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PWD/installdir -DHICMA_USE_MPI=OFF
make clean
make -j
make install
export PKG_CONFIG_PATH=$PWD/installdir/lib/pkgconfig:$PKG_CONFIG_PATH

cd $currdir
set +x
