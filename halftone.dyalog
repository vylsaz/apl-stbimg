:Namespace halftone
  ⎕IO ⎕ML←0 1
  ⎕CY'stbimg'

  ⍝ stbimg can't save 1-bit images, only 8 bits per channel.
  ⍝ still, it should be fun to look at.

  ToLuminance←{
    ⍝ ⍵ ←→ normalized r g b
    ⍝ r ←→ normalized luminance/grayscale
    ⍝ height width ≡ ⍴r
    ⊃0.299 0.587 0.114+.×⍵
  }

  ∇ r←(weight _ErrorDiffusion_ coords) img;len;shp;o;i;p;e;n;m
    r←,img ⋄ len←≢r
    shp←⍴img
    o←(shp⊥⊢)¨coords
    :For i :In ⍳len       ⍝ this is a very imperative algorithm.
      p←r[i]
      r[i]←p>0.5          ⍝ apply threshold
      e←p-r[i]            ⍝ quantization error
      n←i+o               ⍝ neighbours
      m←n<len             ⍝ valid neighbours
      r[m/n]+←e×m/weight  ⍝ distribute error to neighbours
    :EndFor
    r←shp⍴r
  ∇

  Jarvis←{
    weight←(⊢÷+/)7 5 3 5 7 5 3 1 3 5 3 1
    coords←3↓,-∘0 2¨⍳3 5
    (weight _ErrorDiffusion_ coords)⍵
  }

  Floyd_Steinberg←{
    weight←(⊢÷+/)7 3 5 1
    coords←2↓,-∘0 1¨⍳2 3
    (weight _ErrorDiffusion_ coords)⍵
  }

  ⍝ https://beyondloom.com/blog/dither.html
  Atkinson←{
    weight←8÷⍨6⍴1
    coords←(0 1)(0 2)(1 ¯1)(1 0)(1 1)(2 0)
    (weight _ErrorDiffusion_ coords)⍵
  }

  RandomDither←{
    w←(⍺,⍨-⍺)(16808⌶)'Uniform'(⍴⍵)
    0.5<w+⍵
  }

  LowPass←{
    k←9÷⍨3 3⍴1
    k+.×⍨⍥(,⍤2)({⍵}⌺3 3)⍵
  }

  Bayer←{
    b←2 2⍴0 2 3 1
    ⍵≡0:b
    ,[0 1],[2 3]0 2 1 3⍉b∘.+4×∇⍵-1 ⍝ a generalized Kronecker product
    ⍝ - outer product but with rank of the left argument
  }

  _orderedDither←{
    p←(1∘+÷×/∘⍴) ⍺⍺ ⍺    ⍝ pre-calculated weight
    (ph pw)←⍴p
    (ih iw)←⍴⍵
    1<⍵+p[ph|⍳ih;pw|⍳iw] ⍝ wrapped indexing, then apply threshold
  }

  ∇ Demo;P;g;i;n;y;r;h
    ⍝ please load it manually, I don't know how to make it work.
    :If 0=⎕NC'#.HttpCommand'
      ('Please',(⎕UCS 13),'      ]load HttpCommand')⎕SIGNAL 6
    :EndIf
    P←{'<p>',⍵,'</p>'}
    h←'<title>demo</title>'
    ⎕←g←#.HttpCommand.Get'https://upload.wikimedia.org/wikipedia/en/7/7d/Lenna_%28test_image%29.png'
    
    i←stbimg.(rgb LoadMem⊢)g.Data
    h,←P ⎕←'original'
    h,←stbimg.EmitHTML i
    
    n←stbimg.ToNorm i
    y←ToLuminance n

    ⍝ faster, but looks not that good
    r←0.1 RandomDither y
    h,←P ⎕←'random dither'
    h,←stbimg.(EmitHTML∘FromNorm)r
    
    ⍝ uses Bayer matrix
    r←2 (Bayer _orderedDither) y
    h,←P ⎕←'ordered dither'
    h,←stbimg.(EmitHTML∘FromNorm)r
     
    ⍝ it's too slow for larger images...    
    r←Atkinson y
    h,←P ⎕←'error diffusion (grayscale)'
    h,←stbimg.(EmitHTML∘FromNorm)r
     
    ⍝ we can generalize this to all three channels
    r←Floyd_Steinberg¨n
    h,←P ⎕←'error diffusion (rgb)'
    h,←stbimg.(EmitHTML∘FromNorm)r
     
    ⍝ what if we filter out the noisy parts?
    ⍝ i.e. take the average in a window
    ⍝ this is how halftoning works, because
    ⍝ human eyes act like a low pass filter
    h,←P ⎕←'low pass filter'
    h,←stbimg.(EmitHTML∘FromNorm)LowPass¨r
   
    'hr'⎕WC'HTMLRenderer'h
  ∇
:EndNamespace
