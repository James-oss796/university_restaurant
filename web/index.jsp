<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List, model.MenuItem, model.dao.MenuItemDAO" %>
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
<title>University Restaurant - Delicious Meals Delivered Fast</title>
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
<a class="text-[#E31837] border-b-2 border-[#E31837] pb-1 font-bold" href="${pageContext.request.contextPath}/">Home</a>
<a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/menu.jsp">Menu</a>
<c:if test="${not empty sessionScope.user}">
    <c:choose>
        <c:when test="${sessionScope.user.role == 'student'}">
            <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/OrderServlet?action=viewOrders">Orders</a>
            <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/QueueServlet">Queue</a>
        </c:when>
        <c:when test="${sessionScope.user.role == 'admin'}">
            <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/ReportServlet">Reports</a>
        </c:when>
        <c:when test="${sessionScope.user.role == 'cashier'}">
            <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/PaymentServlet">Payments</a>
        </c:when>
    </c:choose>
</c:if>
</div>
<div class="flex items-center gap-4">
<c:choose>
    <c:when test="${not empty sessionScope.user}">
        <span class="text-sm font-bold text-neutral-600 hidden md:inline ml-4">👤 ${sessionScope.user.name}</span>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="material-symbols-outlined p-2 flex items-center justify-center rounded-full hover:bg-neutral-50 transition-all text-neutral-600" title="Logout">logout</a>
        <c:if test="${sessionScope.user.role == 'student'}">
            <a href="${pageContext.request.contextPath}/menu.jsp" class="bg-[#E31837] text-white px-6 py-2 rounded-lg font-bold active:scale-[0.98] transition-transform shadow-lg">New Order</a>
        </c:if>
    </c:when>
    <c:otherwise>
        <a href="${pageContext.request.contextPath}/LoginServlet" class="text-neutral-600 font-bold hover:text-[#E31837] transition-colors">Login</a>
        <a href="${pageContext.request.contextPath}/RegisterServlet" class="bg-[#E31837] text-white px-6 py-2 rounded-lg font-bold active:scale-[0.98] transition-transform shadow-lg">Sign Up</a>
    </c:otherwise>
</c:choose>
</div>
</nav>

<main class="max-w-[1440px] mx-auto pb-24">
<!-- Hero Section -->
<section class="relative h-[600px] w-full overflow-hidden bg-neutral-900">
<div class="absolute inset-0 z-0">
<img alt="Hero" class="w-full h-full object-cover opacity-80" src="${pageContext.request.contextPath}/images/carousel1.jpg"/>
<div class="absolute inset-0 bg-gradient-to-r from-black/80 via-black/40 to-transparent"></div>
</div>
<div class="relative z-10 h-full flex flex-col justify-center px-12 max-w-4xl">
<h1 class="font-display-xl text-5xl md:text-6xl font-extrabold tracking-tight text-white mb-4">Delicious Meals Delivered Fast</h1>
<p class="font-body-lg text-lg text-white/90 mb-8 max-w-xl">Order your favorite campus meals from University Restaurant. From spicy pilau to hearty nyama choma, we bring the flavor to your doorstep in minutes.</p>
<div class="flex gap-4">
<a href="${pageContext.request.contextPath}/menu.jsp" class="bg-[#E31837] text-white px-8 py-4 rounded-xl font-bold text-lg shadow-2xl hover:translate-y-[-2px] transition-all active:scale-[0.98]">Order Your Favorite Now</a>
<a href="#featured" class="bg-white/10 backdrop-blur-md border-2 border-white/20 text-white px-8 py-4 rounded-xl font-bold text-lg hover:bg-white/20 transition-all">Explore Menu</a>
</div>
</div>
</section>

<!-- Category Tabs -->
<section class="mt-12 px-8" id="featured">
<div class="flex items-center justify-between mb-6">
<h2 class="font-headline-lg text-3xl font-bold">Explore Categories</h2>
<div class="flex gap-2">
<button class="material-symbols-outlined p-2 rounded-full border border-neutral-200">chevron_left</button>
<button class="material-symbols-outlined p-2 rounded-full border border-neutral-200">chevron_right</button>
</div>
</div>
<div class="flex gap-4 overflow-x-auto pb-4 no-scrollbar">
<a href="${pageContext.request.contextPath}/menu.jsp" class="flex-shrink-0 cursor-pointer flex items-center gap-3 bg-neutral-900 text-white px-8 py-4 rounded-full font-bold">
<span class="material-symbols-outlined">restaurant</span> All Meals
</a>
<a href="${pageContext.request.contextPath}/menu.jsp?cat=chicken" class="flex-shrink-0 cursor-pointer flex items-center gap-3 bg-white border border-neutral-200 px-8 py-4 rounded-full font-bold hover:bg-neutral-50">
<span class="material-symbols-outlined">kebab_dining</span> Chicken
</a>
<a href="${pageContext.request.contextPath}/menu.jsp?cat=snacks" class="flex-shrink-0 cursor-pointer flex items-center gap-3 bg-white border border-neutral-200 px-8 py-4 rounded-full font-bold hover:bg-neutral-50">
<span class="material-symbols-outlined">bakery_dining</span> Snacks
</a>
<a href="${pageContext.request.contextPath}/menu.jsp?cat=rice" class="flex-shrink-0 cursor-pointer flex items-center gap-3 bg-white border border-neutral-200 px-8 py-4 rounded-full font-bold hover:bg-neutral-50">
<span class="material-symbols-outlined">rice_bowl</span> Rice & Ugali
</a>
</div>
</section>

<!-- Featured Meals -->
<section class="mt-16 px-8">
<h2 class="font-headline-lg text-3xl font-bold mb-8">Featured Meals</h2>
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
<c:forEach var="item" items="${items}" end="3" varStatus="vs">
    <c:set var="img" value="${not empty item.imageUrl ? pageContext.request.contextPath.concat('/').concat(item.imageUrl) : pageContext.request.contextPath.concat('/images/carousel2.jpg')}" />
    <div class="group bg-white rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(227,24,55,0.05)] hover:shadow-[0_8px_20px_rgba(227,24,55,0.1)] transition-all duration-300 hover:-translate-y-1">
        <div class="relative h-48 overflow-hidden bg-neutral-100 flex items-center justify-center">
            <img alt="${item.name}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" src="${img}"/>
            <c:if test="${vs.first}"><div class="absolute top-4 right-4 bg-black text-white text-xs font-bold px-3 py-1 rounded-full">MUST TRY</div></c:if>
            <c:if test="${vs.index == 3}"><div class="absolute top-4 right-4 bg-secondary-container text-white text-xs font-bold px-3 py-1 rounded-full">POPULAR</div></c:if>
        </div>
        <div class="p-5">
            <h3 class="font-headline-md text-xl font-bold mb-2">${item.name}</h3>
            <p class="font-body-md text-neutral-500 text-sm mb-4 line-clamp-2" style="display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${item.description}</p>
            <div class="flex items-center justify-between">
                <span class="font-display-xl text-2xl font-bold text-[#E31837]">KES ${item.price}</span>
                <a href="${pageContext.request.contextPath}/menu.jsp" class="bg-[#E31837] inline-block text-center text-white px-4 py-2 rounded-lg font-bold active:scale-95 transition-all">Order</a>
            </div>
        </div>
    </div>
</c:forEach>
</div>
</section>

<!-- Offers Banner Section -->
<section class="mt-20 px-8">
<div class="relative rounded-3xl overflow-hidden bg-gradient-to-r from-[#E31837] to-[#FF8200] p-12 text-white flex flex-col md:flex-row items-center justify-between gap-8">
<div class="max-w-xl">
<span class="bg-white/20 text-white font-bold px-4 py-1 rounded-full text-sm mb-6 inline-block">TODAY'S SPECIAL OFFERS</span>
<h2 class="font-display-xl text-4xl md:text-5xl font-extrabold mb-4">Student Monday! <br/> Get 30% OFF all Combos</h2>
<p class="font-body-lg text-white/90 mb-8">Fuel your studies with our best-selling meal combos. Valid for all University students with a valid ID. Don't miss out on the zest!</p>
<a href="${pageContext.request.contextPath}/menu.jsp" class="bg-white inline-block text-[#E31837] px-8 py-4 rounded-xl font-bold text-lg hover:shadow-xl transition-all active:scale-95">Claim Offer Now</a>
</div>
<div class="relative w-full md:w-1/3 aspect-square">
<img alt="Combo Offer" class="w-full h-full object-contain drop-shadow-2xl" src="${pageContext.request.contextPath}/images/carousel3.jpg"/>
</div>
</div>
</section>

<!-- Order Tracker Step Indicator -->
<section class="mt-20 px-8">
<div class="bg-surface-container-low rounded-3xl p-10 border-2 border-dashed border-neutral-200">
<div class="flex flex-col md:flex-row items-center justify-between gap-8">
<div>
<h2 class="font-headline-lg text-3xl font-bold mb-2">Track Your Heat</h2>
<p class="text-neutral-500">Real-time update for your current order #FZ-99281</p>
</div>
<div class="flex items-center gap-4 hidden sm:flex">
<div class="flex flex-col items-center">
<div class="w-12 h-12 rounded-full bg-[#E31837] text-white flex items-center justify-center mb-2">
<span class="material-symbols-outlined">receipt_long</span>
</div>
<span class="text-xs font-bold">Ordered</span>
</div>
<div class="h-1 w-12 bg-[#E31837] mb-6"></div>
<div class="flex flex-col items-center">
<div class="w-12 h-12 rounded-full bg-[#E31837] text-white flex items-center justify-center mb-2">
<span class="material-symbols-outlined">skillet</span>
</div>
<span class="text-xs font-bold">Cooking</span>
</div>
<div class="h-1 w-12 bg-neutral-200 mb-6"></div>
<div class="flex flex-col items-center">
<div class="w-12 h-12 rounded-full bg-neutral-200 text-neutral-400 flex items-center justify-center mb-2">
<span class="material-symbols-outlined">delivery_dining</span>
</div>
<span class="text-xs font-bold text-neutral-400">Transit</span>
</div>
<div class="h-1 w-12 bg-neutral-200 mb-6"></div>
<div class="flex flex-col items-center">
<div class="w-12 h-12 rounded-full bg-neutral-200 text-neutral-400 flex items-center justify-center mb-2">
<span class="material-symbols-outlined">check_circle</span>
</div>
<span class="text-xs font-bold text-neutral-400">Arrived</span>
</div>
</div>
<div class="sm:hidden flex text-[#E31837] font-bold text-xl items-center gap-2">
    <span class="material-symbols-outlined">skillet</span> Cooking now...
</div>
</div>
</div>
</section>
</main>

<!-- Footer -->
<footer class="bg-neutral-950 text-white pt-20 pb-10 px-8 font-body-md">
<div class="max-w-[1440px] mx-auto grid grid-cols-1 md:grid-cols-4 gap-12 mb-20">
<div class="col-span-1 md:col-span-1">
<span class="text-3xl font-black italic tracking-tighter text-[#E31837] block mb-6">University Restaurant</span>
<p class="text-neutral-400 leading-relaxed">Providing high-quality, flavorful meals to the university community. We believe in fast service without compromising on the premium restaurant taste.</p>
</div>
<div>
<h4 class="font-bold text-lg mb-6">Quick Links</h4>
<ul class="space-y-4 text-neutral-400">
<li><a class="hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/menu.jsp">Menu</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Today's Deals</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/OrderServlet?action=viewOrders">Track Order</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Student Loyalty</a></li>
</ul>
</div>
<div>
<h4 class="font-bold text-lg mb-6">Support</h4>
<ul class="space-y-4 text-neutral-400">
<li><a class="hover:text-[#E31837] transition-colors" href="#">Help Center</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Terms of Service</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Privacy Policy</a></li>
<li><a class="hover:text-[#E31837] transition-colors" href="#">Contact Us</a></li>
</ul>
</div>
<div>
<h4 class="font-bold text-lg mb-6">Contact Info</h4>
<div class="space-y-4 text-neutral-400">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-[#E31837]">location_on</span>
<span>Main Campus, Central Plaza</span>
</div>
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-[#E31837]">call</span>
<span>+254 700 000 000</span>
</div>
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-[#E31837]">mail</span>
<span>orders@universityrestaurant.ac.ke</span>
</div>
</div>
</div>
</div>
<div class="border-t border-neutral-800 pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-neutral-500 text-sm">
<p>© 2026 University Restaurant University Restaurant. All rights reserved.</p>
<div class="flex gap-6">
<a class="hover:text-white transition-colors" href="#">Instagram</a>
<a class="hover:text-white transition-colors" href="#">Twitter</a>
<a class="hover:text-white transition-colors" href="#">Facebook</a>
</div>
</div>
</footer>

<c:if test="${empty sessionScope.user || sessionScope.user.role == 'student'}">
<a href="${pageContext.request.contextPath}/menu.jsp" class="fixed bottom-8 right-8 bg-[#E31837] text-white p-4 rounded-full shadow-2xl flex items-center justify-center active:scale-90 transition-all z-50 group">
<span class="material-symbols-outlined text-3xl">shopping_cart</span>
<span class="absolute right-full mr-4 bg-white text-[#E31837] px-4 py-2 rounded-lg font-bold shadow-xl opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap overflow-hidden pointer-events-none">Order Now</span>
</a>
</c:if>

</body>
</html>
