:Namespace mandelbrot
⍝ usage: mandelbrot.('filepath'Show Calc width,height)
  ⎕IO ⎕ML←0 1  
  ⎕CY'stbimg' ⍝ requires a workspace
  #.('DRC'⎕CY'conga')
  #.⎕CY'isolate'           
  #.isolate.ynys.isoStart ⍬          
  ⍝ https://www.dyalog.com/blog/2014/08/isolated-mandelbrot-set-explorer/
  ∇ r←iter Mand right
    ;iter;w;h;l;b;dl;db;dom;clr;idc;cnt;zed;esc;pal
    w h dl db l b←right
    dom←,(⌽¯11○b+db×⍳h)∘.+l+dl×⍳w
    clr←{0}¨dom
    idc←⍳≢clr
    zed←{0}¨dom
    :For cnt :In ⍳iter
      esc←2<|zed
      clr[esc/idc]←cnt
      idc←idc/⍨~esc
      :If 0∊⍴idc ⋄ :Leave ⋄ :EndIf
      zed←dom[idc]+×⍨zed/⍨~esc
    :EndFor            
    clr[idc]←iter        
    r←iter÷⍨clr
  ∇ 
  _Calc_←{
    _←#.isolate.Reset 0
    p←#.isolate.Config 'processors' 
    w h←⍵ 
    (l b)(r t)←9 11∘○¨⍺⍺ ⍵⍵
    dl db←w h÷⍨r t-l b 
    rows←p{¯2-/⌈⍵,⍨(⍳⍺)×⍵÷⍺}h
    buts←b+db×1↓⌽0,+\rows
    args←↓w,rows,dl,db,l,⍪buts
    h w⍴∊⍺ Mand#.isolate.llEach args
  } 
  Calc←{⍺←32
    ⍝ ⍺←iterations
    ⍝ ⍵←width,height
    ⍝ r←matrix of ratio ⋄ (⍴r)≡height,width
    ⍺(¯2j¯1 _Calc_ 1j1)⍵
  }
  Show←{                  
    stbimg.(Show ⍺ SaveNorm 1-⍵)
  }
:EndNamespace


