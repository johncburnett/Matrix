Style [view in "RAW" or edit mode for correct formatting]:

Generator modules (6x):
  Output 1 Stereo Buss (choose routing to FX via Matrix [a la Putney]
  
Processing modules (x6):
  Input 1 Stereo Buss -> Output 1 Stereo Buss
  
Output Module:
  Input 6 Stereo Busses (from Processing Modules) [individual vol Control] -> Output 1 Stereo Buss [master vol Control]

Buss Info: 
  Generators:
    no1 genInput
      output (stereo) -> choose route to [50,52,54,56,58,60] via matrix
    no2 droplet (wip)
          output (stereo) -> choose route to [50,52,54,56,58,60] via matrix
    no3 butterSynth
          output (stereo) -> choose route to [50,52,54,56,58,60] via matrix
    no4 patternPercussion
          output (stereo) -> choose route to [50,52,54,56,58,60] via matrix
    no5 Snare
          output (stereo) -> choose route to [50,52,54,56,58,60] via matrix
    no6 TBA
          output (stereo) -> choose route to [50,52,54,56,58,60] via matrix
          
  Processors:
    no1 dopplerPanner
      input (stereo) -> 50
      output (stereo) -> 100
    no2 SplatDelay
      input (stereo) -> 52
      output (stereo) -> 102
    no3 OctoVerb
      input (stereo) -> 54
      output (stereo) -> 104
    no4 CombShift
      input (stereo) -> 56
      output (stereo) -> 106
    no5 CombFilter
      input (stereo) -> 58
      output (stereo) -> 108
    no6 LiveSampler (wip)
      input (stereo) -> 60
      output (stereo) -> 110
      
  Output Module:
    Input from dopplerPanner
      output (stereo) -> 100
    Input from SplatDelay
          output (stereo) -> 102
    Input from OctoVerb
          output (stereo) -> 104
    Input from CombShift
          output (stereo) -> 106
    Input from CombFilter
          output (stereo) -> 108
    Input from LiveSampler
          output (stereo) -> 110
        
