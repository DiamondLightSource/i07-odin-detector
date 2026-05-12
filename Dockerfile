FROM ghcr.io/odin-detector/odin-data-build:1.12.0-xspress-dev4 AS build

# Use /odin as the workspace root
WORKDIR /odin

# Copy this plugin repo into /odin/i07-odin-detector
COPY . /odin/i07-odin-detector

# Overlay the i07 plugin into the odin-data FrameProcessor source tree
RUN rm -rf /odin/odin-data/cpp/frameProcessor/src/i07 && \
    mkdir -p /odin/odin-data/cpp/frameProcessor/src/i07 && \
    cp -r /odin/i07-odin-detector/cpp/frameProcessor/. \
          /odin/odin-data/cpp/frameProcessor/src/i07

# Add the i07 plugin directory to the FrameProcessor CMake build
RUN printf '\nadd_subdirectory(i07)\n' >> /odin/odin-data/cpp/frameProcessor/src/CMakeLists.txt

# Build odin-data with the i07 plugin included
WORKDIR /odin/odin-data/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/odin \
    ../cpp && \
    make -j$(nproc) && \
    make install

# Remove the i07 plugin source tree now it has been built into odin-data
RUN rm -rf /odin/i07-odin-detector

# Use /odin as the landing directory
WORKDIR /odin
