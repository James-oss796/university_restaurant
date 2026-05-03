<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.MenuItem, model.User, model.dao.MenuItemDAO" %>
<%
    MenuItemDAO dao   = new MenuItemDAO();
    List<MenuItem> items = dao.getAllMenuItems();
    request.setAttribute("items", items);
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Menu - University Restaurant</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Epilogue:wght@400;700;800;900&family=Be+Vietnam+Pro:wght@400;500;700&display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "error": "#ba1a1a",
                        "on-tertiary": "#ffffff",
                        "secondary": "#954a00",
                        "primary": "#b90027",
                        "on-surface": "#1c1b1b",
                        "inverse-surface": "#313030",
                        "surface-bright": "#fcf9f8",
                        "surface-container": "#f0eded",
                        "secondary-fixed-dim": "#ffb785",
                        "secondary-container": "#fd8100",
                        "on-surface-variant": "#5d3f3e",
                        "tertiary-fixed-dim": "#f6bf22",
                        "tertiary-container": "#916e00",
                        "on-tertiary-fixed": "#251a00",
                        "on-secondary-fixed-variant": "#723700",
                        "on-tertiary-container": "#fff9f5",
                        "surface-tint": "#bf0029",
                        "primary-container": "#e31837",
                        "secondary-fixed": "#ffdcc6",
                        "on-secondary": "#ffffff",
                        "on-secondary-container": "#5d2c00",
                        "surface-container-highest": "#e5e2e1",
                        "on-primary-container": "#fffaf9",
                        "surface-container-high": "#eae7e7",
                        "surface-dim": "#dcd9d9",
                        "surface-container-lowest": "#ffffff",
                        "on-error": "#ffffff",
                        "tertiary-fixed": "#ffdf99",
                        "on-primary": "#ffffff",
                        "outline-variant": "#e6bdbb",
                        "on-background": "#1c1b1b",
                        "on-tertiary-fixed-variant": "#5a4300",
                        "primary-fixed": "#ffdad8",
                        "outline": "#916e6d",
                        "surface-container-low": "#f6f3f2",
                        "inverse-primary": "#ffb3b1",
                        "tertiary": "#735600",
                        "on-primary-fixed": "#410007",
                        "inverse-on-surface": "#f3f0ef",
                        "on-secondary-fixed": "#301400",
                        "surface-variant": "#e5e2e1",
                        "surface": "#fcf9f8",
                        "on-error-container": "#93000a",
                        "background": "#fcf9f8",
                        "error-container": "#ffdad6",
                        "primary-fixed-dim": "#ffb3b1",
                        "on-primary-fixed-variant": "#92001d"
                    },
                    "fontFamily": {
                        "display-xl": ["Epilogue"],
                        "body-md": ["Be Vietnam Pro"],
                        "body-lg": ["Be Vietnam Pro"],
                        "headline-lg": ["Epilogue"],
                        "label-bold": ["Be Vietnam Pro"],
                        "headline-md": ["Epilogue"]
                    }
                },
            },
        }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .app-shadow-l1 { box-shadow: 0 4px 12px rgba(227,24,55,0.05); }
        .app-shadow-l2 { box-shadow: 0 8px 20px rgba(227,24,55,0.1); }
        body { scroll-behavior: smooth; }
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        
        /* Hide number input spinners */
        input[type=number]::-webkit-inner-spin-button, 
        input[type=number]::-webkit-outer-spin-button { 
            -webkit-appearance: none; 
            margin: 0; 
        }
        input[type=number] {
            -moz-appearance: textfield;
            appearance: textfield;
        }
    </style>
</head>
<body class="bg-background font-body-md text-on-background">

<!-- TopAppBar -->
<nav class="flex justify-between items-center px-8 py-4 w-full sticky top-0 z-50 bg-white border-b border-neutral-100 shadow-[0_4px_12px_rgba(227,24,55,0.05)] font-['Epilogue'] antialiased">
<div class="flex items-center gap-8">
<a href="${pageContext.request.contextPath}/" class="text-2xl font-black italic tracking-tighter text-[#E31837]">University Restaurant</a>
<div class="hidden md:flex relative items-center">
<span class="material-symbols-outlined absolute left-3 text-neutral-400">search</span>
<input class="bg-surface-container-low border-0 border-b-2 border-neutral-200 focus:border-[#E31837] focus:ring-0 rounded-none pl-10 pr-4 py-2 w-64 transition-all" placeholder="Search for your cravings..." type="text"/>
</div>
</div>
<div class="hidden md:flex items-center gap-8">
<a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/">Home</a>
<a class="text-[#E31837] border-b-2 border-[#E31837] pb-1 font-bold" href="${pageContext.request.contextPath}/menu.jsp">Menu</a>
<a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/OrderServlet?action=viewOrders">Orders</a>
<a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/QueueServlet">Queue</a>
</div>
<div class="flex items-center gap-4">
<span class="text-sm font-bold text-neutral-600 hidden md:inline ml-4">👤 ${sessionScope.user.name}</span>
<a href="${pageContext.request.contextPath}/LogoutServlet" class="material-symbols-outlined p-2 flex items-center justify-center rounded-full hover:bg-neutral-50 transition-all text-neutral-600" title="Logout">logout</a>
</div>
</nav>

<div class="max-w-[1440px] mx-auto pb-24">

<!-- Page Header -->
<div class="bg-gradient-to-br from-neutral-900 to-[#b90027] pt-12 pb-16 px-8 text-white relative overflow-hidden mb-12 shadow-md">
    <div class="absolute right-0 top-0 opacity-10 pointer-events-none">
        <span class="material-symbols-outlined text-[300px] absolute -top-16 -right-16">local_dining</span>
    </div>
    <div class="max-w-4xl relative z-10">
        <span class="bg-white/20 text-white font-bold px-4 py-1 rounded-full text-sm mb-4 inline-block backdrop-blur-md">Full Menu</span>
        <h1 class="font-display-xl text-4xl md:text-5xl font-extrabold mb-4">Today's Available Meals</h1>
        <p class="font-body-lg text-lg text-white/90">Select quantities and place your order — we'll assign a queue number for quick campus pickup.</p>
    </div>
</div>

<div class="px-8">
    <form action="${pageContext.request.contextPath}/OrderServlet" method="post" id="orderForm">
        <div class="flex flex-col lg:flex-row gap-8 items-start">
            
            <!-- Left Side: Menu Grid -->
            <div class="w-full lg:w-3/4">
                
                <!-- Category Tabs -->
                <div class="tabs-wrapper flex gap-4 overflow-x-auto pb-6 mb-4 no-scrollbar">
                    <button type="button" class="tab-btn active flex-shrink-0 flex items-center gap-2 bg-[#E31837] text-white px-6 py-3 rounded-full font-bold shadow-md" data-cat="all">
                        <span class="material-symbols-outlined">restaurant</span> All Items
                    </button>
                    <button type="button" class="tab-btn flex-shrink-0 flex items-center gap-2 bg-white border border-neutral-200 px-6 py-3 rounded-full font-bold hover:bg-neutral-50 text-neutral-600" data-cat="chicken">
                        <span class="material-symbols-outlined">kebab_dining</span> Chicken
                    </button>
                    <button type="button" class="tab-btn flex-shrink-0 flex items-center gap-2 bg-white border border-neutral-200 px-6 py-3 rounded-full font-bold hover:bg-neutral-50 text-neutral-600" data-cat="rice">
                        <span class="material-symbols-outlined">rice_bowl</span> Rice & Ugali
                    </button>
                    <button type="button" class="tab-btn flex-shrink-0 flex items-center gap-2 bg-white border border-neutral-200 px-6 py-3 rounded-full font-bold hover:bg-neutral-50 text-neutral-600" data-cat="snacks">
                        <span class="material-symbols-outlined">bakery_dining</span> Snacks
                    </button>
                    <button type="button" class="tab-btn flex-shrink-0 flex items-center gap-2 bg-white border border-neutral-200 px-6 py-3 rounded-full font-bold hover:bg-neutral-50 text-neutral-600" data-cat="drinks">
                        <span class="material-symbols-outlined">local_drink</span> Drinks
                    </button>
                </div>

                <!-- Meals Grid -->
                <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6 meals-grid">
                <c:forEach var="item" items="${items}">
                <c:set var="nameLower" value="${fn:toLowerCase(item.name)}" />
                <c:set var="cat" value="all" />
                <c:choose>
                    <c:when test="${fn:contains(nameLower, 'chicken') || fn:contains(nameLower, 'nyama') || fn:contains(nameLower, 'fish') || fn:contains(nameLower, 'tilapia')}"><c:set var="cat" value="chicken" /></c:when>
                    <c:when test="${fn:contains(nameLower, 'rice') || fn:contains(nameLower, 'pilau') || fn:contains(nameLower, 'ugali')}"><c:set var="cat" value="rice" /></c:when>
                    <c:when test="${fn:contains(nameLower, 'chips') || fn:contains(nameLower, 'chapati') || fn:contains(nameLower, 'beans') || fn:contains(nameLower, 'samosa') || fn:contains(nameLower, 'smocha')}"><c:set var="cat" value="snacks" /></c:when>
                    <c:when test="${fn:contains(nameLower, 'juice') || fn:contains(nameLower, 'tea') || fn:contains(nameLower, 'soda')}"><c:set var="cat" value="drinks" /></c:when>
                </c:choose>
                
                <c:set var="imgUrl" value="${item.imageUrl}" />
                <c:if test="${empty imgUrl}">
                    <c:set var="imgUrl" value="images/carousel2.jpg" />
                </c:if>
                <c:if test="${not empty imgUrl && !fn:startsWith(imgUrl, 'http')}">
                    <c:set var="imgUrl" value="${pageContext.request.contextPath}/${imgUrl}" />
                </c:if>

                <div class="meal-card group bg-white rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(227,24,55,0.05)] border border-neutral-100 hover:shadow-[0_8px_20px_rgba(227,24,55,0.1)] transition-all duration-300 flex flex-col justify-between" data-cat="${cat}">
                    <div>
                        <div class="relative h-48 overflow-hidden bg-neutral-100 flex items-center justify-center">
                            <img class="meal-card-img w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" src="${imgUrl}" alt="${item.name}" loading="lazy" />
                        </div>
                        <div class="p-5 pb-0">
                            <h3 class="font-headline-md text-xl font-bold mb-1">${item.name}</h3>
                            <p class="font-body-md text-neutral-500 text-sm line-clamp-2 mb-4" style="display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${item.description}</p>
                        </div>
                    </div>
                    
                    <div class="p-5 pt-0 mt-auto border-t border-neutral-50 pt-4 flex flex-col gap-4">
                        <div class="flex justify-between items-end">
                            <div>
                                <div class="text-xs font-bold text-neutral-400 uppercase tracking-wider mb-1">${item.mealPeriod}</div>
                                <div class="font-display-xl text-2xl font-black text-[#E31837]">KES ${item.price}</div>
                            </div>
                        </div>
                        
                        <div class="qty-control flex items-center justify-between bg-surface-container-low rounded-xl p-1 border border-neutral-200">
                            <button type="button" class="qty-btn minus w-10 h-10 flex items-center justify-center text-neutral-600 hover:bg-white hover:shadow-sm rounded-lg transition-all font-bold text-xl active:scale-95">−</button>
                            <input class="qty-input menu-qty w-12 text-center bg-transparent border-0 font-bold text-lg text-neutral-800 focus:ring-0 p-0" type="number"
                                   name="qty_${item.menuId}"
                                   data-price="${item.price}"
                                   data-name="${item.name}"
                                   value="0" min="0" />
                            <button type="button" class="qty-btn plus w-10 h-10 flex items-center justify-center bg-[#E31837] text-white shadow-sm rounded-lg transition-all font-bold text-xl active:scale-95 hover:bg-[#b90027]">+</button>
                        </div>
                    </div>
                </div>
                </c:forEach>
                </div><!-- /meals-grid -->

            </div>

            <!-- Right Side: Cart Sidebar -->
            <div class="w-full lg:w-1/4">
                <div class="cart-sidebar sticky top-[100px] bg-white p-6 rounded-2xl shadow-[0_8px_30px_rgba(227,24,55,0.08)] border border-[#E31837]/10 flex flex-col h-[calc(100vh-140px)]">
                    <h3 class="font-headline-md text-2xl font-bold flex items-center gap-2 pb-4 border-b-2 border-neutral-100 mb-4">
                        <span class="material-symbols-outlined text-[#E31837]">shopping_bag</span> Your Order
                    </h3>
                    
                    <div id="cart-ui-items" class="flex-grow overflow-y-auto no-scrollbar font-body-md text-sm text-neutral-600 flex flex-col gap-3">
                        <div class="flex flex-col items-center justify-center h-full text-neutral-400 opacity-60">
                            <span class="material-symbols-outlined text-5xl mb-2">restaurant_menu</span>
                            <p class="italic text-center">Add some zest to your cart!</p>
                        </div>
                    </div>
                    
                    <div class="pt-6 mt-4 border-t-2 border-neutral-100">
                        <div class="flex justify-between items-center mb-6">
                            <span class="font-bold text-neutral-500 uppercase tracking-widest text-sm">Total</span>
                            <span class="font-display-xl text-3xl font-black text-[#E31837]">KES <span id="cart-ui-total">0</span></span>
                        </div>
                        <button type="submit" class="w-full bg-[#E31837] text-white py-4 rounded-xl font-bold text-lg shadow-[0_4px_14px_rgba(227,24,55,0.4)] hover:shadow-[0_6px_20px_rgba(227,24,55,0.6)] hover:translate-y-[-2px] transition-all active:scale-[0.98] flex items-center justify-center gap-2">
                            Place Order <span class="material-symbols-outlined">arrow_forward</span>
                        </button>
                    </div>
                </div>
            </div>

        </div><!-- /flex container -->
    </form>
</div>

</div>

<!-- Footer -->
<footer class="bg-neutral-950 text-white pt-20 pb-10 px-8 font-body-md mt-12 w-full relative z-10 text-left">
<div class="max-w-[1440px] mx-auto grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
<div class="col-span-1 md:col-span-1">
<span class="text-3xl font-black italic tracking-tighter text-[#E31837] block mb-6">University Restaurant</span>
<p class="text-neutral-400 leading-relaxed text-sm">Providing high-quality, flavorful meals to the university community. We believe in fast service without compromising on the premium restaurant taste.</p>
</div>
<div>
<h4 class="font-bold text-lg mb-4 text-white">Quick Links</h4>
<ul class="space-y-3 text-neutral-400 text-sm">
<li><a class="hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/menu.jsp">Menu</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Today's Deals</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/OrderServlet?action=viewOrders">Track Order</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Student Loyalty</a></li>
</ul>
</div>
<div>
<h4 class="font-bold text-lg mb-4 text-white">Support</h4>
<ul class="space-y-3 text-neutral-400 text-sm">
<li><a class="hover:text-[#E31837] transition-colors" href="#">Help Center</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Terms of Service</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Privacy Policy</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Contact Us</a></li>
</ul>
</div>
<div>
<h4 class="font-bold text-lg mb-4 text-white">Contact Info</h4>
<div class="space-y-3 text-neutral-400 text-sm">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-[#E31837] text-xl">location_on</span>
<span>Main Campus, Central Plaza</span>
</div>
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-[#E31837] text-xl">call</span>
<span>+254 700 000 000</span>
</div>
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-[#E31837] text-xl">mail</span>
<span>orders@universityrestaurant.ac.ke</span>
</div>
</div>
</div>
</div>
<div class="border-t border-neutral-800 pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-neutral-500 text-xs max-w-[1440px] mx-auto">
<p>© 2026 University Restaurant University Restaurant. All rights reserved.</p>
<div class="flex gap-6">
<a class="hover:text-white transition-colors" href="#">Instagram</a>
<a class="hover:text-white transition-colors" href="#">Twitter</a>
<a class="hover:text-white transition-colors" href="#">Facebook</a>
</div>
</div>
</footer>

<script src="${pageContext.request.contextPath}/js/main.js" defer></script>
<!-- Category filtering script adapted for Tailwind classes -->
<script>
document.addEventListener("DOMContentLoaded", function() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    const mealCards = document.querySelectorAll('.meal-card');
    
    // Check if there's a category in URL
    const urlParams = new URLSearchParams(window.location.search);
    const catParam = urlParams.get('cat');
    if(catParam) {
        filterMenu(catParam);
        
        tabBtns.forEach(btn => {
            btn.classList.remove('bg-[#E31837]', 'text-white', 'shadow-md');
            btn.classList.add('bg-white', 'text-neutral-600');
            if(btn.dataset.cat === catParam) {
                btn.classList.add('bg-[#E31837]', 'text-white', 'shadow-md');
                btn.classList.remove('bg-white', 'text-neutral-600');
            }
        });
    }

    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            // style tabs
            tabBtns.forEach(b => {
                b.classList.remove('bg-[#E31837]', 'text-white', 'shadow-md');
                b.classList.add('bg-white', 'text-neutral-600');
            });
            btn.classList.add('bg-[#E31837]', 'text-white', 'shadow-md');
            btn.classList.remove('bg-white', 'text-neutral-600');
            
            filterMenu(btn.dataset.cat);
        });
    });
    
    function filterMenu(cat) {
        mealCards.forEach(card => {
            if (cat === 'all') {
                card.style.display = '';
            } else {
                if (card.dataset.cat === cat) {
                    card.style.display = '';
                } else {
                    card.style.display = 'none';
                }
            }
        });
    }
});
</script>
</body>
</html>
