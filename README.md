# apl-stbimg
Save and load image in Dyalog APL. Based on [stb_image](https://github.com/nothings/stb).

![example](image/mandelbrot.png)

## Build
- Build the shared library

  On Window using MSYS2:
  ```
  gcc stbimg.c -Wall -Wextra -pedantic -O3 -march=native -static -shared -o stbimg.dll
  ```
  Put the shared library somewhere on the `PATH`.

- (Optional) load the namespace script (`stbimg.dyalog`) into a `clear WS` and save it as a workspace `stbimg.dws` on the workspace search path. (Required by `mandelbrot.dyalog`)

## Usage
The namespace is in `stbimg.dyalog`.

```⎕IO←0``` implied.  
The "\*Norm" variants of functions expect color to be 0-1 floating point numbers.  
Otherwise, color is in 0-255 integer value.

```apl
R←{X} stbimg.Load Y
R←{X} stbimg.LoadNorm Y
```
Y is the path of a file whose format is [supported by stb_image](https://github.com/nothings/stb/blob/master/stb_image.h#L19).  
X, if present, is one of 1, 2, 3 or 4. It represents the number of color channels.  
| number of channels | description |
| --- | --- |
| 1 | greyscale |
| 2 | greyscale and alpha |
| 3 | rgb |
| 4 | rgb and alpha |

If X is not present, the number of channels is decided by the image.  
R is a vector of matrices. Length of R equals to X if X is present.  
The shape of matrices in R equals to `height,width` of the image.

```apl
X←X stbimg.Save Y
X←X stbimg.SaveNorm Y
```
Y is either a simple matrix for greyscale, or a vector of matrices. `≢⊆X` is the number of channels of the resulting image.  
X is the path. Currently, the supported extensions are .png, .bmp, .jpg (or .jpeg) and .tga.

```apl
stbimg.Disp Y
stbimg.DispNorm Y
```
Y is either a simple matrix for greyscale, or a vector of matrices. `≢⊆X` is the number of channels of the resulting image. The alpha channel is ignored.  
The image is displayed on a window implemented in Dyalog GUI object.

```apl
R←stbimg.Info Y
```
Y is the path of a file whose format is supported by stb_image.  
R is a length 4 vector.  
| R\[\] | description |
| --- | --- |
| R\[0\] | 1 if the file is read successfully. If R\[0\] is 0, the rest of R is invalid. |
| R\[1\] | the width of the image. |
| R\[2\] | the height of the image. |
| R\[3\] | the number of channels (one of 1, 2, 3 or 4). Refer to the previous section of `stbimg.Load`. |

```apl
stbimg.Show Y
```
Y is the path of a file whose format is jpg, bmp or png.  
The image is displayed on a window implemented in Dyalog GUI object.

## Example
See `mandelbrot.dyalog`. (A dialog about network access might show up -- that is due to `isolate`.)

## License
`stbimg.c`, `stbimg.dyalog` and `mandelbrot.dyalog` are under MIT license.

`stb_image.h` and `stb_image_write.h` are in public domain.

WIP
