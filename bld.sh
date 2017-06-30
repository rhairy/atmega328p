GCC_VERSION="7.1.0"
BINUTILS_VERSION="2.28"

ENABLE_LANGUAGES="ada"

GCC_ARCHIVE="gcc-$GCC_VERSION.tar.gz"
BINUTILS_ARCHIVE="binutils-$BINUTILS_VERSION.tar.gz"

GCC_SRC_DIR="gcc-$GCC_VERSION"
BINUTILS_SRC_DIR="binutils-$BINUTILS_VERSION"

GCC_OBJ_DIR="gcc-$GCC_VERSION-obj"

SOURCE_DIR="$(pwd)/src"
PREFIX_DIR="$(pwd)/bld"

# Checks the return status of the last executed command.
# Input $1: This should be the name of the command whose exit status is being checked.
# Input $2: This should be a string value "eq", "ne", "lt", or "gt".
# Input $3: This should be an integer value that along with $2 will indicate whether the program has exited successfully.
check_return_status () {
  case "$2" in
    "eq" )
      if [ ! "$?" -eq "$3" ]
        then
        echo "ERROR - $1 returned $?"
	exit -1
      fi;;
    "ne" )
      if [ ! "$?" -ne "$3" ]
        then
        echo "ERROR - $1 returned $?"
	exit -1
      fi;;
    "lt" )
      if [ ! "$?" -lt "$3" ]
        then
        echo "ERROR - $1 returned $?"
	exit -1
      fi;;
    "gt" )
      if [ ! "$?" -gt "$3" ]
        then
        echo "ERROR - $1 returned $?"
	exit -1
      fi;;
  esac
}

# Prepare source directory.
if [ ! -d $SOURCE_DIR ]
  then
  mkdir $SOURCE_DIR
fi

cd $SOURCE_DIR
check_return_status "cd $BUILD_DIR" "eq" 0

# Download and extract sources.
if [ ! -e "$BINUTILS_ARCHIVE" ]
  then
  wget https://ftp.gnu.org/gnu/binutils/$BINUTILS_ARCHIVE
  tar -xf $BINUTILS_ARCHIVE
  check_return_status "tar -xf $BINUTILS_ARCHIVE" "eq" 0
fi

if [ ! -e "$GCC_ARCHIVE" ]
  then
  wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION/$GCC_ARCHIVE
  tar -xf $GCC_ARCHIVE
  check_return_status "tar -xf $GCC_ARCHIVE" "eq" 0
fi

# Build native binutils.
cd "$SOURCE_DIR/$BINUTILS_SRC_DIR"
./configure --prefix=$PREFIX_DIR
check_return_status "configure" "eq" 0
make
check_return_status "make" "eq" 0
make install
check_return_status "make install" "eq" 0

# Build Native GCC
mkdir "$SOURCE_DIR/$GCC_OBJ_DIR"
cd "$SOURCE_DIR/$GCC_OBJ_DIR"
../$GCC_SRC_DIR/configure --prefix=$PREFIX_DIR --disable-multilib --enable-languages=$ENABLE_LANGUAGES
check_return_status "configure" "eq" 0
make
check_return_status "make" "eq" 0
make install
check_return_status "make install" "eq" 0

# Change PATH to include newly built GCC and Binutils
TMP=$PATH
export PATH=$PREFIX_DIR/bin:$TMP
export CC=$PREFIX_DIR/bin/gcc

# Build Binutils and GCC targeted for AVR.
cd $SOURCE_DIR
rm -rf ./$BINUTILS_SRC_DIR
tar -xf $BINUTILS_ARCHIVE
cd $BINUTILS_SRC_DIR

./configure --prefix=$PREFIX_DIR --target=avr
check_return_status "configure" "eq" 0
make
check_return_status "make" "eq" 0
make install
check_return_status "make install" "eq" 0

cd $SOURCE_DIR/$GCC_OBJ_DIR
check_return_status "cd" "eq" 0
rm -rf ./*

../$GCC_SRC_DIR/configure --prefix=$PREFIX_DIR --disable-multilib --enable-languages=$ENABLE_LANGUAGES --target=avr --disable-libada
check_return_status "configure" "eq" 0
make
check_return_status "make" "eq" 0
make install
check_return_status "make install" "eq" 0
