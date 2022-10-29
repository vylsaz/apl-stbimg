:Namespace stbimg
    ⎕IO ⎕ML←0 1
    :Namespace _C
        Assoc←{
            3=⎕NC ⍺:⍺
            r p←⍵ ⋄ call←r,' stbimg|',⍺,' ',p
            ⎕NA call
        }
        _call_←{(⍎⍺⍺ Assoc ⍵⍵)⍵} 
    :EndNamespace
    grey grey_alpha rgb rgb_alpha rgba←1 2 3 4 4
    Info←{
        0≡0 2∊⍨10|⎕DR ⍵:'Not a file name'⎕SIGNAL 11
        ('STBIMG_Info'_C._call_'I4' '<0UTF8[] >I4 >I4 >I4')⍵ 0 0 0
    }
    Load←{
        s w h c←Info ⍵
        ⍺←c 
        s≡0:('Failed to load file ',⍵)⎕SIGNAL 22 
        ~0=⍴⍴⍺:'⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
        ~⍺∊1 2 3 4:'⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
        len←h×w×⍺
        type←'' '<0UTF8[] I4 >U1[]'
        raw←('STBIMG_Load_Raw'_C._call_ type)⍵ ⍺ len
        ⊂⍤¯1⊢1 2 0⍉h w ⍺⍴raw
    }
    Save←{
        rslt←⍺{
            type←'I4' '<0UTF8[] I4 I4 I4 <U1[]'
            Fpng←'STBIMG_Save_PNG_Raw'
            Fbmp←'STBIMG_Save_BMP_Raw'
            Fjpg←'STBIMG_Save_JPG_Raw'
            Ftga←'STBIMG_Save_TGA_Raw'
            Ext←{{1↓⍵/⍨∨\⌽<\⌽⍵='.'}1↓(⊢↓⍨'\/'∊⍨⊃)⍵/⍨∨\⌽<\⌽(1↑⍨≢⍵)∨'\/'∊⍨⍵}
            x←¯1⎕C Ext ⍺
            Raw←{,1 3 0 2⍉,[¯0.5]⍵}
            y←↑,⊆⍵ ⋄ r←Raw y ⋄ c h w←⍴y  
            x≡'png':(Fpng _C._call_ type)⍺ w h c r
            x≡'bmp':(Fbmp _C._call_ type)⍺ w h c r 
            (x≡'jpg')∨x≡'jpeg':(Fjpg _C._call_ type)⍺ w h c r
            x≡'tga':(Ftga _C._call_ type)⍺ w h c r 
            ('File extension ',x,' is not supported')⎕SIGNAL 11
        }⍵
        rslt≡0:('Failed to save file ',⍺)⎕SIGNAL 22
        ⍺
    }
    ∇ Show name;s;w;h;c;big;small;ratio
        big←1280 720 ⋄ small←400 400
        s w h c←Info name
        {⍵≡0:⎕SIGNAL 11}s   
        :If ∨/w h>big
            ratio←⌊/big÷w h
            w h←⌊w h×ratio 
        :ElseIf ∨/w h<small 
            ratio←⌈/small÷w h
            w h←⌊w h×ratio 
        :Endif 
        'F'⎕WC'Form'('Coord' 'RealPixel')('Size'(h,w))
        'F.B'⎕WC'Bitmap'('File' name)
        'F.I'⎕WC'Image'(0 0)('Picture' 'F.B')('Size'(h,w))
    ∇ 
    ∇ Disp data;pixels;w;h;big;small;ratio
        big←1280 720 ⋄ small←400 400
        pixels←256⊥↑3⍴(⊢↓⍨∘-2≡≢)⊆data
        h w←⍴pixels
        :If ∨/w h>big
            ratio←⌊/big÷w h
            w h←⌊w h×ratio 
        :ElseIf ∨/w h<small 
            ratio←⌈/small÷w h
            w h←⌊w h×ratio 
        :Endif 
        'F'⎕WC'Form'('Coord' 'RealPixel')('Size'(h,w))
        'F.B'⎕WC'Bitmap'('CBits' pixels)
        'F.I'⎕WC'Image'(0 0)('Picture' 'F.B')('Size'(h,w))
    ∇
    LoadNorm←{
        s w h c←Info ⍵
        ⍺←c 
        s≡0:('Failed to load file ',⍵)⎕SIGNAL 22
        ~0=⍴⍴⍺:'⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
        ~⍺∊1 2 3 4:'⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
        len←h×w×⍺
        type←'' '<0UTF8[] I4 >F4[]'
        raw←('STBIMG_Load_Norm_Raw'_C._call_ type)⍵ ⍺ len
        ⊂⍤¯1⊢1 2 0⍉h w ⍺⍴raw
    }
    SaveNorm←{ 
        0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
        ⍺ Save ⌊255×⍵
    }
    ∇ DispNorm data
        Disp ⌊255×data
    ∇
:EndNamespace
