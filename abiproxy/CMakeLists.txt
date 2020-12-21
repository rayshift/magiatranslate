# CMakeList.txt : CMake project for AbiProxy, include source and define
# project specific logic here.
#
#set(CMAKE_CXX_STANDARD 11)
cmake_minimum_required (VERSION 3.8)

project ("AbiProxy")
set(TARGET_NAME abiproxy)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

if(CMAKE_BUILD_TYPE STREQUAL "Release")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fvisibility=hidden -fvisibility-inlines-hidden -g0 -O3 -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fvisibility=hidden -fvisibility-inlines-hidden -g0 -O3 -ffunction-sections -fdata-sections")
endif(CMAKE_BUILD_TYPE STREQUAL "Release")

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/../lib
  ${CMAKE_CURRENT_SOURCE_DIR}/../lib/cocos
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
link_libraries("-Wl,--strip-all")
endif(CMAKE_BUILD_TYPE STREQUAL "Release")

add_library( # Sets the name of the library.
  ${TARGET_NAME}
  # Sets the library as a shared library.
  SHARED
  
  # Provides a relative path to your source file(s).
  "src/magia/StringsProxy.cc"
  "src/magia/DialogueBox.cc")

find_library(ANDROID_LOG_LIB log)
target_link_libraries(${TARGET_NAME} ${ANDROID_LOG_LIB})

macro(SET_OPTION option value)
  set(${option} ${value} CACHE INTERNAL "" FORCE)
endmacro()
