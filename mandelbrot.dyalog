:Namespace mandelbrot
⍝ usage: mandelbrot.('filepath'Show Calc width,height)
  ⎕IO ⎕ML←0 1  
  ⎕CY'stbimg' ⍝ requires a workspace
  #.('DRC'⎕CY'conga')
  #.⎕CY'isolate'           
  #.isolate.ynys.isoStart ⍬          
  ⍝ https://www.dyalog.com/blog/2014/08/isolated-mandelbrot-set-explorer/
  ∇ clr←iter Mand right;iter;w;h;l;b;dl;db;dom;idc;cnt;zed;esc;pal
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
  ⍝ https://github.com/rodrigogiraoserrao/fractals/blob/master/mapl/Palette.aplf
  Palette←{
    ⍝ Dumb-down of https://stackoverflow.com/a/25816111/2828287
    n ← ⌈⍵÷4
    Int ← {⌊⍺+⍤0 1⊢(⍵-⍺)∘.×n÷⍨⍳n}
    0,⍨⊃,/2 Int/(0 7 100)(66 107 203)(237 255 255)(255 170 0)(0 2 0)
  } 
  Calc←{⍺←32
    ⍝ ⍺←iterations
    ⍝ ⍵←width,height
    ⍝ r←matrix of ratio ⋄ (⍴r)≡height,width
    clr←⍺(¯2j¯1 _Calc_ 1j1)⍵
    pal←Palette ⍺
    pal[;clr]
  }
  Show←{   
    stbimg.(ShowHTML ⍺ Save ⊂⍤¯1⊢⍵)
  }
:EndNamespace


