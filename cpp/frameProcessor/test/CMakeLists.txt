# Function to add a FrameProcessor unit test. The source must be of the form
#  <target_name>Test.cpp
# The target name will be prefixed with unit_fp_ to differentiate from any other type of
# unit test executables.

function(add_unit_test _target)
  set(_source ${_target}Test.cpp)
  set(_target "unit_fp_${_target}")
  add_executable(${_target} ${_source})

  target_link_libraries(${_target}
    ${LIB_PROCESSOR}
    ThresholdBinPlugin
    ${Boost_LIBRARIES}
    ${LOG4CXX_LIBRARIES}
    ${ZEROMQ_LIBRARIES}
    ${HDF5_LIBRARIES}
    ${HDF5_HL_LIBRARIES}
  )

  install(TARGETS ${_target} RUNTIME DESTINATION bin)
endfunction()

add_unit_test(ThresholdBinPlugin)
