cmake_minimum_required(VERSION 3.6.0)

project(asteroid-heliograph
    VERSION 0.0.1
    DESCRIPTION "Scrolling light message app for AsteroidOS")

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMFindQmlModule)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

ecm_find_qmlmodule(Nemo.KeepAlive 1.1)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/asteroid-heliograph.in
    ${CMAKE_BINARY_DIR}/asteroid-heliograph
    @ONLY)

install(PROGRAMS ${CMAKE_BINARY_DIR}/asteroid-heliograph
    DESTINATION ${CMAKE_INSTALL_BINDIR})

install(FILES asteroid-heliograph.desktop
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)

build_translations(i18n)
add_subdirectory(src)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
