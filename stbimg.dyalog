:Class stbimg
  ⎕IO ⎕ML←0 1
  :Field Public Shared ReadOnly grey←1
  :Field Public Shared ReadOnly grey_alpha←2
  :Field Public Shared ReadOnly rgb←3
  :Field Public Shared ReadOnly rgb_alpha←4
  :Field Public Shared ReadOnly rgba←4
  
  :Field Private Shared ReadOnly shared_lib←'stbimg'
  :Field Private Shared ReadOnly gamma←2.2   
  :Field Private Shared call_ns←⎕NS''
     
  ∇ rslt←(func _Call_ type) args;r;p;call
    :Access Private Shared      
    :If 3≠call_ns.⎕NC func 
      r p←type
      call←r,' ',shared_lib,'|',func,' ',p
      call_ns.⎕NA call
    :EndIf 
    rslt←(call_ns.⍎func)args      
  ∇ 
  
  ∇ info←Info name
    :Access Public Shared
    :If 0≡0 2∊⍨10|⎕DR name ⋄ 'Not a file name'⎕SIGNAL 11 ⋄ :EndIf
    info←('STBIMG_Info'_Call_'I4' '<0UTF8[] >I4 >I4 >I4')name 0 0 0
  ∇ 

  Raw←{,1 3 0 2⍉,[¯0.5]⍵}
  Pack←{1 2 0⍉⍺[1 2 0]⍴⍵}

  ∇ data←info (data_type _Load) name;s;w;h;ch;len;type;func
    :Access Private Shared
    s w h ch←info
    :If s≡0 ⋄ ('Failed to load file ',name)⎕SIGNAL 22 ⋄ :EndIf
    :If ~0=⍴⍴ch
    :OrIf ~ch∊1 2 3 4
      '⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
    :EndIf                          
    
    len←ch×h×w
    type←''('<0UTF8[] I4 >',data_type,'[]')                         
    func←'STBIMG_Load_',data_type
    data←(func _Call_ type)name ch len
    data←(⊂⍤¯1)ch h w Pack data
  ∇ 
  
  ∇ data←{ch} Load name;s;w;h;n
    :Access Public Shared
    s w h n←Info name
    :If 0=⎕NC'ch' ⋄ ch←n ⋄ :EndIf
    data←s w h ch('U1'_Load)name
  ∇

  ∇ data←{ch} LoadLin name;s;w;h;n
    :Access Public Shared
    s w h n←Info name
    :If 0=⎕NC'ch' ⋄ ch←n ⋄ :EndIf
    data←s w h ch('F4'_Load)name
  ∇

  ∇ data←{ch} LoadNorm name;s;w;h;n
    :Access Public Shared
    s w h n←Info name
    :If 0=⎕NC'ch' ⋄ ch←n ⋄ :EndIf
    data←65535÷⍨s w h ch('U2'_Load)name
  ∇ 

  ∇ info←InfoMem mem;len;type
    :Access Public Shared
    len←≢mem
    :If 80≡⎕DR mem
      type←'I4' '<C1[] I4 >I4 >I4 >I4'
    :Else
      type←'I4' '<U1[] I4 >I4 >I4 >I4'
    :EndIf
    info←('STBIMG_Info_Mem'_Call_ type)mem len 0 0 0
  ∇ 

  ∇ data←{ch} LoadMem mem;len;s;w;h;n;olen;type
    :Access Public Shared
    len←≢mem
    s w h n←InfoMem mem
    :If 0=⎕NC'ch' ⋄ ch←n ⋄ :EndIf
    
    :If s≡0 ⋄ ('Failed to load from buffer')⎕SIGNAL 22 ⋄ :EndIf
    :If ~0=⍴⍴ch
    :OrIf ~ch∊1 2 3 4
      '⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
    :EndIf  

    olen←ch×h×w
    :If 80≡⎕DR mem
      type←'' '<C1[] I4 I4 >U1[]'
    :Else
      type←'' '<U1[] I4 I4 >U1[]'
    :EndIf
    data←('STBIMG_Load_U1_Mem'_Call_ type)mem len ch olen
    data←(⊂⍤¯1)ch h w Pack data
  ∇

  ∇ name←name Save data;type;Ext;x;y;r;c;h;w;rslt
    :Access Public Shared                 
    type←'I4' '<0UTF8[] I4 I4 I4 <U1[]'
    Ext←{1↓2⊃1⎕NPARTS⍵}
    x←¯1⎕C Ext name
        
    y←↑,⊆data ⋄ r←Raw y ⋄ c h w←⍴y  
    :If ~c∊1 2 3 4
      '⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
    :EndIf  

    :Select ¯1⎕C x
    :Case 'png' 
      rslt←('STBIMG_Save_PNG'_Call_ type)name w h c r
    :Case 'bmp'
      rslt←('STBIMG_Save_BMP'_Call_ type)name w h c r 
    :CaseList 'jpg' 'jpeg'
      rslt←('STBIMG_Save_JPG'_Call_ type)name w h c r
    :Case 'tga'
      rslt←('STBIMG_Save_TGA'_Call_ type)name w h c r 
    :Else  
      ('File extension ',x,' is not supported')⎕SIGNAL 11
    :EndSelect
    :If rslt≡0 ⋄ 
    ('Failed to save file ',name)⎕SIGNAL 22 ⋄ 
    :EndIf
  ∇

  ∇ output←size Resize input;oh;ow;y;r;c;ih;iw;olen;type;ok
    :Access Public Shared
    oh ow←size
    y←↑,⊆input ⋄ r←Raw y ⋄ c ih iw←⍴y
    olen←c×oh×ow

    type←'I4' '<U1[] I4 I4 >U1[] I4 I4 I4'
    ok output←('STBIMG_Resize_U1'_Call_ type)r iw ih olen ow oh c
    :If ~ok ⋄ 'Failed to resize'⎕SIGNAL 11 ⋄ :EndIf
    output←(⊂⍤¯1)c oh ow Pack output
  ∇
  
  ∇ output←ratio Scale input;oh;ow;y;r;c;ih;iw;olen;type;ok
    :Access Public Shared
    y←↑,⊆input ⋄ r←Raw y ⋄ c ih iw←⍴y
    oh ow←⌊ratio×ih iw 
    olen←c×oh×ow

    type←'I4' '<U1[] I4 I4 >U1[] I4 I4 I4'
    ok output←('STBIMG_Resize_U1'_Call_ type)r iw ih olen ow oh c
    :If ~ok ⋄ 'Failed to resize'⎕SIGNAL 11 ⋄ :EndIf
    output←(⊂⍤¯1)c oh ow Pack output
  ∇
  
  ∇ r←Squeeze size;w;h;big;small
    :Access Private Shared
    h w←size
    big←1280 720 ⋄ small←400 400
    :If ∨/w h>big
      w h←⌊w h×⌊/big÷w h 
    :ElseIf ∨/w h<small 
      w h←⌊w h×⌈/small÷w h 
    :Endif 
    r←w h
  ∇           

  ∇ Disp data;pixels;w;h
    :Access Public Shared
    pixels←256⊥↑3⍴(⊢↓⍨∘-2≡≢)⊆data
    w h←Squeeze ⍴pixels
    '∆f'⎕WC'Form'('Caption' 'Disp')('Coord' 'RealPixel')('Size'(h,w))
    '∆f.bit'⎕WC'Bitmap'('CBits' pixels)
    '∆f.img'⎕WC'Image'(0 0)('Picture' '∆f.bit')('Size'(h,w))
  ∇            

  ∇ Show name;s;w;h;c 
    :Access Public Shared
    s w h c←Info name
    :If s≡0 ⋄ ('Failed to load file ',name)⎕SIGNAL 22 ⋄ :EndIf 
    w h←Squeeze h w 
    '∆f'⎕WC'Form'('Caption'name)('Coord' 'RealPixel')('Size'(h,w))
    '∆f.bit'⎕WC'Bitmap'('File' name)
    '∆f.img'⎕WC'Image'(0 0)('Picture' '∆f.bit')('Size'(h,w))
  ∇        
     
  ∇ HTML←{limit} EmitHTML data;y;r;c;h;w;type;ptr;len;nchars;ok;enc;URI;style 
    :Access Public Shared 
    :If 0=⎕NC'limit' ⋄ limit←0 ⋄ :EndIf
    
    y←↑,⊆data ⋄ r←Raw y ⋄ c h w←⍴y 
    :If ~c∊1 2 3 4
      '⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
    :EndIf

    type←'P' 'I4 I4 I4 <U1[] >I4'
    ptr len←('STBIMG_Save_PNG_Mem'_Call_ type)w h c r 0
    
    nchars←4×⌊3÷⍨2+len
    type←'I4' 'P I4 >UTF8[] I4'
    ok enc←('STBIMG_Encode_64'_Call_ type)ptr len nchars nchars
    :If ~ok ⋄ 'Failed to encode image'⎕SIGNAL 6 ⋄ :EndIf
    
    URI←'data:image/png;base64,',enc
    :If limit 
      style←'style=' 
      style,←'"max-height:1280px; max-width:720px;'
      style,←' min-height:400px; min-width:400px;" '
    :Else
      style←''
    :EndIf
    HTML←'<img ',style,'src="',URI,'" />'
  ∇   

  ∇ DispHTML data;HTML
    :Access Public Shared 
    HTML←'HTML'(1 EmitHTML data)
    '∆hr'⎕WC'HTMLRenderer' HTML ('Caption' 'DispHTML')
  ∇ 

  ∇ ShowHTML name;URL
    :Access Public Shared 
    URL←'URL'('file:///',⊃,/1 ⎕NPARTS name)
    '∆hr'⎕WC'HTMLRenderer' URL
  ∇

  ∇ data_255←FromNorm data_norm
    :Access Public Shared
    data_255←⌊255×data_norm
  ∇

  ∇ data_norm←ToNorm data_255
    :Access Public Shared
    data_norm←data_255÷255
  ∇

  ∇ r←gama GammaCorr data
    :Access Public Shared
    r←data*gama{ ⍝ don't apply gamma to alpha channel  
      c←{1=≡⍵:1 ⋄ ≢⍵}⍵
      c≡2:⍺,1
      c≡4:(3⍴⍺),1
      ⍺
    }data
  ∇

  ∇ data_norm←NormFromLin data_lin
    :Access Public Shared
    data_norm←(÷gamma) GammaCorr data_lin
  ∇

  ∇ data_lin←LinFromNorm data_norm
    :Access Public Shared
    data_lin←gamma GammaCorr data_norm
  ∇

  ∇ data_255←FromLin data_lin
    :Access Public Shared 
    data_255←FromNorm NormFromLin data_lin
  ∇ 
  
  ∇ data_lin←ToLin data_255
    :Access Public Shared
    data_lin←LinFromNorm ToNorm data_255
  ∇

:EndClass


