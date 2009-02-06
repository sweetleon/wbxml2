# - Try to find BlueZ
# Find BlueZ headers, libraries and the answer to all questions.
#
#  BLUEZ_FOUND               True if BlueZ libraries got found
#  BLUEZ_INCLUDE_DIRS         Location of BlueZ headers 
#  BLUEZ_LIBRARIES           List of libaries to use BlueZ
#
# Copyright (c) 2007 Daniel Gollub <dgollub@suse.de>
# Copyright (c) 2007 Bjoern Ricks  <b.ricks@fh-osnabrueck.de>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

INCLUDE( FindPkgConfig )

# Take care about bluez.pc settings
IF ( LibWbxml2_FIND_REQUIRED )
	SET( _pkgconfig_REQUIRED "REQUIRED" )
ELSE( LibWbxml2_FIND_REQUIRED )
	SET( _pkgconfig_REQUIRED "" )	
ENDIF ( LibWbxml2_FIND_REQUIRED )

IF ( BLUEZ_MIN_VERSION )
	PKG_SEARCH_MODULE( BLUEZ ${_pkgconfig_REQUIRED} bluez>=${BLUEZ_MIN_VERSION} )
ELSE ( BLUEZ_MIN_VERSION )
	PKG_SEARCH_MODULE( BLUEZ ${_pkgconfig_REQUIRED} bluez )
ENDIF ( BLUEZ_MIN_VERSION )

# Look for BlueZ include dir and libraries
IF( NOT BLUEZ_FOUND AND NOT PKG_CONFIG_FOUND )

	FIND_PATH( BLUEZ_INCLUDE_DIRS bluetooth/bluetooth.h )
	FIND_LIBRARY( BLUEZ_LIBRARIES bluetooth )

	# Report results
	IF ( BLUEZ_LIBRARIES AND BLUEZ_INCLUDE_DIRS )	
		SET( BLUEZ_FOUND 1 )
		IF ( NOT BlueZ_FIND_QUIETLY )
			MESSAGE( STATUS "Found BlueZ: ${BLUEZ_LIBRARIES}" )
		ENDIF ( NOT BlueZ_FIND_QUIETLY )
	ELSE ( BLUEZ_LIBRARIES AND BLUEZ_INCLUDE_DIRS )	
		IF ( BlueZ_FIND_REQUIRED )
			MESSAGE( SEND_ERROR "Could NOT find BLUEZ" )
		ELSE ( BlueZ_FIND_REQUIRED )
			IF ( NOT BlueZ_FIND_QUIETLY )
				MESSAGE( STATUS "Could NOT find BLUEZ" )	
			ENDIF ( NOT BlueZ_FIND_QUIETLY )
		ENDIF ( BlueZ_FIND_REQUIRED )
	ENDIF ( BLUEZ_LIBRARIES AND BLUEZ_INCLUDE_DIRS )

ENDIF( NOT BLUEZ_FOUND AND NOT PKG_CONFIG_FOUND  )

# Hide advanced variables from CMake GUIs
MARK_AS_ADVANCED( BLUEZ_LIBRARIES BLUEZ_INCLUDE_DIRS )

