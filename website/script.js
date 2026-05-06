// Initialize Lucide icons
lucide.createIcons();

document.addEventListener('DOMContentLoaded', () => {
    
    // Theme Toggling Logic
    const themeBtn = document.getElementById('theme-toggle');
    const themeIcon = document.getElementById('theme-icon');
    
    // Check local storage for theme
    if(localStorage.getItem('lumina-theme') === 'light') {
        document.body.classList.add('light-mode');
        themeIcon.dataset.lucide = 'moon';
    } else {
        themeIcon.dataset.lucide = 'sun';
    }
    lucide.createIcons();

    themeBtn.addEventListener('click', () => {
        document.body.classList.toggle('light-mode');
        const isLight = document.body.classList.contains('light-mode');
        
        // Update Icon
        themeIcon.dataset.lucide = isLight ? 'moon' : 'sun';
        lucide.createIcons(); // re-render icon
        
        // Save preference
        localStorage.setItem('lumina-theme', isLight ? 'light' : 'dark');
    });

    // 1. Mouse tracking background glow
    const glow = document.getElementById('glow-cursor');
    let mouseX = window.innerWidth / 2;
    let mouseY = window.innerHeight / 2;
    
    document.addEventListener('mousemove', (e) => {
        mouseX = e.clientX;
        mouseY = e.clientY;
    });

    const animateGlow = () => {
        const currentX = parseFloat(glow.style.left) || window.innerWidth / 2;
        const currentY = parseFloat(glow.style.top) || window.innerHeight / 2;
        glow.style.left = `${currentX + (mouseX - currentX) * 0.1}px`;
        glow.style.top = `${currentY + (mouseY - currentY) * 0.1}px`;
        requestAnimationFrame(animateGlow);
    };
    animateGlow();

    // 2. 3D Tilt Effect for Phone Mockup
    const phoneContainer = document.querySelector('.phone-container');
    const phone = document.getElementById('tilt-phone');
    const bubbles = document.querySelectorAll('.floating-bubble');
    
    if (phoneContainer && phone) {
        phoneContainer.addEventListener('mousemove', (e) => {
            const rect = phoneContainer.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = ((y - centerY) / centerY) * -12;
            const rotateY = ((x - centerX) / centerX) * 12;
            
            phone.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
            
            bubbles.forEach((bubble, index) => {
                const speed = (index + 1) * 0.05;
                bubble.style.transform = `translate(${(centerX - x) * speed}px, ${(centerY - y) * speed}px)`;
            });
        });

        phoneContainer.addEventListener('mouseleave', () => {
            phone.style.transform = `perspective(1000px) rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)`;
            bubbles.forEach(bubble => bubble.style.transform = `translate(0px, 0px)`);
        });
    }

    // 3. Scroll Reveal Animations
    const scrollElements = document.querySelectorAll('[data-scroll]');
    scrollElements.forEach(el => {
        el.classList.add('hidden');
        if(el.classList.contains('hero-content')) {
            Array.from(el.children).forEach((child, index) => {
                child.style.transitionDelay = `${index * 0.1}s`;
            });
        }
    });

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.remove('hidden');
                entry.target.classList.add('visible');
            }
        });
    }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

    scrollElements.forEach(el => observer.observe(el));
    
    // 4. Navbar scroll effect
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.style.padding = '1rem 5%';
            navbar.style.boxShadow = '0 10px 30px rgba(0,0,0,0.2)';
        } else {
            navbar.style.padding = '1.5rem 5%';
            navbar.style.boxShadow = 'none';
        }
    });
    // 5. Live Audio Mixer Logic
    const masterPlayBtn = document.getElementById('master-play-btn');
    const masterPlayIcon = document.getElementById('master-play-icon');
    const rainAudio = document.getElementById('audio-rain');
    const fireAudio = document.getElementById('audio-fire');
    const rainSlider = document.getElementById('vol-rain');
    const fireSlider = document.getElementById('vol-fire');
    let isPlaying = false;

    if (masterPlayBtn) {
        masterPlayBtn.addEventListener('click', () => {
            if (!isPlaying) {
                // Initialize audio to user-indicated slider volumes
                rainAudio.volume = rainSlider.value / 100;
                fireAudio.volume = fireSlider.value / 100;
                
                // If both are 0, set rain to 50% automatically to prove it works
                if (rainSlider.value == 0 && fireSlider.value == 0) {
                    rainSlider.value = 50;
                    rainAudio.volume = 0.5;
                }

                rainAudio.play().catch(e => console.log(e));
                fireAudio.play().catch(e => console.log(e));
                masterPlayIcon.dataset.lucide = 'pause';
                isPlaying = true;
            } else {
                // Pause it
                rainAudio.pause();
                fireAudio.pause();
                masterPlayIcon.dataset.lucide = 'play';
                isPlaying = false;
            }
            lucide.createIcons();
        });

        rainSlider.addEventListener('input', (e) => {
            rainAudio.volume = e.target.value / 100;
            // auto-play if they start sliding from a paused state
            if (e.target.value > 0 && !isPlaying) masterPlayBtn.click();
        });
        fireSlider.addEventListener('input', (e) => {
            fireAudio.volume = e.target.value / 100;
            // auto-play if they start sliding from a paused state
            if (e.target.value > 0 && !isPlaying) masterPlayBtn.click();
        });
    }

    // 6. Pricing Table Toggle
    const btnMonthly = document.getElementById('btn-monthly');
    const btnLifetime = document.getElementById('btn-lifetime');
    const proPrice = document.getElementById('pro-price');

    if (btnMonthly && btnLifetime && proPrice) {
        btnMonthly.addEventListener('click', () => {
            btnMonthly.classList.add('active');
            btnLifetime.classList.remove('active');
            proPrice.innerHTML = '$4.99<span>/mo</span>';
        });
        btnLifetime.addEventListener('click', () => {
            btnLifetime.classList.add('active');
            btnMonthly.classList.remove('active');
            proPrice.innerHTML = '$49.99<span>/life</span>';
        });
    }

    // 7. FAQ Accordion Engine
    const faqQuestions = document.querySelectorAll('.faq-question');
    faqQuestions.forEach(question => {
        question.addEventListener('click', () => {
            const faqItem = question.parentElement;
            const answer = question.nextElementSibling;
            
            // Close other open panels
            const allItems = document.querySelectorAll('.faq-item');
            allItems.forEach(item => {
                if (item !== faqItem && item.classList.contains('active')) {
                    item.classList.remove('active');
                    item.querySelector('.faq-answer').style.maxHeight = null;
                }
            });

            // Toggle current panel
            faqItem.classList.toggle('active');
            if (faqItem.classList.contains('active')) {
                answer.style.maxHeight = answer.scrollHeight + "px";
            } else {
                answer.style.maxHeight = null;
            }
        });
    });

    // 8. Ambient Particle System (Appends stars, ashes, rain, and leaves)
    const initAmbientParticles = () => {
        const canvas = document.createElement('div');
        canvas.className = 'ambient-canvas';
        document.body.appendChild(canvas);

        const types = ['ash', 'rain', 'star', 'leaf'];
        const particleCount = 100; 
        const wrappers = [];

        for (let i = 0; i < particleCount; i++) {
            const wrapper = document.createElement('div');
            wrapper.className = 'particle-wrapper';
            
            const p = document.createElement('div');
            const type = types[Math.floor(Math.random() * types.length)];
            p.className = `particle particle-${type}`;
            
            const size = Math.random() * 5 + 2; 
            const left = Math.random() * 100;
            const top = Math.random() * 100; // Distribute vertically across absolute canvas!
            const duration = Math.random() * 15 + 10; 
            const delay = Math.random() * 20; 

            if (type !== 'rain') {
                p.style.width = `${size}px`;
                p.style.height = `${size}px`;
            } else {
                p.style.width = '2px'; // make rain thicker
                p.style.height = `${size * 5}px`;
            }

            wrapper.style.left = `${left}vw`;
            wrapper.style.top = `${top}%`;
            p.style.animationDuration = `${duration}s`;
            p.style.animationDelay = `-${delay}s`;

            // Parallax factor
            wrapper.dataset.speed = (Math.random() * 0.5) + 0.1; 
            wrapper.dataset.windX = (Math.random() * 0.3) - 0.15;
            
            wrapper.appendChild(p);
            canvas.appendChild(wrapper);
            wrappers.push(wrapper);
        }

        // Parallax Scroll Breeze Effect
        let scrollY = window.scrollY;
        let lastScrollY = scrollY;
        let ticking = false;

        window.addEventListener('scroll', () => {
            scrollY = window.scrollY;
            const scrollDelta = scrollY - lastScrollY;
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    wrappers.forEach(w => {
                        const speed = parseFloat(w.dataset.speed);
                        const windX = parseFloat(w.dataset.windX);
                        // Convert previous transform to values or just use absolute scrollY offset
                        // We use the absolute scrollY to push them up slightly faster/slower than natural scroll + horizontal breeze
                        const yOffset = scrollY * speed * 0.4;
                        const xOffset = scrollY * windX;
                        w.style.transform = `translate3d(${xOffset}px, ${yOffset}px, 0)`;
                    });
                    ticking = false;
                });
                ticking = true;
            }
        });
    };
    initAmbientParticles();

});
