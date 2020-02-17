/**
 * Copyright 2019 Xiaobin Wei <xiaobin.wee@gmail.com>
 */

#include <stdio.h>
#include <assert.h>

#include "HalideBuffer.h"

#include "brighten_planar.h"
#include "brighten_interleaved.h"
#include "brighten_either.h"
#include "brighten_specialized.h"

#define LOG_TAG "lesson16"
#include "utils.h"
using namespace utils::perf;


int main(int argc, char** argv) {
    Halide::Runtime::Buffer<uint8_t> planar_input(1024, 768, 3);
    Halide::Runtime::Buffer<uint8_t> planar_output(1024, 768, 3);
    Halide::Runtime::Buffer<uint8_t> interleaved_input =
        Halide::Runtime::Buffer<uint8_t>::make_interleaved(1024, 768, 3);
    Halide::Runtime::Buffer<uint8_t> interleaved_output =
        Halide::Runtime::Buffer<uint8_t>::make_interleaved(1024, 768, 3);

    assert(planar_output.dim(0).stride() == 1);
    assert(interleaved_input.dim(0).stride() == 3);
    assert(interleaved_output.dim(0).stride() == 3);
    assert(interleaved_input.dim(2).stride() == 1);
    assert(interleaved_output.dim(2).stride() == 1);

    const long LOOP_CNT = 1000;

    Timer timer;
    for (int i = 0; i < LOOP_CNT; i++) {
        brighten_planar(planar_input, 1, planar_output);
    }
    logd("planar: total %.2f ms ave %.2f ms", timer.get_msecs (), timer.get_msecs_reset()/LOOP_CNT);

    for (int i = 0; i < LOOP_CNT; i++) {
        brighten_interleaved(interleaved_input, 1, interleaved_output);
    }
    logd("interleaved: total %.2f ms ave %.2f ms", timer.get_msecs (), timer.get_msecs_reset()/LOOP_CNT);

    for (int i = 0; i < LOOP_CNT; i++) {
        brighten_either(planar_input, 1, planar_output);
    }
    logd("either on planar image: total %.2f ms ave %.2f ms", timer.get_msecs (), timer.get_msecs_reset()/LOOP_CNT);

    for (int i = 0; i < LOOP_CNT; i++) {
        brighten_either(interleaved_input, 1, interleaved_output);
    }
    logd("either on interleaved image: total %.2f ms ave %.2f ms", timer.get_msecs (), timer.get_msecs_reset()/LOOP_CNT);

    for (int i = 0; i < LOOP_CNT; i++) {
        brighten_specialized(planar_input, 1, planar_output);
    }
    logd("specialized on planar image: total %.2f ms ave %.2f ms", timer.get_msecs (), timer.get_msecs_reset()/LOOP_CNT);

    for (int i = 0; i < LOOP_CNT; i++) {
        brighten_specialized(interleaved_input, 1, interleaved_output);
    }
    logd("specialized on interleaved image: total %.2f ms ave %.2f ms", timer.get_msecs (), timer.get_msecs_reset()/LOOP_CNT);

    return 0;
}
