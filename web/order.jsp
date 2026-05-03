<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.Map, java.util.Map.Entry, model.MenuItem, model.dao.MenuItemDAO" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    MenuItemDAO dao = new MenuItemDAO();
    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    Integer lastOrderId = (Integer) session.getAttribute("lastOrderId");
    if (lastOrderId != null) {
        request.setAttribute("lastOrderId", lastOrderId);
    }
    if (cart != null) {
        Map<MenuItem, Integer> detailedCart = new java.util.LinkedHashMap<>();
        double total = 0;
        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            MenuItem item = dao.getMenuItemById(entry.getKey());
            if (item != null) {
                detailedCart.put(item, entry.getValue());
                total += item.getPrice() * entry.getValue();
            }
        }
        request.setAttribute("detailedCart", detailedCart);
        request.setAttribute("total", total);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Your Order – University Restaurant</title>
  <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
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
  <div class="flex items-center gap-8">
    <a href="${pageContext.request.contextPath}/" class="text-2xl font-black italic tracking-tighter text-[#E31837] font-display">University Restaurant</a>
  </div>
  <div class="hidden md:flex items-center gap-8 font-display">
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/">Home</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/menu.jsp">Menu</a>
    <a class="text-[#E31837] border-b-2 border-[#E31837] pb-1 font-bold" href="${pageContext.request.contextPath}/order.jsp">My Cart</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/OrderServlet?action=viewOrders">Orders</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/QueueServlet">Queue</a>
  </div>
  <div class="flex items-center gap-4">
    <span class="text-sm font-bold text-neutral-600 hidden md:inline">👤 ${sessionScope.user.name}</span>
    <a href="${pageContext.request.contextPath}/LogoutServlet" class="material-symbols-outlined p-2 rounded-full hover:bg-neutral-100 text-neutral-500 transition-all" title="Logout">logout</a>
  </div>
</nav>

<main class="flex-1 max-w-3xl mx-auto w-full px-4 py-12">

  <!-- Page Header -->
  <div class="mb-8">
    <div class="flex items-center gap-3 mb-2">
      <div class="w-10 h-10 bg-[#E31837] rounded-xl flex items-center justify-center">
        <span class="material-symbols-outlined text-white text-xl">shopping_bag</span>
      </div>
      <h1 class="font-display text-3xl font-black text-neutral-900">Your Cart</h1>
    </div>
    <p class="text-neutral-500 ml-13">Review your order before checkout</p>
    <c:if test="${not empty lastOrderId}">
    <div class="mt-3 inline-flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 px-4 py-2 rounded-xl text-sm font-semibold">
      <span class="material-symbols-outlined text-green-600 text-lg">check_circle</span>
      Order #${lastOrderId} placed successfully!
    </div>
    </c:if>
  </div>

  <c:choose>
    <c:when test="${empty cart}">
  <!-- Empty State -->
  <div class="bg-white rounded-3xl shadow-[0_4px_20px_rgba(0,0,0,0.06)] border border-neutral-100 p-16 text-center">
    <div class="w-20 h-20 bg-neutral-100 rounded-full flex items-center justify-center mx-auto mb-5">
      <span class="material-symbols-outlined text-neutral-400 text-4xl">shopping_cart</span>
    </div>
    <h2 class="font-display text-2xl font-bold text-neutral-700 mb-2">Your cart is empty</h2>
    <p class="text-neutral-400 mb-6">Add some delicious items from our menu to get started!</p>
    <a href="${pageContext.request.contextPath}/menu.jsp"
       class="inline-flex items-center gap-2 bg-[#E31837] text-white font-bold px-8 py-3.5 rounded-xl hover:-translate-y-0.5 transition-all shadow-[0_4px_16px_rgba(227,24,55,0.35)]">
      <span class="material-symbols-outlined">restaurant_menu</span> Browse Menu
    </a>
  </div>

    </a>
  </div>
    </c:when>
    <c:otherwise>
  <!-- Order Table Card -->
  <div class="bg-white rounded-3xl shadow-[0_4px_20px_rgba(0,0,0,0.06)] border border-neutral-100 overflow-hidden mb-6">
    <div class="px-6 py-4 border-b border-neutral-100 flex items-center gap-2">
      <span class="material-symbols-outlined text-[#E31837]">receipt_long</span>
      <h2 class="font-display text-lg font-bold">Order Summary</h2>
    </div>
    <table class="w-full text-sm">
      <thead class="bg-neutral-50">
        <tr>
          <th class="text-left px-6 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Item</th>
          <th class="text-center px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Qty</th>
          <th class="text-right px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Unit Price</th>
          <th class="text-right px-6 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Subtotal</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-neutral-50">
        <c:forEach var="entry" items="${detailedCart}">
          <c:set var="item" value="${entry.key}" />
          <c:set var="qty" value="${entry.value}" />
          <c:set var="subtotal" value="${qty * item.price}" />
          <tr class="hover:bg-neutral-50/50 transition-colors">
            <td class="px-6 py-4">
              <div class="font-bold text-neutral-800">${item.name}</div>
              <div class="text-xs text-neutral-400 capitalize mt-0.5">${fn:replace(item.mealPeriod, '_', ' ')}</div>
            </td>
            <td class="px-4 py-4 text-center">
              <span class="inline-flex items-center justify-center w-8 h-8 bg-[#E31837]/10 text-[#E31837] font-bold rounded-lg text-sm">${qty}</span>
            </td>
            <td class="px-4 py-4 text-right text-neutral-600">KES ${item.price}</td>
            <td class="px-6 py-4 text-right font-bold text-neutral-900">KES ${subtotal}</td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
    <!-- Total Row -->
    <div class="px-6 py-5 bg-neutral-50 border-t-2 border-neutral-100 flex justify-between items-center">
      <span class="font-bold text-neutral-500 uppercase tracking-widest text-xs">Total Amount</span>
      <span class="font-display text-3xl font-black text-[#E31837]">KES ${total}</span>
    </div>
  </div>

  <!-- Actions -->
  <div class="flex items-center justify-between gap-4 flex-wrap">
    <a href="${pageContext.request.contextPath}/menu.jsp"
       class="inline-flex items-center gap-2 border-2 border-neutral-200 text-neutral-600 font-bold px-6 py-3 rounded-xl hover:border-[#E31837] hover:text-[#E31837] transition-all">
      <span class="material-symbols-outlined text-xl">arrow_back</span> Edit Order
    </a>
    <form action="${pageContext.request.contextPath}/QueueServlet" method="post">
      <button type="submit"
              class="inline-flex items-center gap-2 bg-[#E31837] text-white font-bold px-8 py-3.5 rounded-xl hover:-translate-y-0.5 transition-all shadow-[0_4px_16px_rgba(227,24,55,0.35)] hover:shadow-[0_6px_24px_rgba(227,24,55,0.5)] active:scale-[0.98]">
        Checkout &amp; Get Queue Number <span class="material-symbols-outlined text-xl">confirmation_number</span>
      </button>
    </form>
  </div>
  </c:otherwise>
  </c:choose>

</main>

<!-- Footer -->
<footer class="bg-neutral-950 text-neutral-500 text-center py-6 text-xs mt-auto">
  © 2026 University Restaurant University Restaurant
</footer>

</body>
</html>
