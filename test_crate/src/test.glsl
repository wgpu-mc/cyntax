#version 440
#define a 1
#ifdef a
int a_defined = TEST_MACRO;
#else
int a_not_defined = TEST_MACRO;

texelFetch(x, y).r;
