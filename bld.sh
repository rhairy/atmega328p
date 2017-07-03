GCC_VERSION="7.1.0"
BINUTILS_VERSION="2.28"
AVRC_VERSION="2.0.0"

<<<<<<< HEAD
AVRC_ARCHIVE="avr-libc-$AVRC_VERSION.tar.bz2"
=======
>>>>>>> bad215e1c8c5dc29f4676312c346fabced043f0b
GCC_ARCHIVE="gcc-$GCC_VERSION.tar.gz"
BINUTILS_ARCHIVE="binutils-$BINUTILS_VERSION.tar.gz"

AVRC_SRC_DIR="avr-libc-$AVRC_VERSION"
GCC_SRC_DIR="gcc-$GCC_VERSION"
BINUTILS_SRC_DIR="binutils-$BINUTILS_VERSION"

GCC_OBJ_DIR="gcc-$GCC_VERSION-obj"

<<<<<<< HEAD
ROOT_DIR="$(pwd)"
SOURCE_DIR="$ROOT_DIR/src"
PREFIX_DIR="$ROOT_DIR/bld"
LOG_DIR="$ROOT_DIR/log"
=======
>>>>>>> bad215e1c8c5dc29f4676312c346fabced043f0b

ERROR_STATE=0

# Checks the return status of the last executed command and sets the ERROR_STAE as appropriate.
# Input $1: This should be a string value "eq", "ne", "lt", or "gt".
# Input $2: This should be an integer value that along with $2 will indicate whether the program has exited successfully.
check_return_status () {
  case "$1" in
    "eq" )
      if [ ! "$?" -eq "$2" ]
        then
	ERROR_STATE=1
      fi;;
    "ne" )
      if [ ! "$?" -ne "$2" ]
        then
	ERROR_STATE=1
      fi;;
    "lt" )
      if [ ! "$?" -lt "$2" ]
        then
	ERROR_STATE=1
      fi;;
    "gt" )
      if [ ! "$?" -gt "$2" ]
        then
	ERROR_STATE=1
      fi;;
  esac
}

# Prepare directories.
if [ ! -d $SOURCE_DIR ]
  then
  mkdir $SOURCE_DIR
fi

cd $SOURCE_DIR

if [ ! -d "$GCC_OBJ_DIR" ]
  then
  mkdir "$GCC_OBJ_DIR"
fi

if [ ! -d $LOG_DIR ]
  then
  mkdir $LOG_DIR
fi

# PHASE1: Download and extract sources.
if [ ! -e "$BINUTILS_ARCHIVE" ]
  then
  wget https://ftp.gnu.org/gnu/binutils/$BINUTILS_ARCHIVE
  check_return_status "eq" 0
fi
tar -xf $BINUTILS_ARCHIVE
check_return_status "eq" 0

if [ ! -e "$GCC_ARCHIVE" ]
  then
  wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$GCC_VERSION/$GCC_ARCHIVE
  check_return_status "eq" 0
fi
tar -xf $GCC_ARCHIVE
check_return_status "eq" 0

if [ ! -e "$AVRC_ARCHIVE" ]
  then
  wget http://download.savannah.gnu.org/releases/avr-libc/$AVRC_ARCHIVE
  check_return_status "eq" 0
fi
tar -xf $AVRC_ARCHIVE
check_return_status "eq" 0

if [ $ERROR_STATE -ne 0 ]
  then
    echo "Phase1 Failed."
    exit -1
fi

<<<<<<< HEAD
# PHASE2: Build native binutils.
if [ ! -e $LOG_DIR/phase2.success ]
  then
  cd "$SOURCE_DIR/$BINUTILS_SRC_DIR"
  ./configure --prefix=$PREFIX_DIR 2>&1 | tee $LOG_DIR/phase2.log
  make 2>&1 | tee -a $LOG_DIR/phase2.log
  check_return_status "eq" 0
  make install 2>&1 | tee -a $LOG_DIR/phase2.log
  check_return_status "eq" 0

  if [ $ERROR_STATE -ne 0 ]
    then
    echo "Phase2 Failed."
    exit -1
  fi
  touch $LOG_DIR/phase2.success
fi


# PHASE3:  Build Native GCC
if [ ! -e $LOG_DIR/phase3.success ]
  then
  cd "$SOURCE_DIR/$GCC_OBJ_DIR"
  ../$GCC_SRC_DIR/configure --prefix=$PREFIX_DIR --disable-multilib --enable-languages=c,c++,ada  2>&1 | tee $LOG_DIR/phase3.log
  check_return_status "eq" 0
  make 2>&1 | tee $LOG_DIR/phase3.log
  check_return_status "eq" 0
  make install 2>&1 | tee $LOG_DIR/phase3.log
  check_return_status "eq" 0

  if [ $ERROR_STATE -ne 0 ]
    then
    echo "Phase3 Failed."
    exit -1
  fi
  touch $LOG_DIR/phase3.success
fi
=======
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
>>>>>>> bad215e1c8c5dc29f4676312c346fabced043f0b

# Change PATH to include newly built GCC and Binutils
TMP=$PATH
export PATH=$PREFIX_DIR/bin:$TMP
<<<<<<< HEAD
=======
>>>>>>> bad215e1c8c5dc29f4676312c346fabced043f0b

# PHASE4: Build Binutils targeted to AVR.
cd $SOURCE_DIR
rm -rf ./$BINUTILS_SRC_DIR
tar -xf $BINUTILS_ARCHIVE
cd $BINUTILS_SRC_DIR

<<<<<<< HEAD
if [ ! -e $LOG_DIR/phase4.success ]
  then
  ./configure --prefix=$PREFIX_DIR --target=avr 2>&1 | tee $LOG_DIR/phase4.log
  check_return_status "eq" 0
  make 2>&1 | tee -a $LOG_DIR/phase4.log
  check_return_status "eq" 0
  make install 2>&1 | tee -a $LOG_DIR/phase4.log
  check_return_status "eq" 0

  if [ $ERROR_STATE -ne 0 ]
    then
    echo "Phase4 Failed."
    exit -1
  fi
  touch $LOG_DIR/phase4.success
fi

# PHASE5: Build GCC targeted to AVR.
if [ ! -e $LOG_DIR/phase5.success ]
  then
  cd $SOURCE_DIR/$GCC_OBJ_DIR
  check_return_status "cd" "eq" 0
  rm -rf ./*

  ../$GCC_SRC_DIR/configure --prefix=$PREFIX_DIR --disable-multilib --enable-languages=c,c++,ada --target=avr --disable-libada 2>&1 | tee $LOG_DIR/phase5.log
  check_return_status "eq" 0
  make 2>&1 | tee -a $LOG_DIR/phase5.log
  check_return_status "eq" 0
  make install 2>&1 | tee -a $LOG_DIR/phase5.log
  check_return_status "eq" 0
  if [ $ERROR_STATE -ne 0 ]
    then
    echo "Phase5 Failed."
    exit -1
  fi
  touch $LOG_DIR/phase5.success
fi

# PHASE6: Build avrlibc.
export CC="$PREFIX_DIR/bin/avr-gcc"
if [ ! -e $LOG_DIR/phase6.success ]
  then
  cd $SOURCE_DIR/$AVRC_SRC_DIR
  ./configure --prefix=$PREFIX_DIR --host=avr --build=`./config.guess` 2>&1 | tee $LOG_DIR/phase6.log
  check_return_status "eq" 0
  make 2>&1 | tee -a $LOG_DIR/phase6.log
  check_return_status "eq" 0
  make install 2>&1 | tee -a $LOG_DIR/phase6.log
  check_return_status "eq" 0
  if [ $ERROR_STATE -ne 0 ]
    then
    echo "Phase6 Failed."
    exit -1
  fi
  touch $LOG_DIR/phase6.success
fi
=======
>>>>>>> bad215e1c8c5dc29f4676312c346fabced043f0b
