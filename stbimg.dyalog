:Class stbimg
  ⎕IO ⎕ML←0 1
  :Field Public Shared grey←1
  :Field Public Shared grey_alpha←2
  :Field Public Shared rgb←3
  :Field Public Shared rgb_alpha←4
  :Field Public Shared rgba←4
  
  :Field Private Shared ReadOnly gamma←2.2   
  :Field Private Shared call_ns←⎕NS''
     
  ∇ rslt←(func _Call_ type) args;r;p;call
    :Access Private Shared      
    :If 3≠call_ns.⎕NC func 
      r p←type
      call←r,' stbimg|',func,' ',p
      call_ns.⎕NA call
    :EndIf 
    rslt←(call_ns.⍎func)args      
  ∇ 
  
  ∇ info←Info name
    :Access Public Shared
    :If 0≡0 2∊⍨10|⎕DR name ⋄ 'Not a file name'⎕SIGNAL 11 ⋄ :EndIf
    info←('STBIMG_Info'_Call_'I4' '<0UTF8[] >I4 >I4 >I4')name 0 0 0
  ∇    

  ∇ data←info (data_type _Load) name;s;w;h;ch;sh;len;type;func
    :Access Private Shared
    s w h ch←info
    :If s≡0 ⋄ ('Failed to load file ',name)⎕SIGNAL 22 ⋄ :EndIf
    :If ~0=⍴⍴ch
    :OrIf ~ch∊1 2 3 4
      '⍺ (# of components) must be one of 1, 2, 3, 4'⎕SIGNAL 11
    :EndIf                          
    
    sh←h w ch ⋄ len←×/sh
    type←''('<0UTF8[] I4 >',data_type,'[]')                         
    func←'STBIMG_Load_',data_type
    data←(func _Call_ type)name ch len
    data←⊂⍤¯1⊢1 2 0⍉sh⍴data
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
  
  ∇ data_255←FromLin data_lin
    :Access Public Shared 
    data_255←⌊0.5+255×data_lin*÷gamma
  ∇ 
  
  ∇ data_255←FromNorm data_norm
    :Access Public Shared
    data_255←⌊255×data_norm
  ∇

  ∇ name←name Save data;type;Ext;x;Raw;y;r;c;h;w;rslt
    :Access Public Shared                 
    type←'I4' '<0UTF8[] I4 I4 I4 <U1[]'
    Ext←{1↓2⊃1⎕NPARTS⍵}
    x←¯1⎕C Ext name
    
    Raw←{,1 3 0 2⍉,[¯0.5]⍵}
    y←↑,⊆data ⋄ r←Raw y ⋄ c h w←⍴y  
    
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
    'F'⎕WC'Form'('Coord' 'RealPixel')('Size'(h,w))
    'F.B'⎕WC'Bitmap'('CBits' pixels)
    'F.I'⎕WC'Image'(0 0)('Picture' 'F.B')('Size'(h,w))
  ∇            

  ∇ Show name;s;w;h;c 
    :Access Public Shared
    big←1280 720 ⋄ small←400 400
    s w h c←Info name
    :If s≡0 ⋄ ('Failed to load file ',name)⎕SIGNAL 22 ⋄ :EndIf 
    w h←Squeeze h w 
    'F'⎕WC'Form'('Coord' 'RealPixel')('Size'(h,w))
    'F.B'⎕WC'Bitmap'('File' name)
    'F.I'⎕WC'Image'(0 0)('Picture' 'F.B')('Size'(h,w))
  ∇        
  
  ∇ DispHTML data;Raw;y;r;c;h;w;type;ptr;len;ok;enc;URI;style;img;HTML
    :Access Public Shared 
    Raw←{,1 3 0 2⍉,[¯0.5]⍵}
    y←↑,⊆data ⋄ r←Raw y ⋄ c h w←⍴y  

    type←'P' 'I4 I4 I4 <U1[] >I4'
    ptr len←('STBIMG_Base64_PNG'_Call_ type)w h c r 0
    
    type←'I4' 'P I4 >UTF8[]'
    ok enc←('STBIMG_Copy_UTF8'_Call_ type)ptr len len
    :If ~ok ⋄ 'Failed to encode image'⎕SIGNAL 6 ⋄ :EndIf
    
    URI←'data:image/png;base64,',enc
    style←,'max-height:1280px; max-width:720px;'
    style,←' min-height:400px; min-width:400px;'
    img←'<img style="',style,'" src="',URI,'">'
    HTML←'<html><body>',img,'</body></html>'
    'HR'⎕WC'HTMLRenderer' HTML
  ∇   

  ∇ ShowHTML name;URL
    :Access Public Shared   
    URL←'URL'(⊃,/1 ⎕NPARTS name)
    'HR'⎕WC'HTMLRenderer' URL
  ∇
:EndClass


