globals [
  colors             ;; a list of colors we use to color the turtles
  regions

  percent-similar    ;; on the average, what percent of a turtle's neighbors are the same color as that turtle?
  percent-unhappy    ;; what percent of the turtles are unhappy?

  percent-isolated   ;; percent of isolated if most of its neighbors share the same color
  percent-extreme    ;; percent of distinct numeric range in political-spectrum
  percent-diverse    ;; percent of how many agents have 5 different neighbours
  polarization-score ;; gives over-all score that is calculated by percent of isolated, extreme and diverse
  shift-score        ;; gives the percent of agents who shift from one political-stance to another

  percent-right
  percent-left
  percent-null

  turtle-extreme
  turtle-moderate
]

turtles-own [
  region                     ;; region the agent is born at
  political-stance           ;; which party to vote
  initial-stance             ;; the initial political stance
  has-changed                ;; changing if political stance is changed over time
  political-spectrum         ;; political leaning (-50 to +50)
  persuasiveness             ;; ability to persuade others (0-10)
  susceptibility             ;; likelihood of being persuaded (0-10)
  happy?                     ;; for each turtle, indicates whether at least %-similar-wanted percent of
                             ;; that turtle's neighbors are the same color as the turtle
  similar-nearby             ;; how many neighboring turtles have a turtle with my color?
  other-nearby               ;; how many have a turtle of another color?
  total-nearby               ;; how many neighboring patches have a turtle?
  my-%-similar-wanted        ;; the threshold for this particular turtle
]


to setup
  clear-all
  reset-ticks
  import-pcolors "regions-in-turkey.png"

  set colors [[88 24 69] [199 0 57] white [218 247 166] yellow]
  set regions ["Marmara" "Ege" "Akdeniz" "Karadeniz" "İç Anadolu" "Doğu Anadolu" "Güneydoğu Anadolu"]

  ;create turtles with randomized political-spectrum
  foreach regions [
  selected-region ->
    ; Create 26 turtles with no distinct political-spectrum - 26 = 1818 * 0.01
    ask n-of 26 patches with [pcolor != black] [
      sprout 1 [
        set region selected-region
        set political-spectrum random 10 - 5
      ]
    ]

    ; Create 50 turtles with political-spectrum towards left - 50 = (132-26) * 0.48
    ask n-of 50 patches with [pcolor != black] [
      sprout 1 [
        set region selected-region
        set political-spectrum random 45 - 50
      ]
    ]

    ; Create 56 turtles with political-spectrum towards right - 56 = (132-26) * 0.52
    ask n-of 56 patches with [pcolor != black] [
      sprout 1 [
        set region selected-region
        set political-spectrum random 46 + 5
      ]
    ]
]

  ;Marmara
  ask patch -26 10
    [ sprout 221 [
      set political-spectrum random 45 - 50      ;;create  turtles with political-spectrum towards left
      set region "Marmara"
      ]
  ]

  ask patch -25 12
    [ sprout 218 [
      set political-spectrum random 46 + 5      ;;create  turtles with political-spectrum towards right
      set region "Marmara"
      ]
  ]

  ;İç Anadolu
  ask patch -7 -1
    [ sprout 67 [
      set political-spectrum random 45 - 50
      set region "İç Anadolu"
      ]
  ]

  ask patch -8 1
    [ sprout 96 [
      set political-spectrum random 46 + 5
      set region "İç Anadolu"
      ]
  ]

  ;Ege
  ask patch -25 -3
    [ sprout 67 [
      set political-spectrum random 45 - 50
      set region "Ege"
      ]
  ]

  ask patch -26 -4
    [ sprout 49 [
      set political-spectrum random 46 + 5
      set region "Ege"
      ]
  ]
  ;Akdeniz
  ask patch -20 -9
    [ sprout 51 [
      set political-spectrum random 45 - 50
      set region "Akdeniz"
      ]
  ]

  ask patch -20 -8
    [ sprout 50 [
      set political-spectrum random 46 + 5
      set region "Akdeniz"
      ]
  ]
  ;Güneydoğu Anadolu
  ask patch 20 -6
    [ sprout 14 [
      set political-spectrum random 45 - 50
      set region "Güneydoğu Anadolu"
      ]
  ]

  ask patch 20 -7
    [ sprout 14 [
      set political-spectrum random 46 + 5
      set region "Güneydoğu Anadolu"
      ]
  ]
  ;Karadeniz
  ask patch -2 10
    [ sprout 18 [
      set political-spectrum random 45 - 50
      set region "Karadeniz"
      ]
  ]

  ask patch -2 12
    [ sprout 34 [
      set political-spectrum random 46 + 5
      set region "Karadeniz"
      ]
  ]

  ask turtles
    [ set my-%-similar-wanted random %-similar-wanted
      set shape "person"
      set sıze 1.3
      set has-changed false
      set persuasiveness random 11

      ifelse political-spectrum >= 40 or political-spectrum <= -40 [
        set susceptibility random 4
      ]
      [
        set susceptibility random 11
      ]

      if political-spectrum >= 30 [
        set color yellow
        set political-stance "right"
      ]
      if political-spectrum >= 5 and political-spectrum < 30 [
        set color [218 247 166]
        set political-stance "right"
      ]
      if political-spectrum >= -5 and political-spectrum < 5 [
        set color white
        set political-stance "undecided"
      ]
      if political-spectrum >= -30 and political-spectrum < -5 [
        set color [199 0 57]
        set political-stance "left"
      ]
      if political-spectrum < -30 [
        set color [88 24 69]
        set political-stance "left"
      ]
      set initial-stance political-stance
  ]

  set turtle-extreme one-of turtles with [ (political-spectrum <= -40 or political-spectrum >= 40) and (susceptibility <= 3 and susceptibility > 0) ]
  set turtle-moderate one-of turtles with [ (political-spectrum <= 30 and political-spectrum >= -30) and susceptibility > 5 ]

  update-turtles
  update-globals
  reset-ticks
end

to go
  if all? turtles [happy?] [ stop ]
  move-unhappy-turtles
  update-turtles
  update-globals
  tick
end

to move-unhappy-turtles
  ask turtles with [ not happy?]
    [ find-new-spot ]
end

to find-new-spot
  rt random-float 360
  fd random-float 10
  if any? other turtles-here
    [ find-new-spot ]          ;; keep going until we find an unoccupied patch
  if pcolor = black
    [ find-new-spot ]       ;; keep turtles in the map
  setxy pxcor pycor  ;; move to center of patch
end

to update-turtles
  ask turtles [
    ;; Existing happiness logic
    set similar-nearby count (turtles-on neighbors in-radius 3) with [color = [color] of myself]
    set total-nearby count (turtles-on neighbors in-radius 3)
    set other-nearby count (turtles-on neighbors in-radius 3) with [color != [color] of myself]
    set happy? similar-nearby >= (my-%-similar-wanted * total-nearby / 100)
                 and other-nearby >= (%-different-wanted * total-nearby / 100)

    ;; New interaction logic for political spectrum
    ask turtles-on neighbors [
      ;; Check persuasiveness
      if [persuasiveness] of myself < [persuasiveness] of one-of turtles-on neighbors [
        if [political-spectrum] of myself < [political-spectrum] of one-of turtles-on neighbors [
          set political-spectrum political-spectrum + susceptibility
          if political-spectrum > 50[
            set political-spectrum 50
           ]
          if political-spectrum < -50[
            set political-spectrum -50
           ]
        ]
        if [political-spectrum] of myself > [political-spectrum] of one-of turtles-on neighbors [
          set political-spectrum political-spectrum - susceptibility
          if political-spectrum > 50[
            set political-spectrum 50
           ]
          if political-spectrum < -50[
            set political-spectrum -50
           ]
         ]

        if political-stance != initial-stance [
        set has-changed true
      ]

      ]

     recolor-turtles political-spectrum
     reassign-political-stance political-spectrum
    ]

    if remainder ticks 100 = 0 [ add-external-event-effects ]
  ]
end

to add-external-event-effects

  if political-campaigns-by-R = true [
       if political-spectrum <= -45 or political-spectrum >= 45 [
         set political-spectrum political-spectrum

         ifelse political-spectrum > -40 [
           set political-spectrum political-spectrum + 5
         ]
         [ ;;else do nothing
         ]
       ]
      recolor-turtles political-spectrum
    ]

  if political-campaigns-by-L = true [
       if political-spectrum <= -45 or political-spectrum >= 45 [
         set political-spectrum political-spectrum

         ifelse political-spectrum < 40 [
           set political-spectrum political-spectrum - 5
         ]
         [ ;;else do nothing
         ]
       ]
      recolor-turtles political-spectrum
      reassign-political-stance political-spectrum
     ]
end

to recolor-turtles [spectrum]

  if spectrum >= 30 [
    set color yellow
  ]
  if spectrum >= 5 and spectrum < 30 [
    set color [218 247 166]
  ]
  if spectrum >= -5 and spectrum < 5 [
    set color white
  ]
  if spectrum >= -30 and spectrum < -5 [
    set color [199 0 57]
  ]
  if spectrum < -30 [
    set color [88 24 69]
  ]
end

to reassign-political-stance [spectrum]

  if spectrum >= 5 [
    set political-stance "right"
  ]
  if spectrum < -5 [
    set political-stance "left"
  ]

  if political-stance != initial-stance [
    set has-changed true
  ]
end

to update-globals
  let similar-neighbors sum [similar-nearby] of turtles
  let total-neighbors sum [total-nearby] of turtles
  set percent-similar (similar-neighbors / total-neighbors) * 100
  set percent-unhappy (count turtles with [not happy?]) / (count turtles) * 100
  set percent-right (count turtles with [political-spectrum >= 5]) / ((count turtles) - (count turtles with [political-spectrum < 5 and political-spectrum >= -5])) * 100
  set percent-left (count turtles with [political-spectrum < -5]) / ((count turtles) - (count turtles with [political-spectrum < 5 and political-spectrum >= -5])) * 100
  set percent-null (count turtles with [political-spectrum < 5 and political-spectrum >= -5]) / (count turtles) * 100
  update-polarization-score
  update-shift-score
end

to update-polarization-score
  update-isolation
  update-extremity
  update-diversity
  set polarization-score (percent-isolated + percent-extreme - percent-diverse)
end

to update-isolation
  let isolated-turtles count turtles with [
    (total-nearby != 0 and similar-nearby / total-nearby >= 0.75)
    or total-nearby = 0
  ]
  set percent-isolated (isolated-turtles / count turtles) * 100
end

to update-extremity
  let extreme-turtles count turtles with [
    political-spectrum <= -40 or political-spectrum >= 40
  ]
  let total-turtles count turtles
  set percent-extreme (extreme-turtles / total-turtles) * 100
end

to update-diversity
  let diverse-turtles count turtles with [
    count (turtles-on neighbors) with [color != [color] of myself] >= 6
  ]
  let total-turtles count turtles
  set percent-diverse (diverse-turtles / total-turtles) * 100
end

to update-shift-score
  let shifted-turtles 0
  set shifted-turtles count turtles with [ has-changed = true ]
  let total-turtles count turtles
  set shift-score (shifted-turtles / total-turtles) * 100
end
@#$#@#$#@
GRAPHICS-WINDOW
434
20
1414
492
-1
-1
3.9835
1
10
1
1
1
0
1
1
1
-60
60
-28
28
1
1
1
ticks
30.0

MONITOR
266
162
376
207
Percent Unhappy
percent-unhappy
1
1
11

MONITOR
46
162
154
207
Percent Similar
percent-similar
1
1
11

PLOT
0
22
210
157
Percent of Similar Neighbors
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -2674135 true "" "plot percent-similar"

PLOT
216
22
416
157
Percent Unhappy
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -10899396 true "" "plot percent-unhappy"

SLIDER
1948
808
2173
841
%-similar-wanted
%-similar-wanted
0.0
100.0
69.0
1.0
1
%
HORIZONTAL

BUTTON
2251
826
2409
882
setup
setup
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
2251
898
2413
953
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
1948
848
2173
881
%-different-wanted
%-different-wanted
0
100
0.0
1
1
%
HORIZONTAL

PLOT
0
212
415
417
Scores
time
%
0.0
50.0
0.0
100.0
true
true
"" ""
PENS
"Percent extreme" 1.0 0 -8630108 true "" "plot percent-extreme"
"Persent isolated" 1.0 0 -13791810 true "" "plot percent-isolated"
"Percent diverse" 1.0 0 -682149 true "" "plot percent-diverse"

PLOT
2
502
380
710
Polarization Score
time
%
0.0
50.0
0.0
100.0
true
false
"" ""
PENS
"Polarization Score" 1.0 0 -16777216 true "" "plot polarization-score"

MONITOR
0
432
103
477
Percent Extreme
percent-extreme
2
1
11

MONITOR
136
432
239
477
Percent Isolated
percent-isolated
2
1
11

MONITOR
270
432
373
477
Percent Diverse
Percent-diverse
2
1
11

MONITOR
111
723
245
768
Polarization Score
polarization-score
2
1
11

PLOT
1436
21
1878
289
Votes
time
%
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Right Vote" 1.0 0 -14835848 true "" "plot percent-right"
"Left Vote" 1.0 0 -2674135 true "" "plot percent-left"
"Null Vote" 1.0 0 -9276814 true "" "plot percent-null"

MONITOR
1456
311
1576
356
Percentage Right
percent-right
0
1
11

MONITOR
1591
311
1711
356
Percentage Left
percent-left
0
1
11

MONITOR
1726
311
1851
356
Percentage Null
percent-null
0
1
11

PLOT
431
511
1872
782
Regional Right Vote 
time
%
0.0
200.0
30.0
70.0
false
true
"" ""
PENS
"selected1" 1.0 0 -16777216 true "" "plot (count turtles with [political-spectrum >= 5 and region = selected1]) / (count turtles with [region = selected1]) * 100"
"selected2" 1.0 0 -2674135 true "" "plot (count turtles with [political-spectrum >= 5 and region = selected2]) / (count turtles with [region = selected2]) * 100"

CHOOSER
1436
382
1576
427
selected1
selected1
"Marmara" "Ege" "Akdeniz" "Karadeniz" "İç Anadolu" "Doğu Anadolu" "Güneydoğu Anadolu"
1

CHOOSER
1436
438
1576
483
selected2
selected2
"Marmara" "Ege" "Akdeniz" "Karadeniz" "İç Anadolu" "Doğu Anadolu" "Güneydoğu Anadolu"
3

PLOT
433
793
1874
1046
Regional Left Vote
time
%
0.0
200.0
30.0
70.0
true
true
"" ""
PENS
"selected1" 1.0 0 -16777216 true "" "plot (count turtles with [political-spectrum < -5 and region = selected1]) / (count turtles with [region = selected1]) * 100"
"selected2" 1.0 0 -2674135 true "" "plot (count turtles with [political-spectrum < -5 and region = selected2]) / (count turtles with [region = selected2]) * 100"

MONITOR
1585
380
1715
425
Selected1 Right Percent
(count turtles with [political-spectrum >= 5 and region = selected1]) / (count turtles with [region = selected1 and (political-spectrum < -5 or political-spectrum >= 5)]) * 100
2
1
11

MONITOR
1585
440
1715
485
Selected2 Right Percent
(count turtles with [political-spectrum >= 5 and region = selected2]) / (count turtles with [region = selected2 and (political-spectrum < -5 or political-spectrum >= 5)]) * 100
2
1
11

MONITOR
1725
380
1855
425
Selected1 Left Percent
(count turtles with [political-spectrum < -5 and region = selected1]) / (count turtles with [region = selected1 and (political-spectrum < -5 or political-spectrum >= 5)]) * 100
2
1
11

MONITOR
1725
440
1855
485
Selected2 Left Percent
(count turtles with [political-spectrum < -5 and region = selected2]) / (count turtles with [region = selected2 and (political-spectrum < -5 or political-spectrum >= 5)]) * 100
2
1
11

SWITCH
1948
911
2122
944
political-campaigns-by-R
political-campaigns-by-R
1
1
-1000

SWITCH
1948
951
2122
984
political-campaigns-by-L
political-campaigns-by-L
1
1
-1000

PLOT
1906
43
2213
302
Change in One Extreme Agent
time
political-spectrum
0.0
10.0
-50.0
50.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot [political-spectrum] of turtle-extreme"

PLOT
2226
46
2544
304
Change in One Moderate Agent
time
political-spectrum
0.0
10.0
-50.0
50.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot [political-spectrum] of turtle-moderate"

PLOT
1908
356
2554
747
plot 1
time
number of turtles
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Right" 1.0 0 -1184463 true "" "plot count turtles with [ color = yellow ]"
"Middle Right" 1.0 0 -723837 true "" "plot count turtles with [ color = [218 247 166] ]"
"Middle" 1.0 0 -7500403 true "" "plot count turtles with [ color = white ]"
"Middle Left" 1.0 0 -5825686 true "" "plot count turtles with [ color = [199 0 57]]"
"Left" 1.0 0 -11783835 true "" "plot count turtles with [ color = [88 24 69] ]"

PLOT
4
778
384
996
Shift Score
time
%
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"shift score" 1.0 0 -16777216 true "" "plot shift-score"

MONITOR
128
1021
252
1066
shift-score
shift-score
2
1
11

@#$#@#$#@
## ACKNOWLEDGMENT

This model is from Chapter Three of the book "Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo", by Uri Wilensky & William Rand.

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

This model is in the IABM Textbook folder of the NetLogo Models Library. The model, as well as any updates to the model, can also be found on the textbook website: http://www.intro-to-abm.com/.

## WHAT IS IT?

This project models the behavior of two types of turtles in a mythical pond. The red turtles and green turtles get along with one another. But each turtle wants to make sure that it lives near some of "its own." That is, each red turtle wants to live near at least some red turtles, and each green turtle wants to live near at least some green turtles. The simulation shows how these individual preferences ripple through the pond, leading to large-scale patterns. This model is an extension of the Segregation Simple Extension 2 model. It adds a constraint that agents also want to have a minimum number of different agents around them.

This project was inspired by Thomas Schelling's writings about social systems (particularly with regards to housing segregation in cities).

## HOW TO USE IT

Click the SETUP button to set up the turtles. There are equal numbers of each color turtles. The turtles move around until there is at most one turtle on a patch.  Click GO to start the simulation. If turtles don't have enough same-color neighbors, they jump to a nearby patch.

The NUMBER slider controls the total number of turtles. (It takes effect the next time you click SETUP.) The NUMBER-OF-ETHNICITIES slider controls the number of different types of turtles, each a different color. The %-SIMILAR-WANTED slider controls the percentage of same-color turtles that each turtle wants among its neighbors. For example, if the slider is set at 30, each green turtle wants at least 30% of its neighbors to be green turtles. The %-DIFFERENT-WANTED slider controls the percentage of different-color turtles that each turtle wants among its neighbors. Turtles can only be happy if both the %-similar and %-different constraints are met.

The "PERCENT SIMILAR" monitor shows the average percentage of same-color neighbors for each turtle. It starts at about 0.5, since each turtle starts (on average) with an equal number of red and green turtles as neighbors. The "PERCENT UNHAPPY" monitor shows the percent of turtles that have fewer same-ethnicity neighbors than they want (and thus want to move).  Both monitors are also plotted.

## THINGS TO NOTICE

When you execute SETUP, the turtles are randomly distributed throughout the pond. But many turtles are "unhappy" since they don't have enough neighbors of the same ethnicity. The unhappy turtles jump to new locations in the vicinity. But in the new locations, they might tip the balance of the local population, prompting other turtles to leave. If a few red turtles move into an area, the local blue or orange turtles might leave. But when the blue or orange turtles move to a new area, they might prompt red turtles to leave that area, and so on.

Over time, the number of unhappy turtles decreases. But the pond becomes more segregated, with clusters of each ethnicity.

Again, relatively small individual preferences can lead to significant overall segregation. The exact numbers depend on how many ethnicities you have, and on the random distribution of their preferences for similarity.

## THINGS TO TRY

How does the diversity in PERCENT-SIMILAR-WANTED for each ethnicity affect the overall segregation pattern?

How does the added constraint of the PERCENT-DIFFERENT-WANTED for each ethnicity affect the overall segregation pattern?

Try different values for %-SIMILAR-WANTED. How does the overall degree of segregation change?

Try different values for NUMBER-OF-ETHNICITIES. How does the overall segregation pattern change?

If each turtle wants at least 40% same-color neighbors, what percentage (on average) do they end up with?

For what slider settings does the model run forever without all agents being satisfied?

## NETLOGO FEATURES

In the UPDATE-GLOBALS procedure, note the use of SUM, COUNT, VALUES-FROM, and WITH to compute the percentages displayed in the monitors and plots.

## CREDITS AND REFERENCES

This model is a simplified version of:

* Wilensky, U. (1997).  NetLogo Segregation model.  http://ccl.northwestern.edu/netlogo/models/Segregation.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Schelling, T. (1978). Micromotives and Macrobehavior. New York: Norton.

See also: Rauch, J. (2002). Seeing Around Corners; The Atlantic Monthly; April 2002;Volume 289, No. 4; 35-48. https://www.theatlantic.com/magazine/archive/2002/04/seeing-around-corners/302471/

## HOW TO CITE

This model is part of the textbook, “Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo.”

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U., Rand, W. (2006).  NetLogo Segregation Simple Extension 3 model.  http://ccl.northwestern.edu/netlogo/models/SegregationSimpleExtension3.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the textbook as:

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

## COPYRIGHT AND LICENSE

Copyright 2006 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2006 Cite: Wilensky, U., Rand, W. -->
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

hamsi
false
0
Polygon -7500403 true true 283 153 288 149 271 146 301 145 300 138 247 119 190 107 104 117 54 133 39 134 10 99 9 112 19 142 9 175 10 185 40 158 69 154 64 164 80 161 86 156 132 160 209 164
Polygon -7500403 true true 199 161 152 166 137 164 169 154
Circle -16777216 true false 256 129 12
Line -16777216 false 222 134 222 150
Line -16777216 false 217 134 217 150
Line -16777216 false 212 134 212 150
Polygon -7500403 true true 78 125 62 118 63 130
Polygon -7500403 true true 121 157 105 161 101 156 106 152
Polygon -7500403 true true 195 120 150 120 122 104 135 105

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="ReplicationExperiment2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>percent-similar</metric>
    <metric>percent-unhappy</metric>
    <metric>percent-extreme</metric>
    <metric>polarization-score</metric>
    <metric>percent-right</metric>
    <metric>percent-left</metric>
    <steppedValueSet variable="random-seed" first="12345" step="1" last="12364"/>
    <enumeratedValueSet variable="%-similar-wanted">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-different-wanted">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected1">
      <value value="&quot;Ege&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected2">
      <value value="&quot;Marmara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-L">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-R">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>percent-similar</metric>
    <metric>percent-unhappy</metric>
    <metric>percent-extreme</metric>
    <metric>polarization-score</metric>
    <metric>percent-right</metric>
    <metric>percent-left</metric>
    <metric>count turtles with [ color = yellow ]</metric>
    <metric>count turtles with [ color = [218 247 166] ]</metric>
    <metric>count turtles with [ color = white ]</metric>
    <metric>count turtles with [ color = [199 0 57]]</metric>
    <metric>count turtles with [ color = [88 24 69] ]</metric>
    <steppedValueSet variable="random-seed" first="12345" step="1" last="12364"/>
    <enumeratedValueSet variable="%-similar-wanted">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-different-wanted">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected1">
      <value value="&quot;Ege&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected2">
      <value value="&quot;Marmara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-L">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-R">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="ReplicationExperimentLast" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>percent-similar</metric>
    <metric>percent-unhappy</metric>
    <metric>percent-extreme</metric>
    <metric>polarization-score</metric>
    <metric>shift-score</metric>
    <metric>percent-right</metric>
    <metric>percent-left</metric>
    <metric>count turtles with [ color = yellow ]</metric>
    <metric>count turtles with [ color = [218 247 166] ]</metric>
    <metric>count turtles with [ color = white ]</metric>
    <metric>count turtles with [ color = [199 0 57]]</metric>
    <metric>count turtles with [ color = [88 24 69] ]</metric>
    <metric>count turtles with [ has-changed = true ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= -40 or political-spectrum &gt;= 40) and (susceptibility &lt;= 3 and susceptibility &gt; 0) ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= 30 or political-spectrum &gt;= -30) and susceptibility &gt; 5 ]</metric>
    <steppedValueSet variable="random-seed" first="12345" step="1" last="12364"/>
    <enumeratedValueSet variable="%-similar-wanted">
      <value value="69"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-different-wanted">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected1">
      <value value="&quot;Ege&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected2">
      <value value="&quot;Marmara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-L">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-R">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity-by-similar-wanted" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>percent-similar</metric>
    <metric>percent-unhappy</metric>
    <metric>percent-extreme</metric>
    <metric>polarization-score</metric>
    <metric>shift-score</metric>
    <metric>percent-right</metric>
    <metric>percent-left</metric>
    <metric>count turtles with [ color = yellow ]</metric>
    <metric>count turtles with [ color = [218 247 166] ]</metric>
    <metric>count turtles with [ color = white ]</metric>
    <metric>count turtles with [ color = [199 0 57]]</metric>
    <metric>count turtles with [ color = [88 24 69] ]</metric>
    <metric>count turtles with [ has-changed = true ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= -40 or political-spectrum &gt;= 40) and (susceptibility &lt;= 3 and susceptibility &gt; 0) ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= 30 or political-spectrum &gt;= -30) and susceptibility &gt; 5 ]</metric>
    <steppedValueSet variable="%-similar-wanted" first="20" step="5" last="80"/>
    <enumeratedValueSet variable="%-different-wanted">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected1">
      <value value="&quot;Ege&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected2">
      <value value="&quot;Marmara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-L">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-R">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sensitivity-by-different-wanted" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>percent-similar</metric>
    <metric>percent-unhappy</metric>
    <metric>percent-extreme</metric>
    <metric>polarization-score</metric>
    <metric>shift-score</metric>
    <metric>percent-right</metric>
    <metric>percent-left</metric>
    <metric>count turtles with [ color = yellow ]</metric>
    <metric>count turtles with [ color = [218 247 166] ]</metric>
    <metric>count turtles with [ color = white ]</metric>
    <metric>count turtles with [ color = [199 0 57]]</metric>
    <metric>count turtles with [ color = [88 24 69] ]</metric>
    <metric>count turtles with [ has-changed = true ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= -40 or political-spectrum &gt;= 40) and (susceptibility &lt;= 3 and susceptibility &gt; 0) ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= 30 and political-spectrum &gt;= -30) and susceptibility &gt; 5 ]</metric>
    <enumeratedValueSet variable="%-similar-wanted">
      <value value="69"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%-different-wanted" first="0" step="5" last="50"/>
    <enumeratedValueSet variable="selected1">
      <value value="&quot;Ege&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected2">
      <value value="&quot;Marmara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-L">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-R">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="globalSensitivity" repetitions="7" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>percent-similar</metric>
    <metric>percent-unhappy</metric>
    <metric>percent-extreme</metric>
    <metric>polarization-score</metric>
    <metric>shift-score</metric>
    <metric>percent-right</metric>
    <metric>percent-left</metric>
    <metric>count turtles with [ color = yellow ]</metric>
    <metric>count turtles with [ color = [218 247 166] ]</metric>
    <metric>count turtles with [ color = white ]</metric>
    <metric>count turtles with [ color = [199 0 57]]</metric>
    <metric>count turtles with [ color = [88 24 69] ]</metric>
    <metric>count turtles with [ has-changed = true ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= -40 or political-spectrum &gt;= 40) and (susceptibility &lt;= 3 and susceptibility &gt; 0) ]</metric>
    <metric>count turtles with [ (political-spectrum &lt;= 30 or political-spectrum &gt;= -30) and susceptibility &gt; 5 ]</metric>
    <steppedValueSet variable="%-similar-wanted" first="20" step="5" last="80"/>
    <steppedValueSet variable="%-different-wanted" first="0" step="5" last="50"/>
    <enumeratedValueSet variable="selected1">
      <value value="&quot;Ege&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected2">
      <value value="&quot;Marmara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-L">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-R">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Robustness" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>percent-similar</metric>
    <metric>percent-unhappy</metric>
    <metric>percent-extreme</metric>
    <metric>polarization-score</metric>
    <metric>shift-score</metric>
    <metric>percent-right</metric>
    <metric>percent-left</metric>
    <metric>count turtles with [ color = yellow ]</metric>
    <metric>count turtles with [ color = [218 247 166] ]</metric>
    <metric>count turtles with [ color = white ]</metric>
    <metric>count turtles with [ color = [199 0 57]]</metric>
    <metric>count turtles with [ color = [88 24 69] ]</metric>
    <metric>count turtles with [ has-changed = true ]</metric>
    <steppedValueSet variable="%-similar-wanted" first="0" step="50" last="100"/>
    <enumeratedValueSet variable="%-different-wanted">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected1">
      <value value="&quot;Ege&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selected2">
      <value value="&quot;Marmara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-L">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="political-campaigns-by-R">
      <value value="false"/>
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
1
@#$#@#$#@
