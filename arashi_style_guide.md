Style:

Input modules:
  Output 4 channels
  
Processing modules:
  Output 4 stereo pairs

Buss Info: 
  Generators:
    no1 genInput
      output (stereo) -> 50
    no2 droplet (wip)
          output (stereo) -> 52
    no3 butterSynth
          output (stereo) -> 54
    no4 patternPercussion
          output (stereo) -> 56
    no5 Snare
          output (stereo) -> 58
    no6 TBA
          output (stereo) -> 60
          
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
        
