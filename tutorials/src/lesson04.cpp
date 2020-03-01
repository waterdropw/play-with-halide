/**
 * Copyright 2019 Xiaobin Wei <xiaobin.wee@gmail.com>
 */

#include <stdio.h>

#include "Halide.h"
#define LOG_TAG "lesson4"
#include "utils.h"


int main(int argc, char** argv) {
    Halide::Var x("x"), y("y");
    {
        logd("Evaluating gradient\n");
        Halide::Func gradient("gradient");
        gradient(x, y) = x + y;
        gradient.trace_stores();
        Halide::Buffer<int> output = gradient.realize(4, 4);

        logd("\nEvaluating parallel_gradient\n");
        Halide::Func parallel_gradient("parallel_gradient");
        parallel_gradient(x, y) = x + y;
        parallel_gradient.trace_stores();
        parallel_gradient.parallel(y);

        parallel_gradient.realize(4, 4);
    }

    {
        Halide::Func f;
        f(x, y) = sin(x) + cos(y);

        Halide::Func g;
        g(x, y) = sin(x) + Halide::print(cos(y));

        logd("\nEvaluating sin(x) + cos(y), and just printing cos(y)\n");

        g.realize(4, 4);
    }

    {
        Halide::Func f;
        f(x, y) = sin(x) + Halide::print(cos(y), "<- this is cos(", y, ") when x=", x);

        logd("\nEvaluating sin(x) + cos(y), and printing cos(y) with more context\n");
        f.realize(4, 4);

        Halide::Expr e = cos(y);
        e = Halide::print(e, "<- this is cos(", y, ") when x=", x);
        Halide::Func g;
        g(x, y) = sin(x) + e;
        g.realize(4, 4);

    }

    {
        Halide::Func f;
        Halide::Expr e = cos(y);
        e = Halide::print_when(x == 37 && y == 42, e, "<- this is cos(y) at x, y == (37, 42)");
        f(x, y) = sin(x) + e;
        logd("\nEvaluating sin(x) + cos(y), and printing cos(y) at a single pixel\n");
        f.realize(640, 480);

        Halide::Func g;
        e = cos(y);
        e = Halide::print_when(e < 0, e, "cos(y) < 0 at y ==", y);
        g(x, y) = sin(x) + e;
        logd("\nEvaluating sin(x) + cos(y), and printing whenever cos(y) < 0\n");
        g.realize(4, 4);
    }

    {
        Halide::Var fizz("fizz"), buzz("buzz");
        Halide::Expr e = 1;
        for (int i = 2; i < 100; i++) {
            if (i % 3 == 0 && i % 5 == 0) e += fizz*buzz;
            else if (i % 3 == 0) e += fizz;
            else if (i % 5 == 0) e += buzz;
            else e += i;
        }
    }
    return 0;
}
