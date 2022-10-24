// gcc stbimg.c -Wall -Wextra -pedantic -O3 -march=native -static -shared -o stbimg.dll
#include <stdlib.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function" 
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_STATIC
#define STBI_WINDOWS_UTF8
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_WRITE_STATIC
#define STBIW_WINDOWS_UTF8
#include "stb_image_write.h"
#pragma GCC diagnostic pop
#include <inttypes.h>

#ifndef STBIMG_EXPORTS
#define STBIMG_EXPORTS
#endif//STBIMG_EXPORTS

#ifdef _WIN32
#ifdef STBIMG_EXPORTS
#define STBIMG_API  __declspec(dllexport) 
#else
#define STBIMG_API  __declspec(dllimport)
#endif
#else
#define STBIMG_API
#endif//_WIN32

#ifdef __GNUC__
#define FALLTHRU    __attribute__((fallthrough))
#else
#define FALLTHRU    
#endif

typedef uint8_t  U1;
typedef int32_t  I4;
typedef float    F4;

// notice that it uses I4 (not a big problem)
STBIMG_API I4 STBIMG_Info(char const *filename, I4 *width, I4 *height, I4 *channels) {
    return stbi_info(filename, width, height, channels);
}

STBIMG_API void STBIMG_Load(char const *filename, I4 channels, U1 *ch1, U1 *ch2, U1 *ch3, U1 *ch4) {
    I4 width = 0, height = 0, comp = 0;
    U1 *data = stbi_load(filename, &width, &height, &comp, channels);
    // Read data to provided arrays
    for (I4 i = 0; i<height; ++i) {
        U1 *row = &data[i*channels*width];
        for (I4 j = 0; j<width; ++j) {
            switch (channels) {
            case 4: ch4[j+width*i] = row[3+channels*j]; FALLTHRU;
            case 3: ch3[j+width*i] = row[2+channels*j]; FALLTHRU;
            case 2: ch2[j+width*i] = row[1+channels*j]; FALLTHRU;
            case 1: ch1[j+width*i] = row[0+channels*j];
            }
        }
    }
    stbi_image_free(data);
}

STBIMG_API void STBIMG_Load_Norm(char const *filename, I4 channels, F4 *ch1, F4 *ch2, F4 *ch3, F4 *ch4) {
    I4 width = 0, height = 0, comp = 0;
    F4 *data = stbi_loadf(filename, &width, &height, &comp, channels);
    // Read data to provided arrays
    for (I4 i = 0; i<height; ++i) {
        F4 *row = &data[i*channels*width];
        for (I4 j = 0; j<width; ++j) {
            switch (channels) {
            case 4: ch4[j+width*i] = row[3+channels*j]; FALLTHRU;
            case 3: ch3[j+width*i] = row[2+channels*j]; FALLTHRU;
            case 2: ch2[j+width*i] = row[1+channels*j]; FALLTHRU;
            case 1: ch1[j+width*i] = row[0+channels*j];
            }
        }
    }
    stbi_image_free(data);
}

STBIMG_API void STBIMG_Load_Raw(char const *filename, I4 channels, U1 *rawdata) {
    I4 width = 0, height = 0, comp = 0;
    U1 *data = stbi_load(filename, &width, &height, &comp, channels);
    memcpy(rawdata, data, width*height*channels);
    stbi_image_free(data);
}

STBIMG_API I4 STBIMG_Save_PNG_Raw(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    return stbi_write_png(filename, width, height, channels, rawdata, channels*width*sizeof(U1));
}

STBIMG_API I4 STBIMG_Save_BMP_Raw(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    return stbi_write_bmp(filename, width, height, channels, rawdata);
}

STBIMG_API I4 STBIMG_Save_JPG_Raw(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    return stbi_write_jpg(filename, width, height, channels, rawdata, 100);
}

STBIMG_API I4 STBIMG_Save_TGA_Raw(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    stbi_write_tga_with_rle = 0;
    return stbi_write_tga(filename, width, height, channels, rawdata);
}
