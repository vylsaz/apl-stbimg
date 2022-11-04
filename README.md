# apl-stbimg
Save and load image in Dyalog APL. Based on [stb_image](https://github.com/nothings/stb).

![example](image/mandelbrot.png)

## Build
- (Optional) Get the newest `stb_image.h` and `stb_image_write.h` files from the [stb](https://github.com/nothings/stb) repository.
- Build the shared library

  On Window using MSYS2:  
  ```
  gcc stbimg.c -Wall -Wextra -pedantic -O3 -march=native -static -shared -o stbimg.dll
  ```
  (I heard that `-static -shared` is Windows-only.)
  
  Put the shared library somewhere on the `PATH`.

- (Optional) Load the class script (`stbimg.dyalog`) into a `clear WS` and save it as a workspace `stbimg.dws` on the workspace search path. (Required by `mandelbrot.dyalog`)

## Usage
The namespace/class stbimg is in `stbimg.dyalog`.

```⎕IO←0```  

The "\*Norm" variants of functions expect color to be 0-1 floating point numbers. The "\*Lin" variants are their linear version.  
Otherwise, color is in 0-255 integer value.

```apl
R←{X} stbimg.Load Y
R←{X} stbimg.LoadLin Y
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
R is a vector of matrices representing colors. Length of R equals to the number of channels. Thus if X is present, `X≡≢R`.  
The shape of matrices in R equals to `height,width` of the image.

```apl
R←stbimg.FromLin Y
R←stbimg.FromNorm Y
```
Y is either a simple matrix for greyscale, or a vector of matrices.  
R is the corresponding 0-255 integer values.

```apl
X←X stbimg.Save Y
```
Y is either a simple matrix for greyscale, or a vector of matrices. `≢⊆X` is the number of channels of the resulting image.  
X is the path. Currently, the supported extensions are .png, .bmp, .jpg (or .jpeg) and .tga.

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
stbimg.Disp Y
stbimg.DispHTML Y
```
Y is either a simple matrix for greyscale, or a vector of matrices. `≢⊆X` is the number of channels of the resulting image. The alpha channel is ignored.  
The image is displayed on a window implemented in Dyalog GUI object "form" or (for DispHTML) "HTMLRenderer".

```apl
stbimg.Show Y
stbimg.ShowHTML Y
```
Y is the path of a file whose format is jpg, bmp or png.  
The image is displayed on a window implemented in Dyalog GUI object "form" or (for ShowHTML) "HTMLRenderer".

## Example
See `mandelbrot.dyalog`. (A dialog about network access might show up -- that is due to `isolate`.)

## License
`stbimg.c`, `stbimg.dyalog` and `mandelbrot.dyalog` are under MIT license.

`stb_image.h` and `stb_image_write.h` are in the public domain.

WIP
