# MOAB_DIR points to top-level install dir, below which MOAB's lib/ and include/ are located
MOAB_BUILD_DIR := @abs_builddir@
MOAB_DIR := @CMAKE_INSTALL_PREFIX@

MOAB_DEV = no
ifneq ($(wildcard ${MOAB_DIR}/lib/moab.make),)
include ${MOAB_DIR}/lib/moab.make
include ${MOAB_DIR}/lib/iMesh-Defs.inc
else
include ${MOAB_BUILD_DIR}/moab.make
include ${MOAB_BUILD_DIR}/itaps/imesh/iMesh-Defs.inc
MOAB_DEV = yes
endif

default:

.SUFFIXES: .o .cpp .F90

VERBOSE=@
ifeq ($(V),1)
	VERBOSE=
endif

# MESH_DIR is the directory containing mesh files that come with MOAB source
MESH_DIR="@abs_srcdir@/MeshFiles/unittest"

RUNSERIAL =
ifeq ("$(MOAB_MPI_ENABLED)","yes")
RUNPARALLEL = @MPIEXEC@ @MPIEXEC_NP@ @NP@
else
RUNPARALLEL =
endif

.cpp.o:
	@echo "  [CXX]  $<"
	${VERBOSE}${MOAB_CXX} ${CXXFLAGS} ${MOAB_CXXFLAGS} ${MOAB_CPPFLAGS} ${MOAB_INCLUDES} -DMESH_DIR=\"${MESH_DIR}\" -c $<

.F90.o:
	@echo "   [FC]  $<"
	${VERBOSE}${IMESH_FC} ${FCFLAGS} ${IMESH_FCFLAGS} ${MOAB_CPPFLAGS} ${IMESH_INCLUDES} ${IMESH_FCDEFS} $(FC_DEFINE)MESH_DIR=\"${MESH_DIR}\" -c $<

info:
ifeq ("$(MOAB_DEV)","no")
	@echo "Using installation MOAB_DIR = ${MOAB_DIR}"
else
	@echo "Using installation MOAB_DIR = ${MOAB_BUILD_DIR}"
endif
	@echo "Using development version of MOAB = ${MOAB_DEV}"

clobber:
	@rm -rf *.o *.mod *.vtk

