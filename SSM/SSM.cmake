set(STATE_SPACE_MODELS Spline LieHomography CBH Homography SL3 Affine Similitude Isometry AST IST Translation)
set(SSM_MODULES ProjectiveBase SSMEstimator SSMEstimatorParams)
addPrefixAndSuffix("${STATE_SPACE_MODELS}" "SSM/src/" ".cc" STATE_SPACE_MODELS_SRC)
addPrefixAndSuffix("${SSM_MODULES}" "SSM/src/" ".cc" SSM_MODULES_SRC)
set(MTF_SRC ${MTF_SRC} ${STATE_SPACE_MODELS_SRC})
set(MTF_SRC ${MTF_SRC} ${SSM_MODULES_SRC})
set(MTF_INCLUDE_DIRS ${MTF_INCLUDE_DIRS} SSM/include)
