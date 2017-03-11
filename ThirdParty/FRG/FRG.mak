FRG_ROOT_DIR = ThirdParty/FRG
FRG_SRC_DIR = ${FRG_ROOT_DIR}/src
FRG_INCLUDE_DIR = ${FRG_ROOT_DIR}/include
FRG_HEADER_DIR = ${FRG_INCLUDE_DIR}/mtf/${FRG_ROOT_DIR}
FRG_LIB_NAME = $(addsuffix ${LIB_POST_FIX}, frg)
FRG_LIB_SO =  $(addprefix lib, $(addsuffix .so, ${FRG_LIB_NAME}))

THIRD_PARTY_TRACKERS += FRG
_THIRD_PARTY_TRACKERS_SO += ${FRG_LIB_NAME}  
THIRD_PARTY_TRACKERS_SO_LOCAL += ${FRG_ROOT_DIR}/${FRG_LIB_SO}
THIRD_PARTY_LIBS_DIRS += -L${FRG_ROOT_DIR}

FRG_HEADERS = $(addprefix  ${FRG_HEADER_DIR}/, FRG.h)

FRG_LIB_MODULES = Fragments_Tracker emd
FRG_LIB_INCLUDES = vot
FRG_LIB_HEADERS = $(addprefix ${FRG_HEADER_DIR}/,$(addsuffix .hpp, ${FRG_LIB_MODULES} ${FRG_LIB_INCLUDES}))
FRG_LIB_SRC = $(addprefix ${FRG_SRC_DIR}/,$(addsuffix .cpp, ${FRG_LIB_MODULES}))

THIRD_PARTY_HEADERS += ${FRG_HEADERS} ${FRG_LIB_HEADERS} 
THIRD_PARTY_INCLUDE_DIRS += ${FRG_INCLUDE_DIR}

${BUILD_DIR}/FRG.o: ${FRG_SRC_DIR}/FRG.cc ${FRG_HEADERS} ${UTILITIES_HEADER_DIR}/miscUtils.h ${MACROS_HEADER_DIR}/common.h ${ROOT_HEADER_DIR}/TrackerBase.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${MTF_COMPILETIME_FLAGS} $< ${OPENCV_FLAGS} -I${FRG_INCLUDE_DIR} -I${UTILITIES_INCLUDE_DIR} -I${MACROS_INCLUDE_DIR} -I${ROOT_INCLUDE_DIR} -o $@
	
${MTF_LIB_INSTALL_DIR}/${FRG_LIB_SO}: ${FRG_ROOT_DIR}/${FRG_LIB_SO}
	${MTF_LIB_INSTALL_CMD_PREFIX} cp -f $< $@
${FRG_ROOT_DIR}/${FRG_LIB_SO}: ${FRG_LIB_SRC} ${FRG_LIB_HEADERS}
	cd ${FRG_ROOT_DIR}; rm -rf Build; mkdir Build; cd Build; cmake -D FRG_LIB_NAME=${FRG_LIB_NAME} ..
	$(MAKE) -C ${FRG_ROOT_DIR}/Build --no-print-directory
	mv ${FRG_ROOT_DIR}/Build/${FRG_LIB_SO} ${FRG_ROOT_DIR}/