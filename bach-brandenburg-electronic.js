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

// ═══════════════════════════════════════════════════════════════════════════
// VISUAL COMPONENTS - Synchronized Geometric Patterns
// ═══════════════════════════════════════════════════════════════════════════

// Drawing capabilities are already loaded in the web UI
// No import needed - draw() and scope() are available globally

// Color scheme based on Bach's harmonic progressions
const baroqueColors = {
  tonic: '#FFD700',      // Gold - G major
  dominant: '#FF6B6B',   // Coral - D major  
  subdominant: '#4ECDC4', // Turquoise - C major
  minor: '#95E1D3',      // Mint - E minor
  diminished: '#C9B1FF', // Lavender - F# dim
  fugue: '#FFB6C1',      // Pink - fugue entries
  bass: '#2E3440',       // Dark grey - bass foundation
  accent: '#FFFFFF'      // White - accents
}

// VISUAL LAYER 1: Sacred Geometry - Golden Ratio Spirals
$: note(brandenburg_theme.slow(16))
  .draw(
    (ctx, hap, currentTime) => {
      const { width, height } = ctx.canvas
      const centerX = width / 2
      const centerY = height / 2
      
      // Calculate note position in scale for color mapping
      const noteValue = hap.value.note || 60
      const octave = Math.floor(noteValue / 12)
      const noteInScale = noteValue % 12
      
      // Golden ratio
      const phi = 1.618033988749
      
      // Create fibonacci spiral based on note pitch
      ctx.save()
      ctx.translate(centerX, centerY)
      ctx.rotate(currentTime * 0.5 + noteValue * 0.1)
      
      // Draw spiral segments
      for (let i = 0; i < 21; i++) {
        const radius = Math.pow(phi, i * 0.5) * 2
        const angle = i * Math.PI / 8
        
        ctx.beginPath()
        ctx.arc(0, 0, radius, angle, angle + Math.PI/4)
        
        // Color based on harmonic function
        const alpha = 0.6 - (i * 0.02)
        if (noteInScale === 0 || noteInScale === 7) {
          ctx.strokeStyle = baroqueColors.tonic + Math.floor(alpha * 255).toString(16)
        } else if (noteInScale === 2 || noteInScale === 9) {
          ctx.strokeStyle = baroqueColors.dominant + Math.floor(alpha * 255).toString(16)
        } else if (noteInScale === 4 || noteInScale === 11) {
          ctx.strokeStyle = baroqueColors.minor + Math.floor(alpha * 255).toString(16)
        } else {
          ctx.strokeStyle = baroqueColors.subdominant + Math.floor(alpha * 255).toString(16)
        }
        
        ctx.lineWidth = 3 - (i * 0.1)
        ctx.stroke()
      }
      
      ctx.restore()
    },
    { fill: baroqueColors.tonic, fade: 0.02 }
  )

// VISUAL LAYER 2: Counterpoint Visualization - Interwoven Lines
$: note(counter_subject.slow(16))
  .draw(
    (ctx, hap, currentTime) => {
      const { width, height } = ctx.canvas
      const noteValue = hap.value.note || 48
      
      // Create interwoven sine waves representing counterpoint
      ctx.save()
      ctx.globalAlpha = 0.7
      
      for (let voice = 0; voice < 4; voice++) {
        ctx.beginPath()
        
        for (let x = 0; x < width; x += 2) {
          const frequency = 0.01 + (voice * 0.005)
          const amplitude = 30 + (noteValue - 48) * 2
          const phase = currentTime * 2 + voice * Math.PI/2
          const y = height/2 + 
                   Math.sin(x * frequency + phase) * amplitude +
                   voice * 20 - 30
          
          if (x === 0) {
            ctx.moveTo(x, y)
          } else {
            ctx.lineTo(x, y)
          }
        }
        
        // Different color for each voice
        const colors = [baroqueColors.tonic, baroqueColors.dominant, 
                       baroqueColors.subdominant, baroqueColors.minor]
        ctx.strokeStyle = colors[voice]
        ctx.lineWidth = 2
        ctx.stroke()
      }
      
      ctx.restore()
    },
    { fade: 0.03 }
  )

// VISUAL LAYER 3: Fugue Visualization - Cascading Geometric Patterns
$: note(fugue_subject.slow(8))
  .draw(
    (ctx, hap, currentTime) => {
      const { width, height } = ctx.canvas
      const noteValue = hap.value.note || 67
      const voiceEntry = Math.floor(currentTime / 4) % 4
      
      // Draw cascading rectangles for fugue entries
      ctx.save()
      
      for (let entry = 0; entry <= voiceEntry; entry++) {
        const x = 100 + entry * 150
        const y = 100 + entry * 50
        const size = 60 + Math.sin(currentTime + entry) * 20
        
        // Rotating squares for each fugue entry
        ctx.save()
        ctx.translate(x, y)
        ctx.rotate((currentTime + entry) * 0.5)
        
        // Outer square
        ctx.strokeStyle = baroqueColors.fugue
        ctx.lineWidth = 3
        ctx.strokeRect(-size/2, -size/2, size, size)
        
        // Inner square
        ctx.strokeStyle = baroqueColors.accent
        ctx.lineWidth = 1
        ctx.strokeRect(-size/3, -size/3, size*2/3, size*2/3)
        
        // Center point
        ctx.fillStyle = baroqueColors.dominant
        ctx.beginPath()
        ctx.arc(0, 0, 3, 0, Math.PI * 2)
        ctx.fill()
        
        ctx.restore()
      }
      
      ctx.restore()
    },
    { fade: 0.05 }
  )

// VISUAL LAYER 4: Harmonic Progression Circles
$: note(`<G:maj7 D:7 Em:min7 C:maj7>`.slow(4))
  .draw(
    (ctx, hap, currentTime) => {
      const { width, height } = ctx.canvas
      const chord = hap.value.note || [67, 71, 74]
      
      // Draw concentric circles for each chord tone
      ctx.save()
      ctx.globalAlpha = 0.4
      
      if (Array.isArray(chord)) {
        chord.forEach((note, i) => {
          const radius = 50 + i * 30 + Math.sin(currentTime * 2 + i) * 10
          const x = width/2 + Math.cos(currentTime + i) * 100
          const y = height/2 + Math.sin(currentTime + i) * 100
          
          ctx.beginPath()
          ctx.arc(x, y, radius, 0, Math.PI * 2)
          
          // Gradient based on chord type
          const gradient = ctx.createRadialGradient(x, y, 0, x, y, radius)
          gradient.addColorStop(0, baroqueColors.accent + '40')
          gradient.addColorStop(1, baroqueColors.tonic + '00')
          
          ctx.fillStyle = gradient
          ctx.fill()
          
          ctx.strokeStyle = baroqueColors.tonic
          ctx.lineWidth = 1
          ctx.stroke()
        })
      }
      
      ctx.restore()
    },
    { fade: 0.02 }
  )

// VISUAL LAYER 5: Particle System for Rhythmic Accents
$: s("bd:5 sd:3 hh")
  .draw(
    (ctx, hap, currentTime) => {
      const { width, height } = ctx.canvas
      const sample = hap.value.s
      
      // Create particle explosion on drum hits
      const particleCount = sample.includes('bd') ? 20 : 10
      const baseRadius = sample.includes('bd') ? 100 : 50
      
      ctx.save()
      ctx.globalAlpha = 0.8
      
      for (let i = 0; i < particleCount; i++) {
        const angle = (Math.PI * 2 / particleCount) * i
        const velocity = (currentTime - hap.whole.begin) * 500
        const radius = Math.min(baseRadius, velocity)
        
        const x = width/2 + Math.cos(angle) * radius
        const y = height/2 + Math.sin(angle) * radius
        
        const size = Math.max(1, 5 - velocity/20)
        
        ctx.beginPath()
        ctx.arc(x, y, size, 0, Math.PI * 2)
        
        // Color based on drum type
        if (sample.includes('bd')) {
          ctx.fillStyle = baroqueColors.bass
        } else if (sample.includes('sd')) {
          ctx.fillStyle = baroqueColors.dominant
        } else {
          ctx.fillStyle = baroqueColors.accent
        }
        
        ctx.fill()
      }
      
      ctx.restore()
    },
    { fade: 0.1 }
  )

// VISUAL LAYER 6: Waveform Visualization with Baroque Ornamentation
$: note(sequence_pattern.slow(8))
  .scope({ 
    lines: 3,
    lineWidth: 2,
    lineColor: baroqueColors.minor,
    background: false
  })

// VISUAL LAYER 7: Dynamic Background - Breathing Cathedral
$: sine.range(0, 1).slow(32)
  .draw(
    (ctx, hap, currentTime) => {
      const { width, height } = ctx.canvas
      const breathe = hap.value
      
      // Create cathedral-like arches
      ctx.save()
      ctx.globalAlpha = 0.1
      
      for (let arch = 0; arch < 5; arch++) {
        const archWidth = width / 5
        const archX = arch * archWidth + archWidth/2
        const archHeight = height * (0.6 + breathe * 0.2)
        
        ctx.beginPath()
        ctx.moveTo(archX - archWidth/2, height)
        ctx.quadraticCurveTo(
          archX - archWidth/2, archHeight,
          archX, archHeight - 50
        )
        ctx.quadraticCurveTo(
          archX + archWidth/2, archHeight,
          archX + archWidth/2, height
        )
        
        const gradient = ctx.createLinearGradient(0, height, 0, 0)
        gradient.addColorStop(0, '#000000')
        gradient.addColorStop(1, baroqueColors.bass + '20')
        
        ctx.fillStyle = gradient
        ctx.fill()
      }
      
      ctx.restore()
    },
    { fade: 0.01 }
  )

// VISUAL LAYER 8: Finale Crescendo - Radial Burst
$: note(finale_flourish.slow(8))
  .when(
    slowcat([0, 0, 0, 0, 0, 0, 0, 0, 1]),
    x => x.draw(
      (ctx, hap, currentTime) => {
        const { width, height } = ctx.canvas
        const intensity = (currentTime % 1)
        
        // Radial burst effect
        ctx.save()
        ctx.translate(width/2, height/2)
        
        for (let ray = 0; ray < 36; ray++) {
          const angle = (Math.PI * 2 / 36) * ray
          const length = 100 + intensity * 300
          
          ctx.save()
          ctx.rotate(angle)
          
          ctx.beginPath()
          ctx.moveTo(0, 0)
          ctx.lineTo(length, 0)
          
          const gradient = ctx.createLinearGradient(0, 0, length, 0)
          gradient.addColorStop(0, baroqueColors.tonic + 'FF')
          gradient.addColorStop(1, baroqueColors.tonic + '00')
          
          ctx.strokeStyle = gradient
          ctx.lineWidth = 2
          ctx.stroke()
          
          ctx.restore()
        }
        
        ctx.restore()
      },
      { fade: 0.03 }
    )
  )