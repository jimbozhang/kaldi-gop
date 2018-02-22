cmake_minimum_required (VERSION 2.6)
project (kaldi-gop)

######
# Check BLAS
find_package(BLAS)
if(NOT BLAS_FOUND)
  message(FATAL_ERROR "Can't find BLAS. On Ubunbu, you may want to "
                "install it by:\n  sudo apt-get install libatlas-dev")
endif()

######
# Build Kaldi
set(KALDI_VERSION 5.3)
set(BUILD_JOBS 8)
set(DEPENDS_DIR "${CMAKE_SOURCE_DIR}/../depends")
set(KALDI_ROOT "${DEPENDS_DIR}/kaldi-${KALDI_VERSION}")
if(NOT EXISTS "${KALDI_ROOT}/tools/openfst/bin/fstcompile")
  if (NOT EXISTS "${DEPENDS_DIR}/${KALDI_VERSION}.zip")
    execute_process(COMMAND wget https://github.com/kaldi-asr/kaldi/archive/${KALDI_VERSION}.zip
                    WORKING_DIRECTORY ${DEPENDS_DIR})
  endif()
  execute_process(COMMAND unzip -o ${KALDI_VERSION}.zip -d ${DEPENDS_DIR}
                   WORKING_DIRECTORY ${DEPENDS_DIR})
  execute_process(COMMAND ln -s kaldi-${KALDI_VERSION} kaldi
                   WORKING_DIRECTORY ${DEPENDS_DIR})
  execute_process(COMMAND make -j ${BUILD_JOBS} WORKING_DIRECTORY ${KALDI_ROOT}/tools)
  execute_process(COMMAND patch kaldi/src/Makefile kaldi-makefile.patch WORKING_DIRECTORY ${DEPENDS_DIR})
endif()

if(NOT EXISTS "${KALDI_ROOT}/src/decoder/kaldi-decoder.a")
  execute_process(COMMAND ./configure WORKING_DIRECTORY ${KALDI_ROOT}/src)
  execute_process(COMMAND make depend -j ${BUILD_JOBS} WORKING_DIRECTORY ${KALDI_ROOT}/src)
  execute_process(COMMAND make -j ${BUILD_JOBS} WORKING_DIRECTORY ${KALDI_ROOT}/src)
endif()

######
# Settings
add_compile_options(-std=c++11)
add_definitions(-DHAVE_ATLAS)
add_definitions(-Wno-deprecated-declarations)
include_directories("${KALDI_ROOT}/src")
include_directories("${KALDI_ROOT}/tools/openfst/include")
include_directories("${KALDI_ROOT}/tools/ATLAS/include")

######
# Build libgop.a
include_directories(".")
file(GLOB GOP "gop/*.cc")
add_library(gop ${GOP})
target_link_libraries(gop ${KALDI_ROOT}/src/decoder/kaldi-decoder.a)
target_link_libraries(gop ${KALDI_ROOT}/src/fstext/kaldi-fstext.a)
target_link_libraries(gop ${KALDI_ROOT}/src/hmm/kaldi-hmm.a)
target_link_libraries(gop ${KALDI_ROOT}/src/gmm/kaldi-gmm.a)
target_link_libraries(gop ${KALDI_ROOT}/src/tree/kaldi-tree.a)
target_link_libraries(gop ${KALDI_ROOT}/src/util/kaldi-util.a)
target_link_libraries(gop ${KALDI_ROOT}/src/matrix/kaldi-matrix.a)
target_link_libraries(gop ${KALDI_ROOT}/src/base/kaldi-base.a)
target_link_libraries(gop ${KALDI_ROOT}/tools/openfst/lib/libfst.a)
target_link_libraries(gop dl.so)
find_library (LIBCBLAS libcblas.so.3)
find_library (LIBLAPACK liblapack_atlas.so.3)
target_link_libraries(gop ${LIBCBLAS})
target_link_libraries(gop ${LIBLAPACK})

######
# Build compute-gmm-gop
add_executable(compute-gmm-gop gopbin/compute-gmm-gop.cc)
target_link_libraries(compute-gmm-gop gop)
find_package(Threads)
target_link_libraries(compute-gmm-gop ${CMAKE_THREAD_LIBS_INIT})
