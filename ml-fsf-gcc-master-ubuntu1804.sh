#!/bin/bash

if [ ! -e riscv-gnu-toolchain ]; then
	git clone https://github.com/riscv/riscv-gnu-toolchain 
fi

cd riscv-gnu-toolchain
git submodule update --init

cd riscv-gcc
git remote | grep -q fsf || git remote add fsf git://gcc.gnu.org/git/gcc.git
git fetch fsf

git clean -fdx
git reset --hard
git checkout master fsf/master
git branch -D "patch-${patch_id}" || true
git checkout -b "patch-${patch_id}" fsf/master

pwclient apply -p gcc "${patch_id}"
# pwclient git-am -p gcc "${patch_id}"

cd ..

# RV64 Tests
rm -rf "$PWD/opt-riscv64"
./configure --prefix="$PWD/opt-riscv64/" \
	--with-arch=rv64gcb \
	--with-abi=lp64d \
	--with-mulitilib-generator="rv64gcb-lp64d--"
make clean
make report-binutils-newlib -j $(nproc)
make report-gcc-newlib -j $(nproc)

# test rv32:
rm -rf "$PWD/opt-riscv32"
./configure --prefix="$PWD/opt-riscv32/" \
	--with-arch=rv32gcb \
	--with-abi=ilp32d \
	--with-mulitilib-generator="rv32gcb-ilp32d--"
make clean
make report-binutils-newlib -j $(nproc)
make report-gcc-newlib -j $(nproc)
