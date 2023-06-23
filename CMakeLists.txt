# CMakeList.txt : CMake project for MagiaClient, include source and define
# project specific logic here.
#
#set(CMAKE_CXX_STANDARD 11)
cmake_minimum_required (VERSION 3.8)

project ("MagiaClient")
set(TARGET_NAME uwasa)
#if (CMAKE_BUILD_TYPE STREQUAL "Debug")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++ -fsanitize=address -fno-omit-frame-pointer")
#else
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++")
#endif(CMAKE_BUILD_TYPE STREQUAL "Debug")

if(CMAKE_BUILD_TYPE STREQUAL "Release")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fvisibility=hidden -fvisibility-inlines-hidden -g0 -O3 -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fvisibility=hidden -fvisibility-inlines-hidden -g0 -O3 -ffunction-sections -fdata-sections")
endif(CMAKE_BUILD_TYPE STREQUAL "Release")

set(DobbyHome ${CMAKE_CURRENT_SOURCE_DIR}/lib/Dobby)
include_directories(
  ${DobbyHome}/include
  ${DobbyHome}/builtin-plugin
  ${DobbyHome}/builtin-plugin/SymbolResolver
  ${DobbyHome}/external/logging
  ${DobbyHome}/source
  ${CMAKE_CURRENT_SOURCE_DIR}/lib
  ${CMAKE_CURRENT_SOURCE_DIR}/lib/cocos
  ${CMAKE_CURRENT_SOURCE_DIR}/abiproxy/src
)

include(FetchContent)

FetchContent_Declare(json
  GIT_REPOSITORY https://github.com/ArthurSonzogni/nlohmann_json_cmake_fetchcontent
  GIT_TAG v3.9.1)

FetchContent_GetProperties(json)
if(NOT json_POPULATED)
  FetchContent_Populate(json)
  add_subdirectory(${json_SOURCE_DIR} ${json_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()


if(CMAKE_BUILD_TYPE STREQUAL "Release")
link_libraries("-Wl,--strip-all")
endif(CMAKE_BUILD_TYPE STREQUAL "Release")

add_library( # Sets the name of the library.
  ${TARGET_NAME}
  # Sets the library as a shared library.
  SHARED
  
  # Provides a relative path to your source file(s).
  "lib/cocos/math/CCGeometry.cpp"
  "lib/cocos/math/Vec2.cpp"
  "src/MagiaClient.cpp"
  "src/Utils.cpp"
  "src/rest/MagiaRest.cpp"
  )

find_library(ANDROID_LOG_LIB log)
target_link_libraries(${TARGET_NAME} PRIVATE ${ANDROID_LOG_LIB})
target_link_libraries(${TARGET_NAME} PRIVATE dobby_static)
target_link_libraries(${TARGET_NAME} PRIVATE nlohmann_json::nlohmann_json)


macro(SET_OPTION option value)
  set(${option} ${value} CACHE INTERNAL "" FORCE)
endmacro()
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
SET_OPTION(DOBBY_DEBUG ON)
endif(CMAKE_BUILD_TYPE STREQUAL "Debug")
SET_OPTION(DOBBY_GENERATE_SHARED OFF)
SET_OPTION(DynamicBinaryInstrument ON)
SET_OPTION(NearBranch ON)
SET_OPTION(Plugin.SymbolResolver ON)

add_subdirectory(${DobbyHome} dobby)
