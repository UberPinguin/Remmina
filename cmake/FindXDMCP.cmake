# Remmina - The GTK+ Remote Desktop Client
#
# Copyright (C) 2011 Marc-Andre Moreau
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, 
# Boston, MA 02111-1307, USA.

find_package(PkgConfig)
pkg_check_modules(PC_XDMCP REQUIRED xdmcp)

find_path(XDMCP_INCLUDE_DIR X11/Xdmcp.h
	HINTS ${PC_XDMCP_INCLUDEDIR} ${PC_XDMCP_INCLUDE_DIRS})

find_library(XDMCP_LIBRARY NAMES libXdmcp
	HINTS ${PC_XDMCP_LIBDIR} ${PC_XDMCP_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(XDMCP DEFAULT_MSG XDMCP_LIBRARY XDMCP_INCLUDE_DIR)

set(XDMCP_LIBRARIES ${XDMCP_LIBRARY})
set(XDMCP_INCLUDE_DIRS ${XDMCP_INCLUDE_DIR})

mark_as_advanced(XDMCP_INCLUDE_DIR XDMCP_LIBRARY)

