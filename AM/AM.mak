# ------------------------------------------------------------------------------------- #
# --------------------------------- Appearance Models --------------------------------- #
# ------------------------------------------------------------------------------------- #
AM_INCLUDE_DIR = AM/include
AM_SRC_DIR = AM/src
AM_HEADER_DIR = ${AM_INCLUDE_DIR}/mtf/AM
AM_BASE_HEADERS =  ${AM_HEADER_DIR}/AppearanceModel.h  ${AM_HEADER_DIR}/ImageBase.h ${AM_HEADER_DIR}/AMParams.h ${AM_HEADER_DIR}/IlluminationModel.h  ${UTILITIES_HEADER_DIR}/excpUtils.h 

MTF_INCLUDE_DIRS += ${AM_INCLUDE_DIR}

APPEARANCE_MODULES = AMParams ImageBase SSDBase
APPEARANCE_MODELS = SSD NSSD ZNCC SCV LSCV RSCV LRSCV CCRE LKLD MI SSIM NCC SPSS KLD RIU NGF SAD MCSSD MCSCV MCLSCV MCRSCV MCZNCC MCNCC MCMI MCSSIM MCSPSS MCCCRE MCRIU MCSAD SumOfAMs
APPEARANCE_OBJS = $(addprefix ${BUILD_DIR}/,$(addsuffix .o, ${APPEARANCE_MODULES}))
APPEARANCE_OBJS += $(addprefix ${BUILD_DIR}/,$(addsuffix .o, ${APPEARANCE_MODELS}))
APPEARANCE_HEADERS = $(addprefix ${AM_HEADER_DIR}/, $(addsuffix .h, ${APPEARANCE_MODULES}))
APPEARANCE_HEADERS += $(addprefix ${AM_HEADER_DIR}/, $(addsuffix .h, ${APPEARANCE_MODELS}))
APPEARANCE_HEADERS += ${AM_BASE_HEADERS}

ILLUMINATION_MODELS = GB PGB RBF
ILLUMINATION_HEADERS = $(addprefix ${AM_HEADER_DIR}/, $(addsuffix .h, ${ILLUMINATION_MODELS}))
ILLUMINATION_OBJS = $(addprefix ${BUILD_DIR}/,$(addsuffix .o, ${ILLUMINATION_MODELS}))

MTF_HEADERS += ${APPEARANCE_HEADERS} ${ILLUMINATION_HEADERS}
MTF_OBJS += ${APPEARANCE_OBJS} ${ILLUMINATION_OBJS}

MI_FLAGS = 
CCRE_FLAGS = 
LSCV_FLAGS = 
SSD_FLAGS = 
DFM_FLAGS = 

dfm ?= 0
dfm_cpu ?= 0
pca ?= 1
mil ?= 0
mid ?= 0
mitbb ?= 0
miomp ?= 0
ccretbb ?= 0
ccreomp ?= 0
ncctbb ?= 0
nccomp ?= 0
sg ?= 0
lscd ?= 0
ctch ?= 1
ctdf ?= 0

ifeq (${ctch}, 0)
CCRE_FLAGS += -D CCRE_DISABLE_TRUE_CUM_HIST
endif
ifeq (${ctdf}, 1)
CCRE_FLAGS += -D CCRE_ENABLE_TRUE_DIST_FEAT
endif

ifeq (${dfm}, 1)
APPEARANCE_MODELS += DFM
MTF_INCLUDE_FLAGS += -I/usr/lib/caffe_fcn/include/ -I/usr/local/cuda-7.5/targets/x86_64-linux/include/ -I/usr/lib/caffe_fcn/.build_release/include/
MTF_LIBS += -L/usr/lib/caffe_fcn/.build_release/lib -lcaffe
else
MTF_COMPILETIME_FLAGS += -D DISABLE_DFM
MTF_RUNTIME_FLAGS += -D DISABLE_DFM
endif
ifeq (${dfm_cpu}, 1)
DFM_FLAGS += -D CPU_ONLY
MTF_COMPILETIME_FLAGS += -D CPU_ONLY
MTF_RUNTIME_FLAGS += -D CPU_ONLY
endif
ifeq (${pca}, 1)
APPEARANCE_MODELS += PCA MCPCA
else
MTF_COMPILETIME_FLAGS += -D DISABLE_PCA
MTF_RUNTIME_FLAGS += -D DISABLE_PCA
endif
ifeq (${mitbb}, 1)
MI_FLAGS += -D ENABLE_TBB
MTF_RUNTIME_FLAGS += -D ENABLE_PARALLEL
endif

ifeq (${miomp}, 1)
MI_FLAGS += -D ENABLE_OMP -fopenmp
MTF_RUNTIME_FLAGS += -D ENABLE_PARALLEL -fopenmp
MTF_LIBS += -fopenmp
endif

ifeq (${ccretbb}, 1)
CCRE_FLAGS += -D ENABLE_TBB
MTF_RUNTIME_FLAGS += -D ENABLE_PARALLEL
else
ifeq (${ccreomp}, 1)
CCRE_FLAGS += -D ENABLE_OMP -fopenmp
MTF_RUNTIME_FLAGS += -D ENABLE_PARALLEL -fopenmp
MTF_LIBS += -fopenmp
endif
endif

ifeq (${ncctbb}, 1)
NCC_FLAGS += -D ENABLE_TBB
MTF_RUNTIME_FLAGS += -D ENABLE_PARALLEL
else
ifeq (${nccomp}, 1)
NCC_FLAGS += -D ENABLE_OMP -fopenmp
MTF_RUNTIME_FLAGS += -D ENABLE_PARALLEL -fopenmp
MTF_LIBS += -fopenmp
endif
endif

ifeq (${mid}, 1)
MI_FLAGS = -D LOG_MI_DATA
endif

ifeq (${mil}, 1)
MI_FLAGS = -D LOG_MI_DATA -D LOG_MI_TIMES 
endif

ifeq (${sg}, 1)
SSD_FLAGS += -D USE_SLOW_GRAD
endif

ifeq (${lscd}, 1)
LSCV_FLAGS += -D LOG_LSCV_DATA
endif

${BUILD_DIR}/AMParams.o: ${AM_SRC_DIR}/AMParams.cc  ${AM_HEADER_DIR}/AMParams.h ${AM_HEADER_DIR}/IlluminationModel.h ${MACROS_HEADER_DIR}/common.h 
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@
	
${BUILD_DIR}/ImageBase.o: ${AM_SRC_DIR}/ImageBase.cc  ${AM_HEADER_DIR}/ImageBase.h ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@
	
${BUILD_DIR}/SSDBase.o: ${AM_SRC_DIR}/SSDBase.cc ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h ${UTILITIES_HEADER_DIR}/spiUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@	
	
${BUILD_DIR}/SSD.o: ${AM_SRC_DIR}/SSD.cc ${AM_HEADER_DIR}/SSD.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/excpUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@
	
${BUILD_DIR}/NSSD.o: ${AM_SRC_DIR}/NSSD.cc ${AM_HEADER_DIR}/NSSD.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@
	
${BUILD_DIR}/ZNCC.o: ${AM_SRC_DIR}/ZNCC.cc ${AM_HEADER_DIR}/ZNCC.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@
	
${BUILD_DIR}/SCV.o: ${AM_SRC_DIR}/SCV.cc ${AM_HEADER_DIR}/SCV.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@
	
${BUILD_DIR}/LSCV.o: ${AM_SRC_DIR}/LSCV.cc ${AM_HEADER_DIR}/LSCV.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} ${LSCV_FLAGS} $< -o $@
	
${BUILD_DIR}/RSCV.o: ${AM_SRC_DIR}/RSCV.cc ${AM_HEADER_DIR}/RSCV.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@	
	
${BUILD_DIR}/LRSCV.o: ${AM_SRC_DIR}/LRSCV.cc ${AM_HEADER_DIR}/LRSCV.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} ${LRSCV_FLAGS} $< -o $@
	
${BUILD_DIR}/DFM.o: ${AM_SRC_DIR}/DFM.cc ${AM_HEADER_DIR}/DFM.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${DFM_FLAGS} ${CAFFE_FLAGS} $< -o $@
	
${BUILD_DIR}/PCA.o: ${AM_SRC_DIR}/PCA.cc ${AM_HEADER_DIR}/PCA.h  ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${PCA_FLAGS} $< -o $@
	
${BUILD_DIR}/KLD.o: ${AM_SRC_DIR}/KLD.cc ${AM_HEADER_DIR}/KLD.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/histUtils.h ${UTILITIES_HEADER_DIR}/imgUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${KLD_FLAGS} $< -o $@
	
${BUILD_DIR}/LKLD.o: ${AM_SRC_DIR}/LKLD.cc ${AM_HEADER_DIR}/LKLD.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/histUtils.h ${UTILITIES_HEADER_DIR}/imgUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${LKLD_FLAGS} $< -o $@
	
${BUILD_DIR}/MI.o: ${AM_SRC_DIR}/MI.cc ${AM_HEADER_DIR}/MI.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/histUtils.h ${UTILITIES_HEADER_DIR}/imgUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${MI_FLAGS} $< -o $@
	
${BUILD_DIR}/CCRE.o: ${AM_SRC_DIR}/CCRE.cc ${AM_HEADER_DIR}/CCRE.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/histUtils.h ${UTILITIES_HEADER_DIR}/imgUtils.h ${UTILITIES_HEADER_DIR}/miscUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${CCRE_FLAGS} $< -o $@	

${BUILD_DIR}/SSIM.o: ${AM_SRC_DIR}/SSIM.cc ${AM_HEADER_DIR}/SSIM.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSIM_FLAGS} $< -o $@
	
${BUILD_DIR}/SPSS.o: ${AM_SRC_DIR}/SPSS.cc ${AM_HEADER_DIR}/SPSS.h ${AM_BASE_HEADERS}  ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SPSS_FLAGS} $< -o $@
	
${BUILD_DIR}/NCC.o: ${AM_SRC_DIR}/NCC.cc ${AM_HEADER_DIR}/NCC.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${NCC_FLAGS} $< -o $@
	
${BUILD_DIR}/RIU.o: ${AM_SRC_DIR}/RIU.cc ${AM_HEADER_DIR}/RIU.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${RIU_FLAGS} $< -o $@	
	
${BUILD_DIR}/NGF.o: ${AM_SRC_DIR}/NGF.cc ${AM_HEADER_DIR}/NGF.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${NGF_FLAGS} $< -o $@	
	
${BUILD_DIR}/SAD.o: ${AM_SRC_DIR}/SAD.cc ${AM_HEADER_DIR}/SAD.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SAD_FLAGS} $< -o $@
	
${BUILD_DIR}/SumOfAMs.o: ${AM_SRC_DIR}/SumOfAMs.cc ${AM_HEADER_DIR}/SumOfAMs.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SumOfAMs_FLAGS} $< -o $@
	
${BUILD_DIR}/MCSSD.o: ${AM_SRC_DIR}/MCSSD.cc ${AM_HEADER_DIR}/MCSSD.h ${AM_HEADER_DIR}/SSD.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSD_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCSCV.o: ${AM_SRC_DIR}/MCSCV.cc ${AM_HEADER_DIR}/MCSCV.h ${AM_HEADER_DIR}/SCV.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SCV_FLAGS} $< -o $@

${BUILD_DIR}/MCLSCV.o: ${AM_SRC_DIR}/MCLSCV.cc ${AM_HEADER_DIR}/MCLSCV.h ${AM_HEADER_DIR}/LSCV.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SCV_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCRSCV.o: ${AM_SRC_DIR}/MCRSCV.cc ${AM_HEADER_DIR}/MCRSCV.h ${AM_HEADER_DIR}/RSCV.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${RSCV_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCZNCC.o: ${AM_SRC_DIR}/MCZNCC.cc ${AM_HEADER_DIR}/MCZNCC.h ${AM_HEADER_DIR}/ZNCC.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${ZNCC_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCMI.o: ${AM_SRC_DIR}/MCMI.cc ${AM_HEADER_DIR}/MCMI.h ${AM_HEADER_DIR}/MI.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${MI_FLAGS} $< -o $@
	
${BUILD_DIR}/MCNCC.o: ${AM_SRC_DIR}/MCNCC.cc ${AM_HEADER_DIR}/MCNCC.h ${AM_HEADER_DIR}/NCC.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${NCC_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCSSIM.o: ${AM_SRC_DIR}/MCSSIM.cc ${AM_HEADER_DIR}/MCSSIM.h ${AM_HEADER_DIR}/SSIM.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SSIM_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCSPSS.o: ${AM_SRC_DIR}/MCSPSS.cc ${AM_HEADER_DIR}/MCSPSS.h ${AM_HEADER_DIR}/SPSS.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SPSS_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCCCRE.o: ${AM_SRC_DIR}/MCCCRE.cc ${AM_HEADER_DIR}/MCCCRE.h ${AM_HEADER_DIR}/CCRE.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${CCRE_FLAGS} $< -o $@	
	
${BUILD_DIR}/MCRIU.o: ${AM_SRC_DIR}/MCRIU.cc ${AM_HEADER_DIR}/MCRIU.h ${AM_HEADER_DIR}/RIU.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${RIU_FLAGS} $< -o $@

${BUILD_DIR}/MCSAD.o: ${AM_SRC_DIR}/MCSAD.cc ${AM_HEADER_DIR}/MCSAD.h ${AM_HEADER_DIR}/SAD.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${SAD_FLAGS} $< -o $@		
	
${BUILD_DIR}/MCPCA.o: ${AM_SRC_DIR}/MCPCA.cc ${AM_HEADER_DIR}/MCPCA.h ${AM_HEADER_DIR}/PCA.h ${AM_HEADER_DIR}/SSDBase.h ${AM_BASE_HEADERS} ${MACROS_HEADER_DIR}/common.h ${UTILITIES_HEADER_DIR}/imgUtils.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${PCA_FLAGS} $< -o $@		
	
${BUILD_DIR}/GB.o: ${AM_SRC_DIR}/GB.cc ${AM_HEADER_DIR}/GB.h ${AM_HEADER_DIR}/IlluminationModel.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${GB_FLAGS} $< -o $@	

${BUILD_DIR}/PGB.o: ${AM_SRC_DIR}/PGB.cc ${AM_HEADER_DIR}/PGB.h ${AM_HEADER_DIR}/IlluminationModel.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${PGB_FLAGS} $< -o $@
	
${BUILD_DIR}/RBF.o: ${AM_SRC_DIR}/RBF.cc ${AM_HEADER_DIR}/RBF.h ${AM_HEADER_DIR}/IlluminationModel.h ${MACROS_HEADER_DIR}/common.h
	${CXX} -c ${MTF_PIC_FLAG} ${WARNING_FLAGS} ${OPT_FLAGS} ${PROF_FLAGS} ${MTF_COMPILETIME_FLAGS} ${MTF_INCLUDE_FLAGS} ${PGB_FLAGS} $< -o $@