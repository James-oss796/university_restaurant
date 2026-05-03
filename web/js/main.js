/* ============================================================
   University Restaurant – Main JS
   ============================================================ */

/* ── Carousel ─────────────────────────────────────────────── */
(function () {
    const track  = document.querySelector('.carousel-track');
    const slides = document.querySelectorAll('.carousel-slide');
    const dots   = document.querySelectorAll('.carousel-dot');
    if (!track || slides.length === 0) return;

    let current = 0;
    let timer;

    function goTo(index) {
        current = (index + slides.length) % slides.length;
        track.style.transform = 'translateX(-' + (current * 100) + '%)';
        dots.forEach(function (d, i) {
            d.classList.toggle('active', i === current);
        });
    }

    function next() { goTo(current + 1); }
    function prev() { goTo(current - 1); }

    function startAuto() {
        clearInterval(timer);
        timer = setInterval(next, 5000);
    }

    var nextBtn = document.querySelector('.carousel-arrow.next');
    var prevBtn = document.querySelector('.carousel-arrow.prev');
    if (nextBtn) nextBtn.addEventListener('click', function () { next(); startAuto(); });
    if (prevBtn) prevBtn.addEventListener('click', function () { prev(); startAuto(); });

    dots.forEach(function (dot, i) {
        dot.addEventListener('click', function () { goTo(i); startAuto(); });
    });

    goTo(0);
    startAuto();
})();


/* ── Category Tabs & meal filtering ──────────────────────── */
(function () {
    var tabBtns  = document.querySelectorAll('.tab-btn');
    var cards    = document.querySelectorAll('.meal-card');
    if (!tabBtns.length) return;

    tabBtns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            tabBtns.forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');

            var cat = btn.getAttribute('data-cat');
            cards.forEach(function (card) {
                if (cat === 'all' || card.getAttribute('data-cat') === cat) {
                    card.classList.remove('hidden');
                } else {
                    card.classList.add('hidden');
                }
            });
        });
    });
})();


/* ── Qty +/- controls ─────────────────────────────────────── */
(function () {
    document.addEventListener('click', function (e) {
        if (e.target.classList.contains('qty-btn')) {
            var btn   = e.target;
            var wrap  = btn.closest('.qty-control');
            var input = wrap ? wrap.querySelector('.qty-input') : null;
            if (!input) return;
            var val = parseInt(input.value, 10) || 0;
            if (btn.classList.contains('minus')) {
                val = Math.max(0, val - 1);
            } else {
                val = val + 1;
            }
            input.value = val;
            
            // Trigger change event to update the sidebar
            if (input.classList.contains('menu-qty')) {
                input.dispatchEvent(new Event('change', { bubbles: true }));
            }
        }
    });

    // Cart Sidebar Logic
    const uiItems = document.getElementById('cart-ui-items');
    const uiTotal = document.getElementById('cart-ui-total');
    if (uiItems && uiTotal) {
        document.addEventListener('change', function (e) {
            if (e.target.classList.contains('menu-qty')) {
                let currentTotal = 0;
                let htmlFragments = [];
                document.querySelectorAll('.menu-qty').forEach(function (inp) {
                    let qty = parseInt(inp.value, 10) || 0;
                    if (qty > 0) {
                        let price = parseFloat(inp.getAttribute('data-price')) || 0;
                        let name = inp.getAttribute('data-name');
                        let subtotal = qty * price;
                        currentTotal += subtotal;

                        htmlFragments.push(`
                            <div style="display:flex; justify-content:space-between; border-bottom:1px solid #f0f0f0; padding-bottom:4px;">
                                <div>
                                    <strong>${name}</strong>
                                    <span style="color:var(--mid); font-size:0.85em;"> x ${qty}</span>
                                </div>
                                <div style="font-weight:600;">KES ${subtotal}</div>
                            </div>
                        `);
                    }
                });

                if (htmlFragments.length > 0) {
                    uiItems.innerHTML = htmlFragments.join('');
                } else {
                    uiItems.innerHTML = '<p style="color:var(--mid); font-style:italic;">No items selected yet.</p>';
                }
                uiTotal.innerText = currentTotal;
            }
        });
    }
})();


/* ── Smooth scroll for anchor links ──────────────────────── */
(function () {
    document.querySelectorAll('a[href^="#"]').forEach(function (link) {
        link.addEventListener('click', function (e) {
            var target = document.querySelector(link.getAttribute('href'));
            if (target) {
                e.preventDefault();
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });
})();
