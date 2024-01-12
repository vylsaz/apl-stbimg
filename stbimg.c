#include <stdlib.h>

#if defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function" 
#endif

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_STATIC
#define STBI_WINDOWS_UTF8
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_WRITE_STATIC
#define STBIW_WINDOWS_UTF8
#include "stb_image_write.h"

#if defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Warray-bounds" 
#endif
#define STB_IMAGE_RESIZE_IMPLEMENTATION
#define STB_IMAGE_RESIZE_STATIC
#include "stb_image_resize2.h"
#if defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

#if defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

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
typedef int8_t   I1;
typedef int32_t  I4;
typedef float    F4;

// notice that it uses I4 (not a big problem)
STBIMG_API I4 STBIMG_Info(char const *filename, I4 *height, I4 *width, I4 *channels) {
    *width = 0; *height = 0; *channels = 0;
    return stbi_info(filename, width, height, channels);
}

STBIMG_API void STBIMG_Load_I1(char const *filename, I4 channels, I1 *rawdata) {
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

STBIMG_API I4 STBIMG_Info_Mem(U1 const *mem, I4 len, I4 *height, I4 *width, I4 *channels) {
    *width = 0; *height = 0; *channels = 0;
    return stbi_info_from_memory(mem, len, width, height, channels);
}

STBIMG_API void STBIMG_Load_Mem_I1(U1 const *mem, I4 len, I4 channels, I1 *rawdata) {
    I4 width = 0, height = 0, comp = 0;
    U1 *data = stbi_load_from_memory(mem, len, &width, &height, &comp, channels);
    memcpy(rawdata, data, width*height*channels*sizeof(U1));
    stbi_image_free(data);
}

STBIMG_API I4 STBIMG_Save_PNG(char const *filename, I4 height, I4 width, I4 channels, I1 *rawdata) {
    return stbi_write_png(filename, width, height, channels, rawdata, channels*width*sizeof(I1));
}

STBIMG_API I4 STBIMG_Save_BMP(char const *filename, I4 height, I4 width, I4 channels, I1 *rawdata) {
    return stbi_write_bmp(filename, width, height, channels, rawdata);
}

STBIMG_API I4 STBIMG_Save_JPG(char const *filename, I4 height, I4 width, I4 channels, I1 *rawdata) {
    return stbi_write_jpg(filename, width, height, channels, rawdata, 100);
}

STBIMG_API I4 STBIMG_Save_TGA(char const *filename, I4 height, I4 width, I4 channels, I1 *rawdata) {
    return stbi_write_tga(filename, width, height, channels, rawdata);
}

STBIMG_API U1 *STBIMG_Save_PNG_Mem(I4 height, I4 width, I4 channels, U1 *rawdata, I4 *out_len) {
    return stbi_write_png_to_mem(rawdata, channels*width*sizeof(U1), width, height, channels, out_len);
}

// https://stackoverflow.com/a/41094722
static I4 Base64_Encode(U1 const *mem, I4 len, U1 *out, I4 nchars) {
    static U1 const charset[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    if (nchars<len) {return 0;}

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
    return(I4)(nchars==pos-out);
}

STBIMG_API I4 STBIMG_Encode_64(U1 *mem, I4 len, U1 *out, I4 nchars) {
    I4 const r = Base64_Encode(mem, len, out, nchars);
    if (mem!=NULL) {STBIW_FREE(mem);}
    return r;
}

STBIMG_API I4 STBIMG_Resize_I1(
    I1 *input,  I4 in_height,  I4 in_width, 
    I1 *output, I4 out_height, I4 out_width, I4 channels
) {
    U1 *r = stbir_resize_uint8_srgb(
        (U1 *)input,  in_width,  in_height,  0, 
        (U1 *)output, out_width, out_height, 0,
        (stbir_pixel_layout)channels
    );
    if (!r) {return 0;}
    return 1;
}

