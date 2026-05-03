<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // Authorization handled by SessionFilter
    String orderStatus = (String) request.getAttribute("orderStatus");
    if (orderStatus == null) request.setAttribute("orderStatus", "pending");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Queue Status – University Restaurant</title>
  <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
  <link href="https://fonts.googleapis.com/css2?family=Epilogue:wght@400;700;800;900&family=Be+Vietnam+Pro:wght@400;500;700&display=swap" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
  <script>
    tailwind.config = {
      theme: { extend: { fontFamily: { 'display': ['Epilogue'], 'body': ['Be Vietnam Pro'] } } }
    }
  </script>
  <style>
    .material-symbols-outlined { font-variation-settings: 'FILL' 0,'wght' 400,'GRAD' 0,'opsz' 24; }
    @keyframes pulse-ring {
      0%   { transform: scale(1);   opacity: 0.8; }
      100% { transform: scale(1.6); opacity: 0; }
    }
    .pulse-ring::before, .pulse-ring::after {
      content: '';
      position: absolute; inset: -12px;
      border-radius: 50%;
      border: 3px solid #E31837;
      animation: pulse-ring 2s ease-out infinite;
    }
    .pulse-ring::after { animation-delay: 0.8s; }
    @keyframes bounce-gentle {
      0%, 100% { transform: translateY(0); }
      50%       { transform: translateY(-8px); }
    }
    .bounce-gentle { animation: bounce-gentle 2.5s ease-in-out infinite; }
  </style>
</head>
<body class="bg-[#fcf9f8] font-body text-neutral-800 min-h-screen flex flex-col">

<!-- Navbar -->
<nav class="flex justify-between items-center px-8 py-4 w-full sticky top-0 z-50 bg-white border-b border-neutral-100 shadow-[0_4px_12px_rgba(227,24,55,0.05)]">
  <a href="${pageContext.request.contextPath}/" class="text-2xl font-black italic tracking-tighter text-[#E31837] font-display">University Restaurant</a>
  <div class="hidden md:flex items-center gap-8 font-display">
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/">Home</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/menu.jsp">Menu</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/OrderServlet?action=viewOrders">Orders</a>
    <a class="text-[#E31837] border-b-2 border-[#E31837] pb-1 font-bold" href="${pageContext.request.contextPath}/QueueServlet">Queue</a>
  </div>
  <div class="flex items-center gap-4">
    <span class="text-sm font-bold text-neutral-600 hidden md:inline">👤 ${sessionScope.user.name}</span>
    <a href="${pageContext.request.contextPath}/LogoutServlet" class="material-symbols-outlined p-2 rounded-full hover:bg-neutral-100 text-neutral-500 transition-all" title="Logout">logout</a>
  </div>
</nav>

<main class="flex-1 flex flex-col items-center justify-center px-4 py-16">

  <c:choose>
  <c:when test="${not empty sessionScope.queueNumber}">

  <!-- Queue Confirmed State -->
  <div class="text-center max-w-md w-full">

    <!-- Animated Queue Badge -->
    <div class="relative inline-block mb-10 bounce-gentle">
      <div class="pulse-ring relative w-36 h-36 rounded-full bg-[#E31837] flex items-center justify-center mx-auto shadow-[0_8px_40px_rgba(227,24,55,0.4)]">
        <div class="text-center text-white">
          <div class="font-display font-black text-4xl leading-none">#${sessionScope.queueNumber}</div>
          <div class="text-xs font-bold opacity-80 mt-1">YOUR TURN</div>
        </div>
      </div>
    </div>

    <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 p-8 mb-6">
      <div class="flex items-center justify-center gap-2 mb-3">
        <span class="material-symbols-outlined text-[#E31837] text-3xl">celebration</span>
        <h1 class="font-display text-2xl font-black text-neutral-900">Order Confirmed!</h1>
      </div>
      <p class="text-neutral-500 text-sm mb-4">
        Your queue number is <strong class="text-[#E31837]">#${sessionScope.queueNumber}</strong>.
        <c:if test="${not empty sessionScope.lastOrderId}"> (Order #${sessionScope.lastOrderId})</c:if>
      </p>
      <p class="text-neutral-500 text-sm">
        Please wait near the collection counter. We'll call your number when your meal is ready!
      </p>
    </div>

    <!-- Status Steps -->
    <c:set var="isServed" value="${orderStatus == 'served' || orderStatus == 'ready' || orderStatus == 'preparing'}" />
    <div class="bg-white rounded-3xl shadow-[0_4px_20px_rgba(0,0,0,0.06)] border border-neutral-100 p-6 mb-6">
      <h3 class="font-display font-bold text-neutral-700 mb-5 text-sm uppercase tracking-wider">Order Progress (<span class="capitalize text-[#E31837]">${isServed ? 'completed' : 'pending'}</span>)</h3>
      <div class="flex items-center gap-2">
        <div class="flex flex-col items-center flex-1">
          <div class="w-12 h-12 rounded-full bg-[#E31837] text-white shadow-lg flex items-center justify-center mb-2">
            <span class="material-symbols-outlined text-2xl">receipt_long</span>
          </div>
          <span class="text-sm font-bold text-[#E31837]">Ordered</span>
        </div>
        <div class="flex-1 h-1 ${isServed ? 'bg-[#E31837]' : 'bg-neutral-200'} rounded mb-6"></div>
        <div class="flex flex-col items-center flex-1">
          <div class="w-12 h-12 rounded-full ${isServed ? 'bg-[#E31837] text-white shadow-lg' : 'bg-neutral-100 text-neutral-400'} flex items-center justify-center mb-2">
            <span class="material-symbols-outlined text-2xl">check_circle</span>
          </div>
          <span class="text-sm font-bold ${isServed ? 'text-[#E31837]' : 'text-neutral-400'}">Completed</span>
        </div>
      </div>
    </div>
    
    <c:choose>
    <c:when test="${orderStatus == 'pending'}">
    <!-- What's Next Info (Only when pending/unpaid) -->
    <div class="bg-amber-50 border border-amber-200 rounded-2xl p-4 text-sm text-amber-800 text-left flex gap-3 mb-6">
      <span class="material-symbols-outlined text-amber-500 mt-0.5">info</span>
      <div>
        <p class="font-bold mb-0.5">Payment at the counter</p>
        <p class="text-amber-700">Your cashier will process payment when your number is called. Have your Order ID ready.</p>
      </div>
    </div>
    </c:when>
    <c:when test="${isServed}">
    <div class="bg-green-50 border border-green-200 rounded-2xl p-4 text-sm text-green-800 text-left flex gap-3 mb-6">
      <span class="material-symbols-outlined text-green-500 mt-0.5">verified</span>
      <div>
        <p class="font-bold mb-0.5">Payment Confirmed - Order Completed</p>
        <p class="text-green-700">Thank you for dining with University Restaurant! Enjoy your meal.</p>
      </div>
    </div>
    </c:when>
    </c:choose>

    <a href="${pageContext.request.contextPath}/menu.jsp"
       class="inline-flex items-center gap-2 border-2 border-[#E31837] text-[#E31837] font-bold px-8 py-3 rounded-xl hover:bg-[#E31837] hover:text-white transition-all active:scale-[0.98]">
      <span class="material-symbols-outlined">add_circle</span> Order Something Else
    </a>
  </div>

  </c:when>
  <c:otherwise>

  <!-- No Queue State -->
  <div class="text-center max-w-sm w-full">
    <div class="w-24 h-24 bg-neutral-100 rounded-full flex items-center justify-center mx-auto mb-6">
      <span class="material-symbols-outlined text-neutral-400 text-5xl">confirmation_number</span>
    </div>
    <h1 class="font-display text-3xl font-black text-neutral-800 mb-3">No Queue Yet</h1>
    <p class="text-neutral-500 mb-8">You haven't placed an order yet. Browse the menu and place your order to get a queue number.</p>
    <a href="${pageContext.request.contextPath}/menu.jsp"
       class="inline-flex items-center gap-2 bg-[#E31837] text-white font-bold px-8 py-3.5 rounded-xl hover:-translate-y-0.5 transition-all shadow-[0_4px_16px_rgba(227,24,55,0.35)]">
      <span class="material-symbols-outlined">restaurant_menu</span> Browse Menu
    </a>
  </div>

  </c:otherwise>
  </c:choose>
</main>

<footer class="bg-neutral-950 text-neutral-500 text-center py-6 text-xs">
  © 2026 University Restaurant University Restaurant
</footer>
</body>
</html>
