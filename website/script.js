// ── Inline SVG icon helpers (avoids lucide re-render issues on cached elements) ──
const SVG_PLAY  = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>`;
const SVG_PAUSE = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>`;
const SVG_VOL_HIGH = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>`;
const SVG_VOL_LOW  = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>`;
const SVG_VOL_MUTE = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><line x1="23" y1="9" x2="17" y2="15"/><line x1="17" y1="9" x2="23" y2="15"/></svg>`;
const SVG_SPEAKER  = `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="2" width="16" height="20" rx="2"/><circle cx="12" cy="14" r="4"/><line x1="12" y1="6" x2="12.01" y2="6"/></svg>`;

function volIcon(v) { return v === 0 ? SVG_VOL_MUTE : v < 0.5 ? SVG_VOL_LOW : SVG_VOL_HIGH; }

// Initialise Lucide for all static icons
lucide.createIcons();

document.addEventListener('DOMContentLoaded', () => {

    // ── Theme toggle ──────────────────────────────────────────────────────────
    const themeBtn  = document.getElementById('theme-toggle');
    const themeIcon = document.getElementById('theme-icon');
    if (localStorage.getItem('lumina-theme') === 'light') {
        document.body.classList.add('light-mode');
        themeIcon.dataset.lucide = 'moon';
    } else {
        themeIcon.dataset.lucide = 'sun';
    }
    lucide.createIcons();
    themeBtn.addEventListener('click', () => {
        document.body.classList.toggle('light-mode');
        const isLight = document.body.classList.contains('light-mode');
        themeIcon.dataset.lucide = isLight ? 'moon' : 'sun';
        lucide.createIcons();
        localStorage.setItem('lumina-theme', isLight ? 'light' : 'dark');
    });

    // ── Cursor glow ───────────────────────────────────────────────────────────
    const glow = document.getElementById('glow-cursor');
    let mouseX = window.innerWidth / 2, mouseY = window.innerHeight / 2;
    document.addEventListener('mousemove', e => { mouseX = e.clientX; mouseY = e.clientY; });
    const animateGlow = () => {
        if (!glow) return;
        const cx = parseFloat(glow.style.left) || window.innerWidth  / 2;
        const cy = parseFloat(glow.style.top)  || window.innerHeight / 2;
        glow.style.left = `${cx + (mouseX - cx) * 0.1}px`;
        glow.style.top  = `${cy + (mouseY - cy) * 0.1}px`;
        requestAnimationFrame(animateGlow);
    };
    animateGlow();

    // ── Phone 3-D tilt ────────────────────────────────────────────────────────
    const phoneContainer = document.querySelector('.phone-container');
    const phone   = document.getElementById('tilt-phone');
    const bubbles = document.querySelectorAll('.floating-bubble');
    if (phoneContainer && phone) {
        phoneContainer.addEventListener('mousemove', e => {
            const r  = phoneContainer.getBoundingClientRect();
            const cx = r.width / 2, cy = r.height / 2;
            const x  = e.clientX - r.left, y = e.clientY - r.top;
            phone.style.transform = `perspective(1000px) rotateX(${((y-cy)/cy)*-12}deg) rotateY(${((x-cx)/cx)*12}deg) scale3d(1.02,1.02,1.02)`;
            bubbles.forEach((b, i) => {
                const s = (i + 1) * 0.05;
                b.style.transform = `translate(${(cx-x)*s}px,${(cy-y)*s}px)`;
            });
        });
        phoneContainer.addEventListener('mouseleave', () => {
            phone.style.transform = 'perspective(1000px) rotateX(0deg) rotateY(0deg) scale3d(1,1,1)';
            bubbles.forEach(b => b.style.transform = 'translate(0,0)');
        });
    }

    // ── Scroll-reveal ─────────────────────────────────────────────────────────
    document.querySelectorAll('[data-scroll]').forEach(el => {
        el.classList.add('hidden');
        if (el.classList.contains('hero-content')) {
            Array.from(el.children).forEach((c, i) => c.style.transitionDelay = `${i * 0.1}s`);
        }
    });
    const revealObs = new IntersectionObserver(entries => {
        entries.forEach(e => {
            if (e.isIntersecting) { e.target.classList.remove('hidden'); e.target.classList.add('visible'); }
        });
    }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
    document.querySelectorAll('[data-scroll]').forEach(el => revealObs.observe(el));

    // ── Navbar shrink on scroll ───────────────────────────────────────────────
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        navbar.style.padding   = window.scrollY > 50 ? '1rem 5%' : '1.5rem 5%';
        navbar.style.boxShadow = window.scrollY > 50 ? '0 10px 30px rgba(0,0,0,0.2)' : 'none';
    });

    // ── Live Audio Sandbox ────────────────────────────────────────────────────
    const masterPlayBtn  = document.getElementById('master-play-btn');
    const rainAudio      = document.getElementById('audio-rain');
    const fireAudio      = document.getElementById('audio-fire');
    const rainSlider     = document.getElementById('vol-rain');
    const fireSlider     = document.getElementById('vol-fire');
    const mixerMasterVol = document.getElementById('mixer-master-vol');
    const mixerVolBtn    = document.getElementById('mixer-vol-btn');
    const speakerBtn     = document.getElementById('speaker-device-btn');
    const speakerDropdown = document.getElementById('speaker-dropdown');
    const speakerList    = document.getElementById('speaker-devices-list');
    let isPlaying = false;
    let mixerLastVol = 85;

    // Set initial button icons
    if (masterPlayBtn) masterPlayBtn.innerHTML = SVG_PLAY;
    if (mixerVolBtn)   mixerVolBtn.innerHTML   = SVG_VOL_HIGH;
    if (speakerBtn)    speakerBtn.innerHTML    = SVG_SPEAKER;

    function getMasterVol() { return mixerMasterVol ? mixerMasterVol.value / 100 : 1; }

    if (masterPlayBtn) {
        masterPlayBtn.addEventListener('click', () => {
            const mv = getMasterVol();
            if (!isPlaying) {
                rainAudio.volume = (rainSlider.value / 100) * mv;
                fireAudio.volume = (fireSlider.value / 100) * mv;
                if (+rainSlider.value === 0 && +fireSlider.value === 0) {
                    rainSlider.value = 50;
                    rainAudio.volume = 0.5 * mv;
                }
                rainAudio.play().catch(() => {});
                fireAudio.play().catch(() => {});
                masterPlayBtn.innerHTML = SVG_PAUSE;
                isPlaying = true;
            } else {
                rainAudio.pause();
                fireAudio.pause();
                masterPlayBtn.innerHTML = SVG_PLAY;
                isPlaying = false;
            }
        });

        rainSlider.addEventListener('input', e => {
            rainAudio.volume = (e.target.value / 100) * getMasterVol();
            if (+e.target.value > 0 && !isPlaying) masterPlayBtn.click();
        });
        fireSlider.addEventListener('input', e => {
            fireAudio.volume = (e.target.value / 100) * getMasterVol();
            if (+e.target.value > 0 && !isPlaying) masterPlayBtn.click();
        });
    }

    // ── Mixer master volume ───────────────────────────────────────────────────
    if (mixerMasterVol && mixerVolBtn) {
        mixerMasterVol.addEventListener('input', () => {
            const mv = getMasterVol();
            mixerLastVol = +mixerMasterVol.value;
            if (isPlaying) {
                rainAudio.volume = (rainSlider.value / 100) * mv;
                fireAudio.volume = (fireSlider.value / 100) * mv;
            }
            mixerVolBtn.innerHTML = volIcon(mv);
        });

        mixerVolBtn.addEventListener('click', () => {
            if (+mixerMasterVol.value > 0) {
                mixerLastVol = +mixerMasterVol.value;
                mixerMasterVol.value = 0;
                rainAudio.volume = 0;
                fireAudio.volume = 0;
                mixerVolBtn.innerHTML = SVG_VOL_MUTE;
            } else {
                mixerMasterVol.value = mixerLastVol;
                const mv = mixerLastVol / 100;
                if (isPlaying) {
                    rainAudio.volume = (rainSlider.value / 100) * mv;
                    fireAudio.volume = (fireSlider.value / 100) * mv;
                }
                mixerVolBtn.innerHTML = volIcon(mv);
            }
        });
    }

    // ── Speaker / audio-output device selector ────────────────────────────────
    if (speakerBtn && speakerDropdown) {
        const allMixerAudios = () => [rainAudio, fireAudio];

        speakerBtn.addEventListener('click', async e => {
            e.stopPropagation();
            if (speakerDropdown.style.display === 'block') {
                speakerDropdown.style.display = 'none';
                return;
            }
            speakerList.innerHTML = '<p class="speaker-no-devices">Loading devices…</p>';
            speakerDropdown.style.display = 'block';

            try {
                if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
                    throw new Error('unsupported');
                }
                // Need at least one audio element playing or a getUserMedia grant
                // to get labelled device names in most browsers
                const devices  = await navigator.mediaDevices.enumerateDevices();
                const outputs  = devices.filter(d => d.kind === 'audiooutput');

                if (!outputs.length) {
                    speakerList.innerHTML = '<p class="speaker-no-devices">No audio output devices found.</p>';
                    return;
                }

                speakerList.innerHTML = '';
                let activeSinkId = 'default';

                outputs.forEach((device, idx) => {
                    const label = device.label || `Speaker ${idx + 1}`;
                    const btn   = document.createElement('button');
                    btn.className = 'speaker-device-item' + (device.deviceId === activeSinkId ? ' active' : '');
                    btn.innerHTML = `<span class="device-dot"></span>${label}`;
                    btn.addEventListener('click', async () => {
                        const targets = [
                            ...allMixerAudios(),
                            ...document.querySelectorAll('.sound-card audio')
                        ];
                        for (const a of targets) {
                            if (typeof a.setSinkId === 'function') {
                                try { await a.setSinkId(device.deviceId); } catch (_) {}
                            }
                        }
                        document.querySelectorAll('.speaker-device-item').forEach(b => b.classList.remove('active'));
                        btn.classList.add('active');
                        activeSinkId = device.deviceId;
                        speakerDropdown.style.display = 'none';
                    });
                    speakerList.appendChild(btn);
                });
            } catch (_) {
                speakerList.innerHTML = `<p class="speaker-no-devices">Audio output selection not supported in this browser. Use system volume to adjust.</p>`;
            }
        });

        document.addEventListener('click', e => {
            if (speakerDropdown.style.display === 'block' &&
                !speakerDropdown.contains(e.target) &&
                !speakerBtn.contains(e.target)) {
                speakerDropdown.style.display = 'none';
            }
        });
    }

    // ── Pricing toggle ────────────────────────────────────────────────────────
    const btnMonthly = document.getElementById('btn-monthly');
    const btnLifetime = document.getElementById('btn-lifetime');
    const proPrice   = document.getElementById('pro-price');
    if (btnMonthly && btnLifetime && proPrice) {
        btnMonthly.addEventListener('click', () => {
            btnMonthly.classList.add('active'); btnLifetime.classList.remove('active');
            proPrice.innerHTML = '$4.99<span>/mo</span>';
        });
        btnLifetime.addEventListener('click', () => {
            btnLifetime.classList.add('active'); btnMonthly.classList.remove('active');
            proPrice.innerHTML = '$49.99<span>/life</span>';
        });
    }

    // ── FAQ accordion ─────────────────────────────────────────────────────────
    document.querySelectorAll('.faq-question').forEach(q => {
        q.addEventListener('click', () => {
            const item   = q.parentElement;
            const answer = q.nextElementSibling;
            document.querySelectorAll('.faq-item.active').forEach(i => {
                if (i !== item) { i.classList.remove('active'); i.querySelector('.faq-answer').style.maxHeight = null; }
            });
            item.classList.toggle('active');
            answer.style.maxHeight = item.classList.contains('active') ? answer.scrollHeight + 'px' : null;
        });
    });

    // ── Free Sound Preview Cards (30-second timer + volume) ───────────────────
    const PREVIEW_SEC = 30;

    document.querySelectorAll('.sound-card').forEach(card => {
        const audio    = card.querySelector('audio');
        const playBtn  = card.querySelector('.sound-play-btn');
        const fillBar  = card.querySelector('.sound-progress-fill');
        const timerLbl = card.querySelector('.sound-timer');
        const overlay  = card.querySelector('.sound-expired-overlay');
        const volBtn   = card.querySelector('.sound-vol-btn');
        const volSlider = card.querySelector('.sound-vol-slider');
        let elapsed = 0, ticker = null, lastVol = 85;

        // Set initial icons
        playBtn.innerHTML = SVG_PLAY;
        volBtn.innerHTML  = SVG_VOL_HIGH;
        audio.volume = 0.85;

        // Volume slider
        volSlider.addEventListener('input', () => {
            const v = +volSlider.value / 100;
            audio.volume = v;
            lastVol = +volSlider.value;
            volBtn.innerHTML = volIcon(v);
        });

        // Mute toggle
        volBtn.addEventListener('click', () => {
            if (+volSlider.value > 0) {
                lastVol = +volSlider.value;
                audio.volume = 0;
                volSlider.value = 0;
                volBtn.innerHTML = SVG_VOL_MUTE;
            } else {
                audio.volume = lastVol / 100;
                volSlider.value = lastVol;
                volBtn.innerHTML = volIcon(lastVol / 100);
            }
        });

        function fmt(s) { return `0:${String(Math.floor(s)).padStart(2, '0')}`; }

        function stopCard(expired) {
            clearInterval(ticker); ticker = null;
            audio.pause();
            card.classList.remove('is-playing');
            playBtn.innerHTML = SVG_PLAY;
            if (expired) overlay.style.display = 'flex';
        }

        playBtn.addEventListener('click', () => {
            if (overlay.style.display === 'flex') return;

            if (card.classList.contains('is-playing')) {
                stopCard(false);
            } else {
                // Pause any other playing card
                document.querySelectorAll('.sound-card.is-playing').forEach(other => {
                    other.querySelector('.sound-play-btn').click();
                });
                audio.currentTime = 0;
                audio.play().catch(() => {});
                card.classList.add('is-playing');
                playBtn.innerHTML = SVG_PAUSE;

                ticker = setInterval(() => {
                    elapsed++;
                    fillBar.style.width = (elapsed / PREVIEW_SEC * 100) + '%';
                    timerLbl.textContent = `${fmt(elapsed)} / 0:30`;
                    if (elapsed >= PREVIEW_SEC) { stopCard(true); elapsed = 0; }
                }, 1000);
            }
        });
    });

    // ── Ambient particle system ───────────────────────────────────────────────
    const initParticles = () => {
        const canvas = document.createElement('div');
        canvas.className = 'ambient-canvas';
        document.body.appendChild(canvas);
        const types = ['ash','rain','star','leaf'];
        const wrappers = [];
        for (let i = 0; i < 100; i++) {
            const wrap = document.createElement('div');
            wrap.className = 'particle-wrapper';
            const p = document.createElement('div');
            const type = types[Math.floor(Math.random() * types.length)];
            p.className = `particle particle-${type}`;
            const size = Math.random() * 5 + 2;
            if (type !== 'rain') { p.style.width = p.style.height = `${size}px`; }
            else { p.style.width = '2px'; p.style.height = `${size * 5}px`; }
            wrap.style.left = `${Math.random() * 100}vw`;
            wrap.style.top  = `${Math.random() * 100}%`;
            p.style.animationDuration = `${Math.random() * 15 + 10}s`;
            p.style.animationDelay   = `-${Math.random() * 20}s`;
            wrap.dataset.speed = (Math.random() * 0.5) + 0.1;
            wrap.dataset.windX = (Math.random() * 0.3) - 0.15;
            wrap.appendChild(p);
            canvas.appendChild(wrap);
            wrappers.push(wrap);
        }
        let ticking = false;
        window.addEventListener('scroll', () => {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    const sy = window.scrollY;
                    wrappers.forEach(w => {
                        w.style.transform = `translate3d(${sy * w.dataset.windX}px,${sy * w.dataset.speed * 0.4}px,0)`;
                    });
                    ticking = false;
                });
                ticking = true;
            }
        });
    };
    initParticles();
});
