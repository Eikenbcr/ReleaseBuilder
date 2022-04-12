#!/bin/sh -e

#############################################################
# buildRelease.sh
#   Author: Dave Elofson
#   Created: 2022-03-31
#############################################################

# Intended Use:
# 
# ./buildRelease <Release Number>
#
# Should clone Q_PIX_GEANT4, Q_PIX_RTD, and qpixar into parallel directories, and run any initial
# build or setup scripts. For future uses, you should only have to run setup scripts.

initdir=$(pwd)


source ./check_dependencies.sh

input="./packages.txt"

while read -r line; do
	echo $line;
	IFS=' ' read -r -a stringarray <<<  "$line";
	PACKAGE=${stringarray[0]};
	TAG=${stringarray[1]};
	URL=${stringarray[2]};
	if [[ "$PACKAGE" == "" ]]; then
		break
	fi
	

	if [ -d "$initdir/../$PACKAGE" ]
	then
		cd $initdir/../$PACKAGE; echo $PACKAGE already exists... Current version: $(git describe --tags); echo Updating to $TAG; git checkout tags/$TAG;
	else
		cd $initdir/..; git clone $URL; cd $PACKAGE; git checkout tags/$TAG;	
	fi

	case $PACKAGE in

		marley)
			echo Performing any Marley specific tasks...
			if [ -d "$initdir/../$PACKAGE" ]
		    then
        		cd $initdir/../$PACKAGE; echo $PACKAGE already exists... Current version: $(git describe --tags); echo Updating to $TAG; git checkout tags/$TAG;
    		else
        		cd $initdir/..; git clone -b develop $URL; cd $PACKAGE; git checkout tags/$TAG;
    		fi

			cd build/; make all	
			;;

		*)
			if [ -d "$initdir/../$PACKAGE" ]
		    then
        		cd $initdir/../$PACKAGE; echo $PACKAGE already exists... Current version: $(git describe --tags); echo Updating to $TAG; git checkout tags/$TAG;
    		else
        		cd $initdir/..; git clone $URL; cd $PACKAGE; git checkout tags/$TAG;
    		fi

			case $PACKAGE in
		
				qpixg4)
					echo Performing any G4 specific tasks...
					echo $(pwd -P)
					source $G4INSTALL/bin/geant4.sh
					source $ROOTSYS/bin/thisroot.sh
					source ./setup/setup_marley.sh;
					cd Build;
					cmake ../;
					make
					;;

				qpixrtd)
					echo Performing any RTD specific tasks...;
					source ./build.sh;
					echo Building the EXAMPLE...;
					echo $(pwd -P)
					cd $initdir/../qpixrtd/EXAMPLE/build; cmake ..; make; cd ..; 
					;;

				qpixar)
					echo Performing any AR specific tasks...
					;;

			esac
		;;
	esac


done < "$input"
