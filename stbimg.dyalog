:Class stbimg
  ⎕IO ⎕ML←0 1
  :Field Public Shared ReadOnly Y←1
  :Field Public Shared ReadOnly YA←2
  :Field Public Shared ReadOnly RGB←3
  :Field Public Shared ReadOnly RGBA←4
  :Field Public Shared ReadOnly GRAY←1
  :Field Public Shared ReadOnly GRAY_ALPHA←2
  :Field Public Shared ReadOnly RGB_ALPHA←4 

  GetExt←{
    mac win←∨/¨'Mac' 'Windows'⍷¨⊂⊃'.'⎕WG'APLVersion'
    ⍵,'' '.so' '.dylib'⊃⍨mac+~win
  }
  :Field Private Shared ReadOnly LIB←GetExt 'stbimg'
  :Field Private Shared call_ns←⎕NS''
     
  ∇ rslt←(func _Call_ type) args;r;p;call
    :Access Private Shared      
    :If 3≠call_ns.⎕NC func 
      (r p)←type
      call←r,' ',LIB,'|',func,' ',p
      call_ns.⎕NA call
    :EndIf 
    rslt←(call_ns.⍎func)args      
  ∇ 
  
  ∇ info←Info name
    :Access Public Shared
    :If 0≡0 2∊⍨10|⎕DR name ⋄ 'Not a file name'⎕SIGNAL 11 ⋄ :EndIf
    info←('STBIMG_Info'_Call_'I4' '<0UTF8[] >I4 >I4 >I4')name 0 0 0
  ∇

  ∇ data←info (data_type _Load) name;ok;h;w;ch;len;type;func
    :Access Private Shared
    (ok h w ch)←info
    :If ~ok ⋄ ('Failed to load file ',name)⎕SIGNAL 22 ⋄ :EndIf
    :If ~0=⍴⍴ch
    :OrIf ~ch∊1 2 3 4
      '# of channels must be 1, 2, 3 or 4'⎕SIGNAL 11
    :EndIf                          
    
    len←h×w×ch
    type←''('<0UTF8[] I4 >',data_type,'[]')                         
    func←'STBIMG_Load_',data_type
    data←h w ch⍴(func _Call_ type)name ch len
  ∇
  
  ∇ data←{ch} Load name;ok;h;w;n
    :Access Public Shared
    (ok h w n)←Info name
    :If 0=⎕NC'ch' ⋄ ch←n ⋄ :EndIf
    data←ok h w ch('U1'_Load)name
  ∇

  ∇ data←{ch} LoadNorm name;ok;h;w;n
    :Access Public Shared
    (ok h w n)←Info name
    :If 0=⎕NC'ch' ⋄ ch←n ⋄ :EndIf
    data←65535÷⍨ok h w ch('U2'_Load)name
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

  ∇ data←{ch} LoadMem mem;len;ok;h;w;n;olen;type
    :Access Public Shared
    len←≢mem
    (ok h w n)←InfoMem mem
    :If 0=⎕NC'ch' ⋄ ch←n ⋄ :EndIf
    
    :If ~ok ⋄ ('Failed to load from buffer')⎕SIGNAL 22 ⋄ :EndIf
    :If ~0=⍴⍴ch
    :OrIf ~ch∊1 2 3 4
      '# of channels must be 1, 2, 3 or 4'⎕SIGNAL 11
    :EndIf

    olen←h×w×ch
    :If 80≡⎕DR mem
      type←'' '<C1[] I4 I4 >U1[]'
    :Else
      type←'' '<U1[] I4 I4 >U1[]'
    :EndIf
    data←h w ch⍴('STBIMG_Load_U1_Mem'_Call_ type)mem len ch olen
  ∇

  Shape←{
    r←≢⍴⍵
    r≡3:⍴⍵
    r≡2:1,⍨⍴⍵
    'Image data should be rank 2 or 3'⎕SIGNAL 11
  }

  ∇ name←name Save data;type;Ext;x;y;h;w;c;rslt
    :Access Public Shared                 
    type←'I4' '<0UTF8[] I4 I4 I4 <U1[]'
    Ext←{1↓2⊃1⎕NPARTS⍵}
    x←¯1⎕C Ext name
        
    y←,data ⋄ (h w c)←Shape data  
    :If ~c∊1 2 3 4
      '# of channels must be 1, 2, 3 or 4'⎕SIGNAL 11
    :EndIf  

    :Select ¯1⎕C x
    :Case 'png' 
      rslt←('STBIMG_Save_PNG'_Call_ type)name h w c y
    :Case 'bmp'
      rslt←('STBIMG_Save_BMP'_Call_ type)name h w c y 
    :CaseList 'jpg' 'jpeg'
      rslt←('STBIMG_Save_JPG'_Call_ type)name h w c y
    :Case 'tga'
      rslt←('STBIMG_Save_TGA'_Call_ type)name h w c y 
    :Else  
      ('File extension ',x,' is not supported')⎕SIGNAL 11
    :EndSelect
    :If rslt≡0 ⋄ 
    ('Failed to save file ',name)⎕SIGNAL 22 ⋄ 
    :EndIf
  ∇

  PrivResize←{
    (oh ow)←⍺ 
    (ih iw c)←Shape ⍵
    olen←oh×ow×c
    y←,⍵

    type←'I4' '<U1[] I4 I4 >U1[] I4 I4 I4'
    (ok output)←('STBIMG_Resize_U1'_Call_ type)y ih iw olen oh ow c
    
    ~ok:'Failed to resize'⎕SIGNAL 11
    oh ow c⍴output
  }

  ∇ output←size Resize input
    :Access Public Shared
    output←size PrivResize input
  ∇
  
  ∇ output←ratio Scale input;size
    :Access Public Shared
    size←⌊ratio×¯1↓⍴input
    output←size PrivResize input 
  ∇

  :Field Private Shared ReadOnly UPPER_LIMIT←720 1280
  :Field Private Shared ReadOnly LOWER_LIMIT←400 400
  
  ⍝ size: (height,width)
  ∇ r←Squeeze size
    :Access Private Shared
    r←size
    :If ∨/size>UPPER_LIMIT
      r←⌊size×⌊/UPPER_LIMIT÷size 
    :ElseIf ∨/size<LOWER_LIMIT 
      r←⌊size×⌈/LOWER_LIMIT÷size 
    :Endif
  ∇ 

  ∇ {r}←{hd} Disp data;pixels;size
    :Access Public Shared
    :If 0=⎕NC'hd' ⋄ hd←'∆f' ⋄ :EndIf
    pixels←((256⊥3⍴⊢)⍤1)(Shape⍴⊢)data
    size←Squeeze ⍴ pixels
    r←hd ⎕WC'Form'('Caption' 'Disp')('Coord' 'RealPixel')('Size'size)
    (hd,'.bit')⎕WC'Bitmap'('CBits'pixels)
    (hd,'.img')⎕WC'Image'(0 0)('Picture'(hd,'.bit'))('Size'size)
  ∇

  ∇ {r}←{hd} Show name;ok;h;w;c;size 
    :Access Public Shared
    :If 0=⎕NC'hd' ⋄ hd←'∆f' ⋄ :EndIf
    (ok h w c)←Info name
    :If ~ok ⋄ ('Failed to load file ',name)⎕SIGNAL 22 ⋄ :EndIf 
    size←Squeeze h w 
    r←hd ⎕WC'Form'('Caption'name)('Coord' 'RealPixel')('Size'size)
    (hd,'.bit')⎕WC'Bitmap'('File'name)
    (hd,'.img')⎕WC'Image'(0 0)('Picture'(hd,'.bit'))('Size'size)
  ∇
     
  ∇ HTML←EmitHTML data;y;h;w;c;type;ptr;len;nchars;ok;enc;URI
    :Access Public Shared 
    
    y←,data ⋄ (h w c)←Shape data 
    :If ~c∊1 2 3 4
      '# of channels must be 1, 2, 3 or 4'⎕SIGNAL 11
    :EndIf

    type←'P' 'I4 I4 I4 <U1[] >I4'
    (ptr len)←('STBIMG_Save_PNG_Mem'_Call_ type)h w c y 0
    
    nchars←4×⌊3÷⍨2+len
    type←'I4' 'P I4 >UTF8[] I4'
    (ok enc)←('STBIMG_Encode_64'_Call_ type)ptr len nchars nchars
    :If ~ok ⋄ 'Failed to encode image'⎕SIGNAL 6 ⋄ :EndIf
    
    URI←'data:image/png;base64,',enc
    HTML←'<img src="',URI,'" />'
  ∇   

  ⍝ Note: multiple HTMLRenderers behave weird without &

  ∇ {r}←{hd} DispHTML data;size;HR
    :Access Public Shared 
    :If 0=⎕NC'hd' ⋄ hd←'∆hr' ⋄ :EndIf
    size←Squeeze ¯1↓Shape data
    size+←16 0 ⍝ margin
    HR←⎕TSYNC{
      x←'<!DOCTYPE html><html><head><title>DispHTML</title><style>'
      x,←'img{image-rendering:pixelated;width:100%;height:100%;}'
      x,←'</style></head><body>',(EmitHTML ⍵),'</body></html>'
      ⍺ ⎕WC'HTMLRenderer'('Coord' 'RealPixel')('Size'size)('HTML'x)  
    }&
    r←hd HR data
  ∇

  ∇ {r}←{hd} ShowHTML name;HR
    :Access Public Shared 
    :If 0=⎕NC'hd' ⋄ hd←'∆hr' ⋄ :EndIf
    HR←⎕TSYNC{
      ⍺ ⎕WC'HTMLRenderer'('URL'('file:///',⊃,/1 ⎕NPARTS ⍵))
    }&
    r←hd HR name
  ∇

  ∇ byte←ByteFromNorm norm
    :Access Public Shared
    byte←⌊255×norm
  ∇

  ∇ norm←NormFromByte byte
    :Access Public Shared
    norm←byte÷255
  ∇

  ∇ chan←ChanFromGrid grid
    :Access Public Shared
    chan←(⊂⍤¯1)1 2 0⍉(Shape⍴⊢)grid
  ∇

  ∇ grid←GridFromChan chan
    :Access Public Shared
    grid←2 0 1⍉↑chan
  ∇

:EndClass
