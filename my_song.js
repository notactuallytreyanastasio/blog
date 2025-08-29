// ═══════════════════════════════════════════════════════════════════════════
// Bach Brandenburg Concerto No. 3 - Electronic Reinterpretation
// Duration: ~3 minutes before loop
// Structure: Allegro → Development → Fugue → Recapitulation → Finale
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// SECTION A: ALLEGRO (0:00 - 0:45)
// Opening theme with characteristic Brandenburg bounce
// ═══════════════════════════════════════════════════════════════════════════

// Main theme - the iconic Brandenburg motif transformed
const brandenburg_theme = `[
  g4 d5 b4 g4 d5 g5 fs5 g5 d5 b4 g4 d4 
  g4 a4 b4 c5 d5 e5 fs5 g5 fs5 e5 d5 c5
  b4 a4 g4 fs4 g4 b4 d5 g5 fs5 e5 d5 c5
  b4 c5 d5 e5 d5 c5 b4 a4 g4 fs4 g4 ~
]`;

// Counter-subject in classical fugue style
const counter_subject = `[
  ~ ~ ~ ~ d3 g3 b3 d4 g4 b3 d4 g4
  fs4 e4 d4 c4 b3 a3 g3 fs3 g3 a3 b3 c4
  d4 e4 fs4 g4 a4 b4 c5 d5 c5 b4 a4 g4
  fs4 g4 a4 b4 a4 g4 fs4 e4 d4 c4 b3 a3
]`;

// Violin I - main melodic line with baroque ornamentations
$: note(brandenburg_theme.slow(16))
  .s("sawtooth")
  .attack(0.01)
  .decay(0.1)
  .sustain(0.7)
  .release(0.3)
  .cutoff(perlin.range(2000, 4000).slow(32))
  .room(0.3)
  .gain(0.6)
  .pan(-0.3)
  .sometimes(x => x.add(note("12"))) // octave doubling

// Violin II - counter melody with slight delay
$: note(brandenburg_theme.slow(16))
  .late(0.125)
  .s("triangle")
  .attack(0.02)
  .decay(0.15)
  .sustain(0.6)
  .release(0.4)
  .cutoff(3000)
  .room(0.4)
  .gain(0.5)
  .pan(0.3)
  .add(note("-12")) // octave below

// Viola section - harmonic support
$: note(counter_subject.slow(16))
  .s("square")
  .attack(0.05)
  .decay(0.2)
  .sustain(0.5)
  .release(0.5)
  .cutoff(1500)
  .resonance(5)
  .gain(0.4)
  .pan(sine.range(-0.5, 0.5).slow(8))

// Continuo bass - walking bassline
$: note(`[
  g2 g2 g2 g2 d2 d2 d2 d2
  g2 g2 c3 c3 d3 d3 d2 d2
  g2 fs2 e2 d2 c2 b1 a1 d2
  g1 g1 g1 g1 g2 fs2 g2 ~
]`.slow(16))
  .s("sine sawtooth".fast(4))
  .attack(0.01)
  .decay(0.3)
  .sustain(0.4)
  .release(0.2)
  .cutoff(800)
  .gain(0.7)
  .shape(0.3)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION B: DEVELOPMENT (0:45 - 1:30)
// Exploration of themes with electronic textures
// ═══════════════════════════════════════════════════════════════════════════

// Sequenced arpeggios - classic Bach sequences
const sequence_pattern = `[
  g5 fs5 e5 d5 c5 b4 a4 g4
  a5 g5 fs5 e5 d5 c5 b4 a4
  b5 a5 g5 fs5 e5 d5 c5 b4
  c6 b5 a5 g5 fs5 e5 d5 c5
]`;

// Electronic sequence with filter automation
$: note(sequence_pattern.slow(8))
  .when(
    slowcat([1, 0, 0, 0]), // plays in second quarter
    x => x
      .s("pulse")
      .attack(0.001)
      .decay(0.05)
      .sustain(0.3)
      .release(0.1)
      .cutoff(sine.range(500, 5000).fast(2))
      .resonance(10)
      .delay(0.5)
      .delaytime(0.375)
      .delayfeedback(0.6)
      .gain(0.5)
      .pan(cosine.range(-0.8, 0.8).slow(4))
  )

// Rhythmic variation - Bach's characteristic rhythmic displacement
$: note(`[
  g4 g4 g4 ~ d5 d5 ~ b4 b4 ~ g5 g5 g5 ~
  fs5 ~ e5 e5 ~ d5 d5 ~ c5 ~ b4 b4 ~ a4
  g4 ~ fs4 fs4 ~ g4 g4 ~ a4 ~ b4 b4 ~ c5
  d5 d5 ~ c5 c5 ~ b4 b4 ~ a4 a4 ~ g4 ~
]`.slow(16))
  .when(
    slowcat([0, 1, 0, 0]),
    x => x
      .s("sawtooth")
      .vowel("a e i o u".slow(4))
      .cutoff(perlin.range(800, 3000).slow(16))
      .gain(0.4)
      .room(0.5)
  )

// Harmonic progression with chord substitutions
$: note(`<
  G:maj7 G:maj7 D:7 D:7 
  Em:min7 C:maj7 D:sus4 D:7
  G:maj7 G:6 C:maj7 C:6
  D:7 D:7sus4 G:maj7 G:maj7
>`.slow(4))
  .when(
    slowcat([0, 1, 1, 0]),
    x => x
      .struct("x ~ x x ~ x ~ x")
      .voicings()
      .s("sine")
      .attack(0.1)
      .release(1)
      .cutoff(2000)
      .gain(0.3)
      .room(0.6)
  )

// ═══════════════════════════════════════════════════════════════════════════
// SECTION C: FUGUE (1:30 - 2:15)
// Four-voice fugue with staggered entries
// ═══════════════════════════════════════════════════════════════════════════

const fugue_subject = `[
  g4 d5 b4 g4 fs4 g4 a4 b4
  c5 b4 a4 g4 fs4 e4 fs4 d4
]`;

const fugue_answer = `[
  d5 a5 fs5 d5 cs5 d5 e5 fs5
  g5 fs5 e5 d5 cs5 b4 cs5 a4
]`;

// Fugue Voice 1 - Subject
$: note(fugue_subject.slow(8))
  .when(
    slowcat([0, 0, 1, 1]),
    x => x
      .s("triangle")
      .attack(0.02)
      .decay(0.1)
      .sustain(0.6)
      .release(0.3)
      .cutoff(4000)
      .gain(0.5)
      .pan(-0.6)
      .room(0.4)
  )

// Fugue Voice 2 - Answer (delayed entry)
$: note(fugue_answer.slow(8))
  .when(
    slowcat([0, 0, 0, 1, 1, 1]),
    x => x
      .late(0.25)
      .s("square")
      .attack(0.03)
      .decay(0.15)
      .sustain(0.5)
      .release(0.4)
      .cutoff(3500)
      .gain(0.45)
      .pan(-0.2)
      .room(0.4)
  )

// Fugue Voice 3 - Subject in lower octave
$: note(fugue_subject.slow(8))
  .when(
    slowcat([0, 0, 0, 0, 1, 1]),
    x => x
      .late(0.5)
      .add(note("-12"))
      .s("sawtooth")
      .attack(0.04)
      .decay(0.2)
      .sustain(0.4)
      .release(0.5)
      .cutoff(2500)
      .gain(0.4)
      .pan(0.2)
      .room(0.4)
  )

// Fugue Voice 4 - Answer in bass
$: note(fugue_answer.slow(8))
  .when(
    slowcat([0, 0, 0, 0, 0, 1]),
    x => x
      .late(0.75)
      .add(note("-24"))
      .s("sine")
      .attack(0.05)
      .decay(0.25)
      .sustain(0.3)
      .release(0.6)
      .cutoff(1500)
      .gain(0.5)
      .pan(0.6)
      .shape(0.2)
  )

// ═══════════════════════════════════════════════════════════════════════════
// SECTION D: RECAPITULATION (2:15 - 2:45)
// Return of main theme with variations and electronic embellishments
// ═══════════════════════════════════════════════════════════════════════════

// Transformed main theme with glitch effects
$: note(brandenburg_theme.slow(16))
  .when(
    slowcat([0, 0, 0, 0, 0, 0, 1, 1]),
    x => x
      .s("sawtooth")
      .sometimes(x => x.chop(8).speed("1 1.5 0.5 2"))
      .attack(0.001)
      .decay(0.05)
      .sustain(0.8)
      .release(0.2)
      .cutoff(perlin.range(1000, 5000).fast(0.5))
      .resonance(sine.range(5, 15).slow(4))
      .distort(perlin.range(0, 0.3).slow(8))
      .gain(0.6)
      .pan(sine.range(-1, 1).slow(3))
      .room(0.3)
      .delay(0.3)
      .delaytime("0.375 0.25 0.5".slow(4))
      .delayfeedback(0.4)
  )

// Harmonic enrichment - extended harmonies
$: note(`<
  G:maj9 G:13 D:9sus4 D:9
  Em:11 C:maj7#11 D:13 D:7alt
  G:maj7 G:6/9 C:maj9 C:6
  D:9 D:7b9 G:maj7 G:maj
>`.slow(4))
  .when(
    slowcat([0, 0, 0, 0, 0, 0, 1, 1]),
    x => x
      .struct("x(5,8)")
      .voicings()
      .s("square")
      .attack(0.05)
      .release(0.5)
      .cutoff(3000)
      .gain(0.35)
      .room(0.7)
      .orbit(2)
  )

// Rhythmic intensification - baroque meets IDM
$: s("bd:5 sd:3 bd:5 sd:3 bd:5 bd:5 sd:3 ~")
  .when(
    slowcat([0, 0, 0, 0, 0, 0, 0, 1]),
    x => x
      .sometimes(x => x.fast(2))
      .speed(1.2)
      .gain(0.8)
      .shape(0.5)
      .room(0.2)
      .orbit(3)
  )

// ═══════════════════════════════════════════════════════════════════════════
// SECTION E: FINALE (2:45 - 3:00)
// Grand conclusion with all voices in counterpoint
// ═══════════════════════════════════════════════════════════════════════════

const finale_flourish = `[
  g5 b5 d6 g6 fs6 e6 d6 c6 
  b5 a5 g5 fs5 e5 d5 c5 b4
  a4 b4 c5 d5 e5 fs5 g5 a5
  b5 c6 d6 e6 fs6 g6 ~ ~
]`;

// All voices together in grand finale
$: stack(
  // Flourish in high register
  note(finale_flourish.slow(8))
    .when(
      slowcat([0, 0, 0, 0, 0, 0, 0, 0, 1]),
      x => x
        .s("triangle")
        .attack(0.001)
        .decay(0.05)
        .sustain(0.9)
        .release(1)
        .cutoff(5000)
        .gain(0.7)
        .room(0.8)
        .delay(0.5)
        .delaytime(0.25)
        .delayfeedback(0.7)
    ),
  
  // Pedal point on G
  note("g2 g1 g2 g1 g2 g2 g1 g3".slow(2))
    .when(
      slowcat([0, 0, 0, 0, 0, 0, 0, 0, 1]),
      x => x
        .s("sine sawtooth".fast(8))
        .attack(0.01)
        .decay(0.5)
        .sustain(0.5)
        .release(2)
        .cutoff(1000)
        .gain(0.8)
        .shape(0.4)
        .room(0.9)
    ),
  
  // Final chord progression
  note("<G:maj7 G:maj7 G:maj7 G:maj7>")
    .when(
      slowcat([0, 0, 0, 0, 0, 0, 0, 0, 0, 1]),
      x => x
        .struct("x ~ ~ ~ ~ ~ ~ ~")
        .voicings()
        .s("sawtooth")
        .attack(0.1)
        .release(3)
        .cutoff(4000)
        .gain(0.6)
        .room(1)
    )
).slow(1)

// ═══════════════════════════════════════════════════════════════════════════
// GLOBAL PARAMETERS AND EFFECTS
// ═══════════════════════════════════════════════════════════════════════════

// Master composition with tempo variations
stack(
  // All patterns are already defined above with $ notation
  // This creates the full 3-minute journey
  
  // Global reverb bus for spatial depth
  s("~ ~ ~ ~")
    .room(0.8)
    .roomsize(0.9)
    .orbit(1),
  
  // Subtle percussion throughout
  s("hh(7,16)")
    .gain(0.1)
    .pan(sine.range(-0.5, 0.5).fast(3))
    .speed(rand.range(0.95, 1.05))
    .orbit(4)
    
).cpm(110) // Bach's typical allegro tempo, adjusted for electronic interpretation

// The composition cycles through:
// 0:00-0:45 - Allegro (main theme exposition)
// 0:45-1:30 - Development (electronic variations)
// 1:30-2:15 - Fugue (four-voice counterpoint)
// 2:15-2:45 - Recapitulation (theme returns transformed)
// 2:45-3:00 - Finale (grand conclusion)
// Total: ~3 minutes before loop
