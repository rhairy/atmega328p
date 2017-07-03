GCC_VERSION="7.1.0"
BINUTILS_VERSION="2.28"
AVRC_VERSION="2.0.0"

AVRC_ARCHIVE="avr-libc-$AVRC_VERSION.tar.bz2"
GCC_ARCHIVE="gcc-$GCC_VERSION.tar.gz"
BINUTILS_ARCHIVE="binutils-$BINUTILS_VERSION.tar.gz"

AVRC_SRC_DIR="avr-libc-$AVRC_VERSION"
GCC_SRC_DIR="gcc-$GCC_VERSION"
BINUTILS_SRC_DIR="binutils-$BINUTILS_VERSION"

GCC_OBJ_DIR="gcc-$GCC_VERSION-obj"

ROOT_DIR="$(pwd)"
SOURCE_DIR="$ROOT_DIR/src"
PREFIX_DIR="$ROOT_DIR/bld"
LOG_DIR="$ROOT_DIR/log"
BIN_DIR="$PREFIX_DIR/bin"

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
PHASE=1
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

# Change PATH to include newly built GCC and Binutils
export PATH="$PATH:$BIN_DIR"

# PHASE2: Build Binutils targeted to AVR.
PHASE=2
cd $SOURCE_DIR
rm -rf ./$BINUTILS_SRC_DIR
tar -xf $BINUTILS_ARCHIVE
cd $BINUTILS_SRC_DIR

if [ ! -e "$LOG_DIR/phase$PHASE.success" ]
  then
  ./configure --prefix=$PREFIX_DIR --target=avr 2>&1 | tee "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  make 2>&1 | tee -a "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  make install 2>&1 | tee -a "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0

  if [ $ERROR_STATE -ne 0 ]
    then
    make clean
    echo "Phase$PHASE Failed."
    exit -1
  fi
  touch "$LOG_DIR/phase$PHASE.success"
fi

# PHASE5: Build GCC targeted to AVR.
PHASE=3
if [ ! -e "$LOG_DIR/phase$PHASE.success" ]
  then
  cd $SOURCE_DIR/$GCC_OBJ_DIR
  check_return_status "cd" "eq" 0
  rm -rf ./*

  ../$GCC_SRC_DIR/configure --prefix=$PREFIX_DIR --disable-multilib --enable-languages=c,c++,ada --target=avr --disable-libada 2>&1 | tee "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  make 2>&1 | tee -a "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  make install 2>&1 | tee -a "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  if [ $ERROR_STATE -ne 0 ]
    then
    make clean
    echo "Phase$PHASE Failed."
    exit -1
  fi
  touch $LOG_DIR/phase$PHASE.success
fi

# PHASE6: Build avrlibc.
PHASE=4
export CC="$PREFIX_DIR/bin/avr-gcc"
if [ ! -e $LOG_DIR/phase$PHASE.success ]
  then
  cd $SOURCE_DIR/$AVRC_SRC_DIR
  ./configure --prefix=$PREFIX_DIR --host=avr --build=`./config.guess` 2>&1 | tee "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  make 2>&1 | tee -a "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  make install 2>&1 | tee -a "$LOG_DIR/phase$PHASE.log"
  check_return_status "eq" 0
  if [ $ERROR_STATE -ne 0 ]
    then
    make clean
    echo "Phase$PHASE Failed."
    exit -1
  fi
  touch $LOG_DIR/phase$PHASE.success
fi
