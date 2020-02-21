turtles-own
[
  ranking
  paranoid?
  standard?
  p?
  notp?
  solveconf
  triangle?
]

globals
[
  change-count
  mtrust_prd_count
  mtrust_std_count
]

to setup
  clear-all
  set-default-shape turtles "circle"

  if (_network_type = "total")
  [
     create-turtles _nodes
     [
      initializeTurtle
      set ranking 0
     ]
     ask turtles [ create-links-with other turtles ]
     layout-circle turtles 13
  ]

  if (_network_type = "linear")
  [
    let maxTurtles _nodes
    let counter 0
    if (world-height * world-width < maxTurtles) [ set maxTurtles world-height * world-width ]
    let newX 0
    let newY world-height - 1
    create-turtles maxTurtles
    [
      initializeTurtle
      set ranking counter
      setxy newX newY
      set newX newX + 1
      if (newX = world-width)
      [
        set newX 0
        set newY newY - 1
      ]
      set counter counter + 1
    ]
    ask turtles
    [
      let r ranking
      create-links-with turtles with [ ranking = r - 1 ]
    ]
  ]


  if (_network_type = "random")
  [
    create-turtles _nodes [ initializeTurtle ]
    ;;draw network
    let total-edges round (count turtles)
    while [count turtles < total-edges]
    [
      ask one-of turtles
      [
        ask one-of other turtles [ create-link-with myself ]
      ]
    ]
    ;;ensure that there are no completely isolated checkpoints
    ask turtles with [count link-neighbors = 0]  [ create-link-with one-of other turtles ]
    layout-radial turtles links max-one-of turtles [count link-neighbors]

    ask turtles [ set ranking 1 / count link-neighbors ]
    ask turtles [ set size 2 - ranking ]
  ]

  if (_network_type = "small-world")
  [
    create-turtles 3 [ initializeTurtle ]
    ask turtle 0 [ create-link-with one-of other turtles ]
    ask one-of turtles with [count link-neighbors = 0] [ create-link-with one-of other turtles ]
    ;;add new node using albert-barabasi method
    while [count turtles < (_nodes + 1)]
    [
       create-turtles 1
       [
         initializeTurtle
         create-link-with find-partner
       ]
    ]
    ask turtles [ set ranking 1 / count link-neighbors ]
    ask turtles [ set size 2 - ranking ]
    layout-radial turtles links max-one-of turtles [count link-neighbors]
  ]

  if (_network_type != "total" and _network_type != "linear")
  [
    let factor 1.5 / ((max [count link-neighbors] of turtles) - (min [count link-neighbors] of turtles))
    ask turtles [ set size 0.5 + (count link-neighbors * factor) ]
  ]

set change-count 0
set  mtrust_prd_count 0
set mtrust_std_count 0
epistemic_attitudes
reset-ticks

end


to-report find-partner
  let total random-float sum [count link-neighbors] of turtles
  let partner nobody
  let q 0
  while [q < count turtles]
  [
    ask turtle q
    [
      let nc count link-neighbors
      ;; if there's no winner yet...
      if partner = nobody
      [
        ifelse nc > total [ set partner self ]
        [ set total total - nc ]
      ]
    ]
    set q q + 1
  ]
  report partner
end


to initializeTurtle
  setxy random-pxcor random-pycor
  set color blue
  set size 0.8
  set ranking who
  ;qui sotto  c'è il codice per distingure tra cerchio e triangolo come è nel suo paper. Visto che si basa su un operazione random
  ;l'ho sostituito con epistemic_attitudes
   ;if (random-float 0.12 <= proportion_paranoid / 100)
  ;[ set shape "triangle"
   ; set paranoid? true
  ;]
  end

to epistemic_attitudes
 let n_of_paranoid (proportion_paranoid * _nodes) / 100
  repeat  n_of_paranoid
  [
    ask one-of turtles with [triangle? = 0]
    [
     set shape "triangle"
     set paranoid? true
     set standard? false
     set triangle? true
    ]
  ]

  ask turtles with [ shape = "circle"]
  [
    set standard? true
    set paranoid? false
  ]
end


to maximize-minimize ; per avere sicuramente un minimo o massimo assuluto standard o paranoid
  if m_M_type = "standard_m"
  [
    ask one-of turtles with-min [ranking]
    [
     set shape "circle"
     set paranoid? false
     set standard? true
    ]
  ]
  if m_M_type = "paranoid_m"
  [
    ask one-of turtles with-min [ranking]
    [
     set shape "triangle"
     set paranoid? true
     set standard? false
    ]
  ]

   if m_M_type = "standard_M"
  [
    ask one-of turtles with-max [ranking]
    [
     set shape "circle"
     set paranoid? false
     set standard? true
    ]
  ]
  if m_M_type = "paranoid_M"
  [
    ask one-of turtles with-max [ranking]
    [
     set shape "triangle"
     set paranoid? true
     set standard? false
    ]
  ]

end


to discovery
  ; Ho un pò modificato i discovery. standard_min ricerca lo standard tra gli altri standard con il ranking più alto,
  ; per averlo assoluto c'è la procedura maximize-minimize (stesso discorso vale per le altre procedure)
  ; per avere le combinazioni che avevamo accordato basta scegliere uno alla volta i tipi di discovery
  if discovery_type = "paranoid_random"
  [
    ask one-of turtles with [paranoid? = true]
    [
     set color red
     set p? false
     set notp? true
    ]
   ]

  if discovery_type = "standard_random"
  [
    ask one-of turtles with [standard? = true]
    [
     set color green
     set p? true
     set notp? false
    ]
   ]

  if discovery_type = "standard_min"
  [
    let m turtles with [standard? = true]
    ask one-of m with-min [ranking]
    [
     set color green
     set p? true
     set notp? false
    ]
   ]

  if discovery_type = "paranoid_min"
  [
    let m turtles with [paranoid? = true]
    ask one-of m with-min [ranking]
    [
     set color red
     set p? false
     set notp? true
    ]
   ]

 if discovery_type = "standard_max"
  [
    let M turtles with [standard? = true]
    ask one-of M with-max [ranking]
    [
     set color green
     set p? true
     set notp? false
    ]
   ]

  if discovery_type = "paranoid_max"
   [
    let M turtles with [paranoid? = true]
    ask one-of M with-max [ranking]
    [
     set color red
     set p? false
     set notp? true
    ]
   ]

end


to partial_setup
  ask turtles
  [
    set color blue
    set p? 0
    set notp? 0
    set solveconf 0
    set change-count 0
    set mtrust_prd_count 0
    set mtrust_std_count 0
    set paranoid? false
    set standard? false
    if shape = "circle" [ set standard? true]
    if shape = "triangle" [ set paranoid? true]
   ]
  reset-ticks
end

to go

  transmission
  solveconflict
  tick
  if ticks mod stability-factor = 0
  [if change-count < 1 [stop] set change-count 0]

end


to transmission

  ask turtles with [paranoid? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking < [ranking] of myself) and ( p? = true) ]
    [mtrust_prd_p]
  ]

   ask turtles with [ paranoid? = true and p? = true and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking < [ranking] of myself) and (p? = true )]
    [mtrust_prd_p]
  ]

  ask turtles with [ paranoid? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking < [ranking] of myself) and ( notp? = true) ]
    [mtrust_prd_notp]
  ]

  ask turtles with [ paranoid? = true and  notp? = true and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking < [ranking] of myself) and (notp? = true) ]
    [mtrust_prd_notp]
  ]

  ask turtles with [ paranoid? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking >= [ranking] of myself) and (p? = true) ]
    [trust_p]
  ]

  ask turtles with [paranoid? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking >= [ranking] of myself) and (notp? = true)]
    [trust_notp]
  ]

  ask turtles with [standard? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking <= [ranking] of myself) and ( p? = true) ]
    [trust_p]
  ]

  ask turtles with [standard? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking <= [ranking] of myself) and ( notp? = true) ]
    [trust_notp]
  ]

  ask turtles with [standard? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking > [ranking] of myself) and ( p? = true) ]
    [trust_p]
  ]

  ask turtles with [ standard? = true and color = blue and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking > [ranking] of myself) and ( notp? = true) ]
    [trust_notp]
  ]

  ask turtles with [standard? = true and p? = true and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking <= [ranking] of myself) and (notp? = true) ]
    [mtrust_std_p]
  ]

  ask turtles with [standard? = true and notp? = true and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking <= [ranking] of myself) and ( p? = true) ]
    [mtrust_std_notp]
  ]


  ; I am in the middle of contradictory information?
  ask turtles  with [ paranoid? = true]
  [
    if any? link-neighbors with [ (ranking < [ranking] of myself) and ( notp? = true)]
    [
      if any? link-neighbors with [ (ranking < [ranking] of myself) and ( p? = true)]
       [set solveconf solveconf + 1 solveconflict]
  ]
  ]

  ask turtles  with [ standard? = true]
  [
    if any? link-neighbors with [ (ranking <= [ranking] of myself) and ( notp? = true)]
    [
      if any? link-neighbors with [ (ranking <= [ranking] of myself) and ( p? = true)]
       [set solveconf solveconf + 1 solveconflict]
  ]
  ]


  ; Caso in cui l'informazione contraddittoria proviene da due agenti con lo stesso ranking, ho deciso di non farlo più random
  ; visto che ho notato che capita frequentemente. Così come è ora lo standard accetta sempre p mentre il paranoico nonp.
  ;Se pensa che non sia una buona idea, torno a random.
  ask turtles with [paranoid? = true and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking < [ranking] of myself) and ( notp? = true)]
    [
      if any? link-neighbors with [ (ranking < [ranking] of myself) and ( p? = true)]
      [
        let m' link-neighbors with [ (ranking < [ranking] of myself) and ( p? = true)]
          let m link-neighbors with [(ranking < [ranking] of myself) and ( notp? = true)]
           if [ranking] of m' = [ranking] of m
            [
            set color red
            set p? false
            set notp? true
            set change-count change-count + 1
            set solveconf solveconf + 2
            ]
           ]
          ]
         ]


  ask turtles with [standard? = true and solveconf = 0]
  [
    if any? link-neighbors with [ (ranking <= [ranking] of myself) and ( notp? = true)]
    [
      if any? link-neighbors with [ (ranking <= [ranking] of myself) and ( p? = true)]
      [
      let m' link-neighbors with [ (ranking <= [ranking] of myself) and ( p? = true)]
      let m link-neighbors with [(ranking <= [ranking] of myself) and ( notp? = true)]
        if [ranking] of m' = [ranking] of m
         [
          set color green
          set p? true
          set notp? false
          set change-count change-count + 1
          set solveconf solveconf + 2
        ]
       ]
      ]
     ]

end




to solveconflict

  ; solveconflict for paranoid
  ask turtles with [solveconf = 1 and paranoid? = true]
  [
    let m link-neighbors with-min [ranking] ask [m] of self
    [
      if notp? = true
      [
        ask turtles with [ solveconf = 1 and paranoid? = true]
         [
          set color green
          set p? true
          set notp? false
          set change-count change-count + 1
          set solveconf solveconf + 1
        ]
       ]
      ]
     ]

  ask turtles with [solveconf = 1 and paranoid? = true]
  [
    let m link-neighbors with-min [ ranking] ask [m] of self
    [
      if p? = true
     [
       ask turtles with [solveconf = 1 and paranoid? = true]
        [
         set color red
         set p? false
         set notp? true
         set change-count change-count + 1
         set solveconf solveconf + 1
        ]
       ]
      ]
     ]

; solve conflict for standard
  ask turtles with [solveconf = 1 and standard? = true]
  [
    let m link-neighbors with-min [ ranking] ask [m] of self
    [
     if notp? = true
     [
      ask turtles with [solveconf = 1 and standard? = true]
        [
         set color red
         set p? false
         set notp? true
         set change-count change-count + 1
         set solveconf solveconf + 1
        ]
       ]
      ]
     ]

  ask turtles with [solveconf = 1 and standard? = true]
  [
    let m link-neighbors with-min [ ranking] ask [m] of self
    [
     if p? = true
    [
     ask turtles with [solveconf = 1 and standard? = true]
        [
         set color green
         set p? true
         set notp? false
         set change-count change-count + 1
         set solveconf solveconf + 1
        ]
       ]
      ]
     ]
end



to mtrust_prd_p
  set color red
  set p? false
  set notp? true
  set change-count change-count + 1
  set mtrust_prd_count mtrust_prd_count + 1
end

to mtrust_prd_notp
  set color green
  set p? true
  set notp? false
  set change-count change-count + 1
  set mtrust_prd_count  mtrust_prd_count + 1
end

to mtrust_std_p
  set color red
  set p? false
  set notp? true
  set change-count change-count + 1
  set mtrust_std_count  mtrust_std_count + 1
end

to mtrust_std_notp
  set color green
  set p? true
  set notp? false
  set change-count change-count + 1
  set mtrust_std_count mtrust_std_count + 1
end

to trust_p
  set color green
  set p? true
  set notp? false
  set change-count change-count + 1
end

to trust_notp
  set color red
  set p? false
  set notp? true
  set change-count change-count + 1
end
@#$#@#$#@
GRAPHICS-WINDOW
359
14
796
452
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

CHOOSER
12
11
150
56
_network_type
_network_type
"small-world" "total" "random" "linear"
3

SLIDER
11
66
183
99
_nodes
_nodes
0
300
100.0
1
1
NIL
HORIZONTAL

BUTTON
10
201
73
240
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
81
377
144
410
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
163
329
248
362
NIL
discovery\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
153
181
186
stability-factor
stability-factor
0
200
101.0
1
1
NIL
HORIZONTAL

MONITOR
843
45
914
90
NIL
count links
17
1
11

MONITOR
956
44
1039
89
NIL
count turtles
17
1
11

MONITOR
833
122
933
167
standard nodes
count turtles with [ standard? = true]
17
1
11

MONITOR
964
122
1062
167
paranoid nodes
count turtles with [ paranoid? = true]
17
1
11

BUTTON
91
205
195
238
NIL
partial_setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
376
69
409
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
835
199
892
244
nodes p
count turtles with [ p? = true ]
17
1
11

MONITOR
919
198
994
243
nodes notp
count turtles with [notp? = true]
17
1
11

MONITOR
831
274
943
319
NIL
mtrust_prd_count
17
1
11

MONITOR
965
275
1076
320
NIL
mtrust_std_count
17
1
11

MONITOR
1011
197
1101
242
solve conflict?
count turtles with [ solveconf >= 2 ]
17
1
11

SLIDER
11
111
183
144
proportion_paranoid
proportion_paranoid
0
100
49.0
1
1
NIL
HORIZONTAL

CHOOSER
5
319
152
364
discovery_type
discovery_type
"paranoid_random" "standard_random" "standard_min" "paranoid_min" "standard_max" "paranoid_max"
4

BUTTON
154
259
285
292
NIL
maximize-minimize
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
5
249
143
294
m_M_type
m_M_type
"standard_m" "paranoid_m" "standard_M" "paranoid_M"
3

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;only_standard&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;total&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;contradictory&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_log">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="57"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="101"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
