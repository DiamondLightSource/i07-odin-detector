# Add library for ThresholdBin plugin
add_library(ThresholdBinPlugin SHARED ThresholdBinPlugin.cpp ThresholdBinPluginLib.cpp)

target_include_directories(ThresholdBinPlugin
    # The target and its consumers (unit tests) can see these headers
    PUBLIC
        # Use one include path during the build, another after the install
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
        $<INSTALL_INTERFACE:include/frameProcessor>
)

target_link_libraries(ThresholdBinPlugin ${LIB_PROCESSOR} ${Boost_LIBRARIES} ${LOG4CXX_LIBRARIES} ${ZEROMQ_LIBRARIES} ${COMMON_LIBRARY})
install(TARGETS ThresholdBinPlugin DESTINATION lib)
