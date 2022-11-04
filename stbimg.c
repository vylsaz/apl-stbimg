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

typedef uint8_t  U1;
typedef uint16_t U2;
typedef int32_t  I4;
typedef float    F4;

typedef size_t   Usz;

// notice that it uses I4 (not a big problem)
STBIMG_API I4 STBIMG_Info(char const *filename, I4 *width, I4 *height, I4 *channels) {
    *width = 0; *height = 0; *channels = 0;
    return stbi_info(filename, width, height, channels);
}

STBIMG_API void STBIMG_Load_U1(char const *filename, I4 channels, U1 *rawdata) {
    I4 width = 0, height = 0, comp = 0;
    U1 *data = stbi_load(filename, &width, &height, &comp, channels);
    memcpy(rawdata, data, width*height*channels*sizeof(U1));
    stbi_image_free(data);
}

STBIMG_API void STBIMG_Load_F4(char const *filename, I4 channels, F4 *rawdata) {
    I4 width = 0, height = 0, comp = 0;
    F4 *data = stbi_loadf(filename, &width, &height, &comp, channels);
    memcpy(rawdata, data, width*height*channels*sizeof(F4));
    stbi_image_free(data);
}

STBIMG_API void STBIMG_Load_U2(char const *filename, I4 channels, U2 *rawdata) {
    I4 width = 0, height = 0, comp = 0;
    U2 *data = stbi_load_16(filename, &width, &height, &comp, channels);
    memcpy(rawdata, data, width*height*channels*sizeof(U2));
    stbi_image_free(data);
}

STBIMG_API I4 STBIMG_Save_PNG(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    return stbi_write_png(filename, width, height, channels, rawdata, channels*width*sizeof(U1));
}

STBIMG_API I4 STBIMG_Save_BMP(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    return stbi_write_bmp(filename, width, height, channels, rawdata);
}

STBIMG_API I4 STBIMG_Save_JPG(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    return stbi_write_jpg(filename, width, height, channels, rawdata, 100);
}

STBIMG_API I4 STBIMG_Save_TGA(char const *filename, I4 width, I4 height, I4 channels, U1 *rawdata) {
    return stbi_write_tga(filename, width, height, channels, rawdata);
}

STBIMG_API I4 STBIMG_Copy_UTF8(U1 *src, I4 len, char *dst) {
    if (src==NULL) {return 0;}
    memcpy(dst, src, len*sizeof(U1));
    free(src);
    return 1;
}

static U1 *Base64_Encode(U1 *mem, I4 len, I4 *out_len);

STBIMG_API U1 *STBIMG_Base64_PNG(I4 width, I4 height, I4 channels, U1 *rawdata, I4 *out_len) {
    I4 len = 0;
    U1 *mem = stbi_write_png_to_mem(rawdata, channels*width*sizeof(U1), width, height, channels, &len);
    U1 *out = Base64_Encode(mem, len, out_len);
    if (mem!=NULL) {STBI_FREE(mem);}
    return out;
}

// https://stackoverflow.com/a/41094722
U1 *Base64_Encode(U1 *mem, I4 len, I4 *out_len) {
    static U1 const charset[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    I4 nchars = 4*((len+2)/3);
    if (nchars < len) {return NULL;}

    U1 *out = calloc(nchars, sizeof(U1));
    U1 const *end = mem+len;
    U1 const *in  = mem;
    U1 *pos = out;
    
    while ((end-in)>=3) {
        *pos++ = charset[in[0] >> 2];
        *pos++ = charset[((in[0] & 0x03) << 4) | (in[1] >> 4)];
        *pos++ = charset[((in[1] & 0x0f) << 2) | (in[2] >> 6)];
        *pos++ = charset[in[2] & 0x3f];
        in += 3;
    }
    if (end-in) {
        *pos++ = charset[in[0] >> 2];
        if ((end-in)==1) {
            *pos++ = charset[(in[0] & 0x03) << 4];
            *pos++ = '=';
        }
        else {
            *pos++ = charset[((in[0] & 0x03) << 4) | (in[1] >> 4)];
            *pos++ = charset[(in[1] & 0x0f) << 2];
        }
        *pos++ = '=';
    }
    *out_len = nchars;
    return out;
}
