<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // Authorization handled by SessionFilter
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Orders – University Restaurant</title>
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
  </style>
</head>
<body class="bg-[#fcf9f8] font-body text-neutral-800 min-h-screen flex flex-col">

<!-- Navbar -->
<nav class="flex justify-between items-center px-8 py-4 w-full sticky top-0 z-50 bg-white border-b border-neutral-100 shadow-[0_4px_12px_rgba(227,24,55,0.05)]">
  <a href="${pageContext.request.contextPath}/" class="text-2xl font-black italic tracking-tighter text-[#E31837] font-display">University Restaurant</a>
  <div class="hidden md:flex items-center gap-8 font-display">
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/">Home</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/menu.jsp">Menu</a>
    <a class="text-[#E31837] border-b-2 border-[#E31837] pb-1 font-bold" href="${pageContext.request.contextPath}/OrderServlet?action=viewOrders">My Orders</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/QueueServlet">Queue</a>
  </div>
  <div class="flex items-center gap-4">
    <span class="text-sm font-bold text-neutral-600 hidden md:inline">👤 ${sessionScope.user.name}</span>
    <a href="${pageContext.request.contextPath}/LogoutServlet" class="material-symbols-outlined p-2 rounded-full hover:bg-neutral-100 text-neutral-500 transition-all" title="Logout">logout</a>
    <a href="${pageContext.request.contextPath}/menu.jsp" class="bg-[#E31837] text-white px-5 py-2 rounded-lg font-bold text-sm hover:-translate-y-0.5 transition-all shadow-md hidden md:inline-flex items-center gap-1">
      <span class="material-symbols-outlined text-base">add</span> New Order
    </a>
  </div>
</nav>

<!-- Page Header Banner -->
<div class="bg-gradient-to-br from-neutral-900 to-[#b90027] pt-10 pb-14 px-8 text-white relative overflow-hidden">
  <div class="absolute right-0 top-0 opacity-10 pointer-events-none">
    <span class="material-symbols-outlined text-[280px] absolute -top-12 -right-12">receipt_long</span>
  </div>
  <div class="max-w-5xl mx-auto relative z-10">
    <span class="bg-white/20 text-white font-bold px-4 py-1 rounded-full text-xs mb-3 inline-block backdrop-blur-md">ORDER HISTORY</span>
    <h1 class="font-display text-4xl font-black mb-2">My Orders</h1>
    <p class="text-white/70 text-sm">Track all your past orders and their current status.</p>
  </div>
</div>

<main class="flex-1 max-w-5xl mx-auto w-full px-4 -mt-6 pb-16">

  <c:choose>
  <c:when test="${empty userOrders}">
  <!-- Empty State -->
  <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 p-16 text-center">
    <div class="w-20 h-20 bg-neutral-100 rounded-full flex items-center justify-center mx-auto mb-5">
      <span class="material-symbols-outlined text-neutral-400 text-4xl">receipt_long</span>
    </div>
    <h2 class="font-display text-2xl font-bold text-neutral-700 mb-2">No Orders Yet</h2>
    <p class="text-neutral-400 mb-6">You haven't placed any orders yet. Start by browsing the menu!</p>
    <a href="${pageContext.request.contextPath}/menu.jsp"
       class="inline-flex items-center gap-2 bg-[#E31837] text-white font-bold px-8 py-3.5 rounded-xl hover:-translate-y-0.5 transition-all shadow-[0_4px_16px_rgba(227,24,55,0.35)]">
      <span class="material-symbols-outlined">restaurant_menu</span> Browse Menu
    </a>
  </div>
  </c:when>
  <c:otherwise>
  <!-- Orders Table -->
  <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden">
    <div class="px-6 py-4 border-b border-neutral-100 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="material-symbols-outlined text-[#E31837]">history</span>
        <h2 class="font-display font-bold text-neutral-900">Order History</h2>
      </div>
      <span class="bg-[#E31837]/10 text-[#E31837] text-xs font-bold px-3 py-1 rounded-full">${fn:length(userOrders)} orders</span>
    </div>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr>
            <th class="text-left px-6 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Order ID</th>
            <th class="text-left px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Date &amp; Time</th>
            <th class="text-right px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Amount (KES)</th>
            <th class="text-center px-6 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Status</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-50">
          <c:forEach var="o" items="${userOrders}">
          <c:set var="status" value="${fn:toLowerCase(o.status)}" />
          <c:choose>
            <c:when test="${status == 'pending'}">
              <c:set var="badgeClass" value="bg-amber-50 text-amber-700 border border-amber-200" />
              <c:set var="dotColor" value="bg-amber-400" />
            </c:when>
            <c:when test="${status == 'preparing'}">
              <c:set var="badgeClass" value="bg-blue-50 text-blue-700 border border-blue-200" />
              <c:set var="dotColor" value="bg-blue-400" />
            </c:when>
            <c:when test="${status == 'ready'}">
              <c:set var="badgeClass" value="bg-green-50 text-green-700 border border-green-200" />
              <c:set var="dotColor" value="bg-green-400" />
            </c:when>
            <c:otherwise>
              <c:set var="badgeClass" value="bg-neutral-100 text-neutral-600 border border-neutral-200" />
              <c:set var="dotColor" value="bg-neutral-400" />
            </c:otherwise>
          </c:choose>
          <tr class="hover:bg-neutral-50/50 transition-colors">
            <td class="px-6 py-4">
              <span class="font-display font-black text-[#E31837] text-base">#${o.orderId}</span>
            </td>
            <td class="px-4 py-4 text-neutral-500 text-xs">${o.createdAt}</td>
            <td class="px-4 py-4 text-right font-bold text-neutral-900">KES ${o.totalAmount}</td>
            <td class="px-6 py-4 text-center">
              <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold ${badgeClass}">
                <span class="w-1.5 h-1.5 rounded-full ${dotColor}"></span>
                ${fn:toUpperCase(fn:substring(status, 0, 1))}${fn:substring(status, 1, fn:length(status))}
              </span>
            </td>
          </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
  </c:otherwise>
  </c:choose>

</main>

<footer class="bg-neutral-950 text-neutral-500 text-center py-6 text-xs">
  © 2026 University Restaurant University Restaurant
</footer>
</body>
</html>
