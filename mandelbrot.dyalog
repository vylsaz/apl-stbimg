:Namespace mandelbrot
⍝ usage: mandelbrot.('filepath'Show Calc width,height)
  ⎕CY'stbimg' ⍝ requires a workspace
  #.('DRC'⎕CY'conga')
  #.⎕CY'isolate'           
  #.isolate.ynys.isoStart ⍬   
  ⎕IO ⎕ML←0 1
  Calc←{⍺←32 
    ⍝ ⍺←iterations
    ⍝ ⍵←width,height
    ⍝ r←matrix of ratio ⋄ (⍴r)≡height,width
    _←#.isolate.Reset 0
    p←#.isolate.Config 'processors' 
    dom←¯2J¯1{
      ⍺⍺+⊖⊃∘.{⍵+¯11○⍺}⍨/(⍳¨⍵)×⍵÷⍨-/¨9 11○⊂⍵⍵ ⍺⍺
    }1J1⊢⍵
    par←p{↓⍵⍴⍨⍺(⊣,⌈⍤÷⍨)≢,⍵}dom
    (⍴dom)⍴∊⍺{⍺÷⍨⍺{iter←⍺
      ⊃⍵{i z←⍵ ⋄ (1+i),⍺+×⍨z}⍣{i z←⍺ ⋄ (iter≤i)∨2<|z}0 0
    }¨⍵}#.isolate.llEach par
  }
  Show←{
    stbimg.(Show ⍺ SaveNorm 1-⍵)
  }
:EndNamespace

