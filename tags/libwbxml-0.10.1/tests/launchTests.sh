#!/bin/sh

# setup correct path for binaries if they are not in $PATH
if [ "${CMAKE_CURRENT_BINARY_DIR}" ]
then
	WBXML2XML="${CMAKE_CURRENT_BINARY_DIR}/tools/wbxml2xml"
	XML2WBXML="${CMAKE_CURRENT_BINARY_DIR}/tools/xml2wbxml"
else
	WBXML2XML=`which wbxml2xml`
	XML2WBXML=`which xml2wbxml`
fi

if [ ! -x "$WBXML2XML" ]
then
    echo Set WBXML2XML to the binary executable of wbxml2xml tool in order to use that script.
    exit 1
fi

if [ ! -x "$XML2WBXML" ]
then
    echo Set XML2XWBML to the binary executable of xml2wbxml tool in order to use that script.
    exit 1
fi

# if somebody enabled CMAKE_SKIP_RPATH
# then it is necessary to specify the path to the library
# Debian does this by default
if [ "${CMAKE_SKIP_RPATH}" ]
then
	LD_LIBRARY_PATH="${CMAKE_CURRENT_BINARY_DIR}/src"
	export LD_LIBRARY_PATH
fi

# Go to test suite directory
if [ " $1" != " " -a -d "$1" ]
then
	TEST_SUITE_DIR="$1"
else
	TEST_SUITE_DIR=`dirname $0`
fi

cd "$TEST_SUITE_DIR"

echo Test suite directory is `pwd`

# Create temporary directory
TMP_DIR=`mktemp -d -t LibWBXMLTestSuite.XXX`

# execute only a special test directory
if [ " $2" != " " ]
then
	DIRLIST=$(find `pwd` -maxdepth 1 -type d -name $2 -print | sort)
	if [ ! "$DIRLIST" ]
	then
		DIRLIST=$(find `pwd` -maxdepth 1 -type d ! -name "*svn*" -print | sort)
		COUNTER=0
		for ITEM in $DIRLIST
		do
			if [ "$COUNTER" -eq "$2" ]
			then
				RESULT=$ITEM
			fi
			COUNTER=$(($COUNTER + 1))
		done
		DIRLIST=$RESULT
	fi
else
	DIRLIST=$(find `pwd` -maxdepth 1 -type d ! -name "*svn*" -print | sort)
fi

# For each directory
RESULT="SUCCEEDED"
for i in $DIRLIST
do
  if [ $i != `pwd` ]; then

  echo ----------------------------
  echo Entering into: `basename $i`
  echo ----------------------------

  # execute only a special test in a directory
  TESTLIST=$(find $i -maxdepth 1 -type f -name "*.xml" -print | sort )
  if [ " $3" != " " ]
  then
	COUNTER=0
	for ITEM in $TESTLIST
	do
		COUNTER=$(($COUNTER + 1))
		if [ "$COUNTER" -eq "$3" ]
		then
			RESULT=$ITEM
		fi
	done
	TESTLIST=$RESULT
  fi

  # For each directory
  for j in $TESTLIST
  do
    echo . `basename $j`

    OUT_WBXML="$TMP_DIR/`basename $i`/`basename $j .xml`.wbxml"
    OUT_XML="$TMP_DIR/`basename $i`/`basename $j`"
    
     # Create output directory if they don't exist
    if [ ! -d "$TMP_DIR/`basename $i`" ]; then
        mkdir -p "$TMP_DIR/`basename $i`"
    fi

    echo Converting into: $OUT_WBXML
    CMD="$XML2WBXML -o $OUT_WBXML $j"
    $CMD
    if [ $? != 0 ]; then RESULT="FAILED"; fi

    echo Converting back: $OUT_XML
    TESTDIR=`basename $i`
    if [ "$TESTDIR" = "ota" ];
    then
        PARAMS="-l OTA"
    else if [ "$TESTDIR" = "airsync" ];
    then
        PARAMS="-l AIRSYNC"
    else
        PARAMS=""
    fi fi
    CMD="$WBXML2XML $PARAMS -o $OUT_XML $OUT_WBXML"
    $CMD
    if [ $? != 0 ]; then RESULT="FAILED"; fi
  done

 fi
done

# Cleanup
rm -rf "$TMP_DIR"

echo ---------------------------
echo \\o/ Finished ! Yeah ! \\o/
echo ---------------------------

echo $RESULT
if [ "$RESULT" != "SUCCEEDED" ];
then
    exit 1;
else
    exit 0;
fi
