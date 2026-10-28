/**
 * AARAA BOUTIQUE – THUDIYALUR
 * Lucky Spin Wheel Interactive Logic
 * Theme: Luxury Regal Purple & Gold ✨
 * Background: Continuous Animated Crackers Blasting in Night Sky
 */

document.addEventListener('DOMContentLoaded', () => {

  // Guaranteed Winning Result: EXTRA 5% OFF
  const FIXED_WINNING_PRIZE = {
    title: "EXTRA 5% OFF",
    badge: "EXTRA 5% OFF",
    congratulations: "🎉 CONGRATULATIONS!",
    message: "You’ve won EXTRA 5% OFF at AARAA BOUTIQUE!",
    couponCode: "AARAA5OFF"
  };

  // 20 Twinkling Bulbs around the circular rim
  const rimContainer = document.getElementById('rimBulbsContainer');
  if (rimContainer) {
    rimContainer.innerHTML = '';
    const totalBulbs = 20;
    for (let i = 0; i < totalBulbs; i++) {
      const angle = (i * (360 / totalBulbs)) * (Math.PI / 180);
      const xPercent = 50 + 47.8 * Math.cos(angle);
      const yPercent = 50 + 47.8 * Math.sin(angle);
      const bulb = document.createElement('div');
      bulb.className = 'rim-bulb';
      bulb.style.left = `${xPercent}%`;
      bulb.style.top = `${yPercent}%`;
      bulb.style.animationDelay = `${(i * 0.12).toFixed(2)}s`;
      rimContainer.appendChild(bulb);
    }
  }

  // Web Audio API Synthesizer
  let audioCtx = null;
  let soundEnabled = true;

  function getAudioContext() {
    if (!audioCtx) {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (AudioContextClass) audioCtx = new AudioContextClass();
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  // Unlock audio on first user click anywhere
  document.addEventListener('click', () => { getAudioContext(); }, { once: true });

  function playCrackerBlastSound(isBoom = false) {
    if (!soundEnabled) return;
    const ctx = getAudioContext();
    if (!ctx) return;
    try {
      const bufferSize = ctx.sampleRate * (isBoom ? 0.32 : 0.12);
      const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (bufferSize * 0.22));
      }
      const noise = ctx.createBufferSource();
      noise.buffer = buffer;
      const filter = ctx.createBiquadFilter();
      filter.type = isBoom ? 'lowpass' : 'bandpass';
      filter.frequency.setValueAtTime(isBoom ? 500 : 1300, ctx.currentTime);
      
      const gain = ctx.createGain();
      gain.gain.setValueAtTime(isBoom ? 0.22 : 0.14, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + (isBoom ? 0.32 : 0.12));
      
      noise.connect(filter);
      filter.connect(gain);
      gain.connect(ctx.destination);
      noise.start();
    } catch (e) {}
  }

  function playTickSound() {
    if (!soundEnabled) return;
    const ctxAudio = getAudioContext();
    if (!ctxAudio) return;
    try {
      const osc = ctxAudio.createOscillator();
      const gain = ctxAudio.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(700 + Math.random() * 150, ctxAudio.currentTime);
      osc.frequency.exponentialRampToValueAtTime(140, ctxAudio.currentTime + 0.035);
      gain.gain.setValueAtTime(0.2, ctxAudio.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctxAudio.currentTime + 0.035);
      osc.connect(gain);
      gain.connect(ctxAudio.destination);
      osc.start();
      osc.stop(ctxAudio.currentTime + 0.035);
    } catch (e) {}
  }

  function playWinFanfare() {
    if (!soundEnabled) return;
    const ctxAudio = getAudioContext();
    if (!ctxAudio) return;
    try {
      const notes = [523.25, 659.25, 783.99, 1046.50];
      notes.forEach((freq, idx) => {
        const osc = ctxAudio.createOscillator();
        const gain = ctxAudio.createGain();
        osc.type = 'sine';
        const startTime = ctxAudio.currentTime + idx * 0.11;
        osc.frequency.setValueAtTime(freq, startTime);
        gain.gain.setValueAtTime(0, startTime);
        gain.gain.linearRampToValueAtTime(0.22, startTime + 0.02);
        gain.gain.exponentialRampToValueAtTime(0.001, startTime + 0.65);
        osc.connect(gain);
        gain.connect(ctxAudio.destination);
        osc.start(startTime);
        osc.stop(startTime + 0.65);
      });
    } catch (e) {}
  }

  // Sound Toggle
  const soundToggleBtn = document.getElementById('soundToggleBtn');
  const soundIcon = document.getElementById('soundIcon');
  const soundLabel = document.getElementById('soundLabel');

  if (soundToggleBtn) {
    soundToggleBtn.addEventListener('click', () => {
      soundEnabled = !soundEnabled;
      if (soundEnabled) {
        if (soundIcon) soundIcon.className = "fa-solid fa-volume-high";
        if (soundLabel) soundLabel.textContent = "Sound ON";
        getAudioContext();
        showToast("Sound effects enabled 🔔");
      } else {
        if (soundIcon) soundIcon.className = "fa-solid fa-volume-xmark";
        if (soundLabel) soundLabel.textContent = "Sound OFF";
        showToast("Sound effects muted 🔇");
      }
    });
  }

  // ==========================================================================
  // CONTINUOUS BACKGROUND FIRECRACKERS BLASTING IN THE NIGHT SKY
  // ==========================================================================
  const bgCanvas = document.getElementById('bgCrackersCanvas');
  let bgRockets = [];
  let bgParticles = [];
  let bgFlashes = [];

  if (bgCanvas) {
    const bgCtx = bgCanvas.getContext('2d');
    let bgWidth = (bgCanvas.width = window.innerWidth);
    let bgHeight = (bgCanvas.height = window.innerHeight);

    window.addEventListener('resize', () => {
      bgWidth = bgCanvas.width = window.innerWidth;
      bgHeight = bgCanvas.height = window.innerHeight;
    });

    class BackgroundRocket {
      constructor(startX, targetX, targetY, colors, sizeMultiplier = 1, isGrand = false) {
        this.x = startX;
        this.y = bgHeight + 10;
        this.targetX = targetX;
        this.targetY = targetY;
        this.colors = colors;
        this.sizeMultiplier = sizeMultiplier;
        this.isGrand = isGrand;

        const dx = targetX - startX;
        const dy = targetY - this.y;
        const dist = Math.hypot(dx, dy);
        const speed = (bgHeight < 700 ? 12 : 15);
        this.vx = (dx / dist) * speed;
        this.vy = (dy / dist) * speed;
        this.alive = true;
        this.trail = [];
      }

      update() {
        this.trail.push({ x: this.x, y: this.y });
        if (this.trail.length > 8) this.trail.shift();

        this.x += this.vx;
        this.y += this.vy;

        if (this.y <= this.targetY || this.vy >= 0) {
          this.explode();
          this.alive = false;
        }
      }

      draw() {
        for (let i = 0; i < this.trail.length; i++) {
          const p = this.trail[i];
          const ratio = i / this.trail.length;
          bgCtx.beginPath();
          bgCtx.arc(p.x, p.y, 2.0 * ratio, 0, Math.PI * 2);
          bgCtx.fillStyle = `rgba(255, 235, 170, ${ratio * 0.7})`;
          bgCtx.fill();
        }

        bgCtx.beginPath();
        bgCtx.arc(this.x, this.y, 3, 0, Math.PI * 2);
        bgCtx.fillStyle = '#FFFFFF';
        bgCtx.shadowColor = '#FFE082';
        bgCtx.shadowBlur = 10;
        bgCtx.fill();
        bgCtx.shadowBlur = 0;
      }

      explode() {
        const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (prefersReduced) return;

        playCrackerBlastSound(this.isGrand);
        const isMobile = window.innerWidth <= 600;

        bgFlashes.push({
          x: this.x,
          y: this.y,
          radius: this.isGrand ? (isMobile ? 180 : 240) : (isMobile ? 120 : 160),
          color: this.colors[0],
          alpha: 0.3
        });

        const count = this.isGrand 
          ? (isMobile ? 65 : 130) 
          : (isMobile ? 35 : (Math.random() > 0.45 ? 85 : 65));

        for (let i = 0; i < count; i++) {
          const angle = Math.random() * Math.PI * 2;
          const speed = (Math.random() * (isMobile ? 4.8 : 6.0) + 1.2) * this.sizeMultiplier;
          const color = this.colors[Math.floor(Math.random() * this.colors.length)];
          bgParticles.push(new BackgroundCrackerParticle(this.x, this.y, angle, speed, color, this.isGrand));
        }
      }
    }

    class BackgroundCrackerParticle {
      constructor(x, y, angle, speed, color, isGrand = false) {
        this.x = x;
        this.y = y;
        this.vx = Math.cos(angle) * speed;
        this.vy = Math.sin(angle) * speed;
        this.gravity = 0.082;
        this.friction = 0.963;
        this.color = color;
        this.alpha = 1;
        this.decay = Math.random() * 0.014 + (isGrand ? 0.007 : 0.011);
        this.radius = Math.random() * 2.8 + 1.3;
        this.flicker = Math.random() > 0.3;
        this.history = [];
      }

      update() {
        this.history.push({ x: this.x, y: this.y });
        if (this.history.length > 5) this.history.shift();

        this.vx *= this.friction;
        this.vy *= this.friction;
        this.vy += this.gravity;
        this.x += this.vx;
        this.y += this.vy;
        this.alpha -= this.decay;
      }

      draw() {
        if (this.alpha <= 0) return;
        bgCtx.save();
        bgCtx.globalAlpha = Math.max(0, this.flicker ? this.alpha * (Math.random() * 0.45 + 0.55) : this.alpha);
        
        if (this.history.length > 1) {
          bgCtx.beginPath();
          bgCtx.moveTo(this.history[0].x, this.history[0].y);
          for (let h = 1; h < this.history.length; h++) {
            bgCtx.lineTo(this.history[h].x, this.history[h].y);
          }
          bgCtx.strokeStyle = this.color;
          bgCtx.lineWidth = this.radius * 0.7;
          bgCtx.stroke();
        }

        bgCtx.fillStyle = this.color;
        bgCtx.shadowColor = this.color;
        bgCtx.shadowBlur = 8;
        bgCtx.beginPath();
        bgCtx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
        bgCtx.fill();
        bgCtx.restore();
      }
    }

    const colorsGold = ['#FFF9E6', '#FFE898', '#E5BE53', '#FFA000', '#FFFFFF'];
    const colorsMagenta = ['#FF4D94', '#FF85B8', '#D43F78', '#FFF0F5', '#FFE082'];
    const colorsCyanBlue = ['#00E5FF', '#80D8FF', '#00B0FF', '#FFFFFF', '#FFEAA7'];
    const colorsGrandFinale = ['#FFE898', '#FF2A85', '#00E5FF', '#76FF03', '#FFFFFF', '#FFD700', '#FF3D00'];

    function spawnRandomBackgroundCracker(isGrand = false) {
      const side = Math.random() > 0.5 ? 'left' : 'right';
      const startX = side === 'left' ? bgWidth * (0.06 + Math.random() * 0.25) : bgWidth * (0.69 + Math.random() * 0.25);
      const targetX = startX + (Math.random() - 0.5) * 80;
      const targetY = bgHeight * (0.10 + Math.random() * 0.38);
      
      const paletteChoices = [colorsGold, colorsMagenta, colorsCyanBlue, colorsGrandFinale];
      const chosenPalette = isGrand ? colorsGrandFinale : paletteChoices[Math.floor(Math.random() * paletteChoices.length)];

      bgRockets.push(new BackgroundRocket(startX, targetX, targetY, chosenPalette, isGrand ? 1.4 : 1.0, isGrand));
    }

    setTimeout(() => spawnRandomBackgroundCracker(false), 200);
    setTimeout(() => spawnRandomBackgroundCracker(false), 600);
    setTimeout(() => spawnRandomBackgroundCracker(true), 1100);

    function scheduleNextBackgroundCracker() {
      const nextDelay = 800 + Math.random() * 800;
      setTimeout(() => {
        const isGrand = Math.random() > 0.65;
        spawnRandomBackgroundCracker(isGrand);
        if (Math.random() > 0.45) {
          setTimeout(() => spawnRandomBackgroundCracker(false), 220);
        }
        scheduleNextBackgroundCracker();
      }, nextDelay);
    }
    scheduleNextBackgroundCracker();

    function animateBackgroundCrackers() {
      bgCtx.clearRect(0, 0, bgWidth, bgHeight);

      for (let i = bgFlashes.length - 1; i >= 0; i--) {
        const f = bgFlashes[i];
        const grad = bgCtx.createRadialGradient(f.x, f.y, 0, f.x, f.y, f.radius);
        grad.addColorStop(0, f.color);
        grad.addColorStop(1, 'transparent');
        bgCtx.save();
        bgCtx.globalAlpha = Math.max(0, f.alpha);
        bgCtx.fillStyle = grad;
        bgCtx.beginPath();
        bgCtx.arc(f.x, f.y, f.radius, 0, Math.PI * 2);
        bgCtx.fill();
        bgCtx.restore();
        f.alpha -= 0.035;
        if (f.alpha <= 0) bgFlashes.splice(i, 1);
      }

      if (Math.random() > 0.5) {
        bgCtx.fillStyle = 'rgba(255, 240, 200, ' + (Math.random() * 0.5 + 0.3) + ')';
        bgCtx.fillRect(Math.random() * bgWidth, Math.random() * (bgHeight * 0.75), 1.5, 1.5);
      }

      for (let i = bgRockets.length - 1; i >= 0; i--) {
        bgRockets[i].update();
        bgRockets[i].draw();
        if (!bgRockets[i].alive) {
          bgRockets.splice(i, 1);
        }
      }

      for (let i = bgParticles.length - 1; i >= 0; i--) {
        bgParticles[i].update();
        bgParticles[i].draw();
        if (bgParticles[i].alpha <= 0) {
          bgParticles.splice(i, 1);
        }
      }

      requestAnimationFrame(animateBackgroundCrackers);
    }
    animateBackgroundCrackers();

    // Export launcher for celebration triggers
    window.launchBgCracker = spawnRandomBackgroundCracker;
  }

  // Confetti Canvas
  const confettiCanvas = document.getElementById('confettiCanvas');
  let confettiPieces = [];
  let confettiAnimationId = null;

  if (confettiCanvas) {
    const confettiCtx = confettiCanvas.getContext('2d');

    function resizeConfetti() {
      confettiCanvas.width = window.innerWidth;
      confettiCanvas.height = window.innerHeight;
    }
    window.addEventListener('resize', resizeConfetti);
    resizeConfetti();

    function triggerConfetti() {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      confettiPieces = [];
      const colors = ['#FFE898', '#D4AF37', '#FF4D94', '#FFF', '#9B1B56', '#FDE8EF'];
      const count = window.innerWidth <= 600 ? 75 : 160;
      for (let i = 0; i < count; i++) {
        confettiPieces.push({
          x: window.innerWidth / 2,
          y: window.innerHeight / 2 - 50,
          r: Math.random() * 8 + 4,
          d: Math.random() * 50 + 10,
          color: colors[Math.floor(Math.random() * colors.length)],
          tilt: Math.floor(Math.random() * 10) - 10,
          tiltAngleInc: (Math.random() * 0.07) + 0.05,
          tiltAngle: 0,
          vx: (Math.random() - 0.5) * 22,
          vy: (Math.random() - 0.7) * 24,
          gravity: 0.38,
          alpha: 1
        });
      }
      if (confettiAnimationId) cancelAnimationFrame(confettiAnimationId);
      updateConfetti();
    }

    function updateConfetti() {
      confettiCtx.clearRect(0, 0, confettiCanvas.width, confettiCanvas.height);
      let activePieces = 0;

      confettiPieces.forEach(p => {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += p.gravity;
        p.vx *= 0.98;
        p.tiltAngle += p.tiltAngleInc;
        p.tilt = Math.sin(p.tiltAngle) * 15;
        p.alpha -= 0.0035;

        if (p.alpha > 0 && p.y < confettiCanvas.height + 50) {
          activePieces++;
          confettiCtx.save();
          confettiCtx.globalAlpha = Math.max(0, p.alpha);
          confettiCtx.fillStyle = p.color;
          confettiCtx.beginPath();
          confettiCtx.lineWidth = p.r / 2;
          confettiCtx.moveTo(p.x + p.tilt + p.r / 4, p.y);
          confettiCtx.lineTo(p.x + p.tilt, p.y + p.tilt + p.r / 4);
          confettiCtx.lineTo(p.x + p.tilt + p.r / 2, p.y + p.tilt + p.r / 2);
          confettiCtx.lineTo(p.x + p.tilt + p.r, p.y + p.r / 2);
          confettiCtx.closePath();
          confettiCtx.fill();
          confettiCtx.restore();
        }
      });

      if (activePieces > 0) {
        confettiAnimationId = requestAnimationFrame(updateConfetti);
      } else {
        confettiCtx.clearRect(0, 0, confettiCanvas.width, confettiCanvas.height);
      }
    }

    window.triggerAppConfetti = triggerConfetti;
  }

  // Spin Physics
  const spinBtn = document.getElementById('spinBtn');
  const wheelDisc = document.getElementById('wheelDisc');
  const pointerNeedle = document.getElementById('pointerNeedle');
  const spinStatusNote = document.getElementById('spinStatusNote');
  const winnerModal = document.getElementById('winnerModal');
  const modalCloseBtn = document.getElementById('modalCloseBtn');
  const copyCodeBtn = document.getElementById('copyCodeBtn');

  let currentRotation = 0;
  let isSpinning = false;

  function calculateWinningAngle() {
    const fullSpins = (6 + Math.floor(Math.random() * 3)) * 360;
    const naturalJitter = (Math.random() - 0.5) * 12; // Lands directly inside EXTRA 5% OFF segment (180deg)
    
    const currentMod = currentRotation % 360;
    let delta = (180 + naturalJitter) - currentMod;
    if (delta <= 0) delta += 360;

    return currentRotation + fullSpins + delta;
  }

  function startSpin() {
    if (isSpinning || !wheelDisc) return;
    isSpinning = true;

    getAudioContext();

    // Launch celebratory firecracker in the background sky as you spin!
    if (window.launchBgCracker) {
      window.launchBgCracker(true);
    }

    if (spinBtn) {
      spinBtn.disabled = true;
      spinBtn.innerHTML = `<i class="fa-solid fa-rotate-right fa-spin spin-btn-icon"></i> <span>SPINNING...</span>`;
    }
    if (spinStatusNote) {
      spinStatusNote.innerHTML = `🍀 <strong style="color: var(--gold-bright);">The wheel is spinning!</strong> Finding your lucky offer...`;
    }

    const targetRotation = calculateWinningAngle();
    const spinDurationMs = 6000;

    wheelDisc.style.transition = `transform ${spinDurationMs / 1000}s cubic-bezier(0.12, 0.99, 0.22, 1)`;
    wheelDisc.style.transform = `rotate(${targetRotation}deg)`;

    let tickDelay = 70;
    const totalDuration = spinDurationMs;
    const startTime = performance.now();

    function scheduleNextTick() {
      if (!isSpinning) return;
      const elapsed = performance.now() - startTime;
      const progress = elapsed / totalDuration;

      if (progress < 0.96) {
        playTickSound();
        if (pointerNeedle) {
          pointerNeedle.classList.add('ticking');
          setTimeout(() => pointerNeedle.classList.remove('ticking'), 30);
        }

        tickDelay = 65 + Math.pow(progress, 2.5) * 320;
        setTimeout(scheduleNextTick, tickDelay);
      }
    }

    setTimeout(scheduleNextTick, 80);

    setTimeout(() => {
      isSpinning = false;
      currentRotation = targetRotation;
      if (spinBtn) {
        spinBtn.disabled = false;
        spinBtn.innerHTML = `<i class="fa-solid fa-rotate-right spin-btn-icon"></i> <span>SPIN AGAIN</span>`;
      }
      if (spinStatusNote) {
        spinStatusNote.innerHTML = `🎉 <strong>Congratulations!</strong> You won <span style="color: var(--gold-bright);">${FIXED_WINNING_PRIZE.title}</span>!`;
      }

      if (window.triggerAppConfetti) window.triggerAppConfetti();
      playWinFanfare();

      if (window.launchBgCracker) {
        window.launchBgCracker(true);
        setTimeout(() => window.launchBgCracker(true), 400);
      }

      displayWinningResult(FIXED_WINNING_PRIZE);
    }, spinDurationMs);
  }

  if (spinBtn) spinBtn.addEventListener('click', startSpin);
  if (wheelDisc) {
    wheelDisc.addEventListener('click', () => {
      if (!isSpinning) startSpin();
    });
  }

  // Modal Display
  function displayWinningResult(prize) {
    if (winnerModal) winnerModal.classList.add('active');
  }

  function closeModal() {
    if (winnerModal) winnerModal.classList.remove('active');
  }

  if (modalCloseBtn) modalCloseBtn.addEventListener('click', closeModal);
  if (winnerModal) {
    winnerModal.addEventListener('click', (e) => {
      if (e.target === winnerModal) closeModal();
    });
  }

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && winnerModal && winnerModal.classList.contains('active')) {
      closeModal();
    }
  });

  if (copyCodeBtn) {
    copyCodeBtn.addEventListener('click', () => {
      const codeEl = document.getElementById('couponCode');
      const codeText = codeEl ? codeEl.textContent : "AARAA5OFF";
      navigator.clipboard.writeText(codeText).then(() => {
        const copyBtnText = document.getElementById('copyBtnText');
        if (copyBtnText) copyBtnText.textContent = "Copied! ✓";
        showToast(`Coupon "${codeText}" copied! Show at billing.`);
        setTimeout(() => {
          if (copyBtnText) copyBtnText.textContent = "Copy";
        }, 3000);
      }).catch(() => {
        showToast(`Coupon Code: ${codeText}`);
      });
    });
  }

  const toastPopup = document.getElementById('toastMessage');
  const toastText = document.getElementById('toastText');
  let toastTimeout = null;

  function showToast(msg) {
    if (!toastPopup || !toastText) return;
    toastText.textContent = msg;
    toastPopup.classList.add('show');
    if (toastTimeout) clearTimeout(toastTimeout);
    toastTimeout = setTimeout(() => {
      toastPopup.classList.remove('show');
    }, 3200);
  }

});
