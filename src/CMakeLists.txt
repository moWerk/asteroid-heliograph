add_library(asteroid-heliograph main.cpp FileHelper.cpp resources.qrc)
set_target_properties(asteroid-heliograph PROPERTIES PREFIX "")

target_link_libraries(asteroid-heliograph PUBLIC
    Asteroid::AsteroidApp6)

install(TARGETS asteroid-heliograph
    DESTINATION ${CMAKE_INSTALL_LIBDIR})
