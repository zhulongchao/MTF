# -------------------------------------------------------------------------------------- #
# --------------------------------- State Space Models --------------------------------- #
# -------------------------------------------------------------------------------------- #
sl3_max_val ?= -1
SL3_FLAGS = 
ifneq (${sl3_max_val}, -1)
SL3_FLAGS += -DSL3_MAX_VALID_VAL=${sl3_max_val}
endif
SSM_INCLUDE_DIR = SSM/include
SSM_SRC_DIR = SSM/src
SSM_HEADER_DIR = ${SSM_INCLUDE_DIR}/mtf/SSM
SSM_BASE_HEADERS =  ${SSM_HEADER_DIR}/StateSpaceModel.h ${UTILITIES_HEADER_DIR}/excpUtils.h 
SSM_BASE_HEADERS += ${SSM_HEADER_DIR}/SSMEstimatorParams.h

MTF_INCLUDE_DIRS += ${SSM_INCLUDE_DIR}

STATE_SPACE_MODELS = Spline LieHomography CBH Homography SL3 Affine Similitude Isometry AST IST Translation
SSM_MODULES = ProjectiveBase SSMEstimator SSMEstimatorParams 
STATE_SPACE_OBJS = $(addprefix ${BUILD_DIR}/,$(addsuffix .o, ${SSM_MODULES} ${STATE_SPACE_MODELS}))	
STATE_SPACE_HEADERS = $(addprefix ${SSM_HEADER_DIR}/, $(addsuffix .h, ${SSM_MODULES} ${STATE_SPACE_MODELS}))
STATE_SPACE_HEADERS += ${SSM_BASE_HEADERS}

MTF_HEADERS += ${STATE_SPACE_HEADERS}
MTF_OBJS += ${STATE_SPACE_OBJS}

${BUILD_DIR}/Spline.o: ${SSM_SRC_DIR}/Spline.cc ${SSM_HEADER_DIR}/Spline.h ${SSM_HEADER_DIR}/StateSpaceModel.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@
	
${BUILD_DIR}/ProjectiveBase.o: ${SSM_SRC_DIR}/ProjectiveBase.cc ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_HEADER_DIR}/StateSpaceModel.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@
	
${BUILD_DIR}/LieHomography.o: ${SSM_SRC_DIR}/LieHomography.cc ${SSM_HEADER_DIR}/LieHomography.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@

${BUILD_DIR}/CBH.o: ${SSM_SRC_DIR}/CBH.cc ${SSM_HEADER_DIR}/CBH.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@
	
${BUILD_DIR}/SL3.o: ${SSM_SRC_DIR}/SL3.cc ${SSM_HEADER_DIR}/SL3.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h ${UTILITIES_HEADER_DIR}/excpUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${SL3_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS}  $< -o $@
	
${BUILD_DIR}/Homography.o: ${SSM_SRC_DIR}/Homography.cc ${SSM_HEADER_DIR}/Homography.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@
	
${BUILD_DIR}/Affine.o: ${SSM_SRC_DIR}/Affine.cc ${SSM_HEADER_DIR}/Affine.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@
	
${BUILD_DIR}/Similitude.o: ${SSM_SRC_DIR}/Similitude.cc ${SSM_HEADER_DIR}/Similitude.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h ${UTILITIES_HEADER_DIR}/warpUtils.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${ISO_FLAGS} $< -o $@	
	
${BUILD_DIR}/Isometry.o: ${SSM_SRC_DIR}/Isometry.cc ${SSM_HEADER_DIR}/Isometry.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${UTILITIES_HEADER_DIR}/warpUtils.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${ISO_FLAGS} $< -o $@

${BUILD_DIR}/AST.o: ${SSM_SRC_DIR}/AST.cc ${SSM_HEADER_DIR}/AST.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h  ${UTILITIES_HEADER_DIR}/warpUtils.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${ISO_FLAGS} $< -o $@	
	
${BUILD_DIR}/IST.o: ${SSM_SRC_DIR}/IST.cc ${SSM_HEADER_DIR}/IST.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${SSM_HEADER_DIR}/SSMEstimator.h  ${UTILITIES_HEADER_DIR}/warpUtils.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${ISO_FLAGS} $< -o $@	
	
${BUILD_DIR}/Translation.o: ${SSM_SRC_DIR}/Translation.cc ${SSM_HEADER_DIR}/Translation.h ${SSM_HEADER_DIR}/ProjectiveBase.h ${SSM_BASE_HEADERS} ${UTILITIES_HEADER_DIR}/warpUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${TRANS_FLAGS} $< -o $@
	
${BUILD_DIR}/SSMEstimator.o: ${SSM_SRC_DIR}/SSMEstimator.cc ${SSM_HEADER_DIR}/SSMEstimator.h ${SSM_HEADER_DIR}/SSMEstimatorParams.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/warpUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@
	
${BUILD_DIR}/SSMEstimatorParams.o: ${SSM_SRC_DIR}/SSMEstimatorParams.cc ${SSM_HEADER_DIR}/SSMEstimatorParams.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} $< -o $@