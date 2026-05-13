ARG ODIN_DATA_VERSION=1.12.0-xspress-dev4
ARG EIGER_DETECTOR_VERSION=1.17.0

FROM ghcr.io/odin-detector/odin-data-build:${ODIN_DATA_VERSION} AS build

# Redeclare Eiger detector version in stage
# (it goes out of scope after the FROM command above)
ARG EIGER_DETECTOR_VERSION

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

# Use /odin as the workspace root
WORKDIR /odin

# Clone eiger-detector
RUN git clone --branch ${EIGER_DETECTOR_VERSION} --depth 1 https://github.com/DiamondLightSource/eiger-detector.git

# Build the C++ part of eiger-detector
WORKDIR /odin/eiger-detector
RUN mkdir -p build && cd build && \
    cmake \
    -DCMAKE_INSTALL_PREFIX=/odin \
    -DODINDATA_ROOT_DIR=/odin \
    -DCMAKE_PREFIX_PATH=/odin \
    ../cpp && \
    make -j$(nproc) && \
    make install

# Build the Python part of eiger-detector
WORKDIR /odin/eiger-detector/python
RUN python -m pip install .

FROM ghcr.io/odin-detector/odin-data-runtime:${ODIN_DATA_VERSION} AS runtime

# Copy full install tree
COPY --from=build /odin /odin

# Copy the venv
COPY --from=build /venv /venv

# Copy the deploy configs
COPY --from=build /odin/eiger-detector/deploy /odin/eiger-deploy

# Remove the eiger-detector source tree now it has been built
RUN rm -rf /odin/eiger-detector

# Add binaries and Python venv to the image PATH
ENV PATH=/odin/bin:/odin/venv/bin:$PATH

# Use /odin as the landing directory
WORKDIR /odin
