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
  <title>Process Payment – University Restaurant</title>
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
    .ref-group { display: none; }
    .order-card-selected {
      border-color: #E31837 !important;
      background-color: #fff1f2 !important;
      box-shadow: 0 10px 15px -3px rgba(227, 24, 55, 0.1), 0 4px 6px -2px rgba(227, 24, 55, 0.05) !important;
    }
    @media (min-width: 1024px) {
      .sticky-panel {
        position: sticky;
        top: 100px;
        max-height: calc(100vh - 140px);
        overflow-y: auto;
      }
    }
  </style>
</head>
<body class="bg-[#fcf9f8] font-body text-neutral-800 min-h-screen flex flex-col">

<!-- Cashier Navbar -->
<nav class="flex justify-between items-center px-8 py-4 w-full sticky top-0 z-50 bg-white border-b border-neutral-100 shadow-[0_4px_12px_rgba(227,24,55,0.05)]">
  <a href="${pageContext.request.contextPath}/" class="text-2xl font-black italic tracking-tighter text-[#E31837] font-display">University Restaurant</a>
  <div class="hidden md:flex items-center gap-8 font-display">
    <a class="${activeView == 'process' ? 'text-[#E31837] border-b-2 border-[#E31837] font-bold' : 'text-neutral-500 hover:text-[#E31837]'} pb-1 transition-all" 
       href="${pageContext.request.contextPath}/PaymentServlet?view=process">Process Payment</a>
    <a class="${activeView == 'history' ? 'text-[#E31837] border-b-2 border-[#E31837] font-bold' : 'text-neutral-500 hover:text-[#E31837]'} pb-1 transition-all" 
       href="${pageContext.request.contextPath}/PaymentServlet?view=history">Payment History</a>
  </div>
  <div class="flex items-center gap-3">
    <div class="hidden md:flex items-center gap-2 bg-amber-50 border border-amber-200 text-amber-700 px-3 py-1.5 rounded-lg text-xs font-bold">
      <span class="material-symbols-outlined text-base">point_of_sale</span>Cashier
    </div>
    <span class="text-sm font-bold text-neutral-600 hidden md:inline">👤 ${sessionScope.user.name}</span>
    <a href="${pageContext.request.contextPath}/LogoutServlet" class="material-symbols-outlined p-2 rounded-full hover:bg-neutral-100 text-neutral-500 transition-all" title="Logout">logout</a>
  </div>
</nav>

<!-- Page Header Banner -->
<div class="bg-gradient-to-br from-neutral-900 to-[#b90027] pt-10 pb-14 px-8 text-white relative overflow-hidden">
  <div class="absolute right-0 top-0 opacity-10 pointer-events-none">
    <span class="material-symbols-outlined text-[280px] absolute -top-12 -right-12">point_of_sale</span>
  </div>
  <div class="max-w-4xl mx-auto relative z-10">
    <span class="bg-white/20 text-white font-bold px-4 py-1 rounded-full text-xs mb-3 inline-block backdrop-blur-md uppercase tracking-widest">
        Cashier Terminal – ${activeView}
    </span>
    <h1 class="font-display text-4xl font-black mb-2">
      ${activeView == 'history' ? 'Transaction Archive' : 'Order Fulfillment'}
    </h1>
    <p class="text-white/70 text-sm max-w-xl">
      ${activeView == 'history' ? 'Review and verify all past payment records and transaction details.' : 'Select a customer\'s pending order to process their payment and finalize the sale.'}
    </p>
  </div>
</div>

<main class="flex-1 max-w-7xl mx-auto w-full px-4 pb-16">
  
  <!-- View Selector (Tabs) -->
  <div class="flex items-center gap-1 bg-white p-1 rounded-2xl border border-neutral-100 shadow-sm mb-8 w-fit">
    <a href="${pageContext.request.contextPath}/PaymentServlet?view=process" 
       class="flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold transition-all ${activeView == 'process' ? 'bg-[#E31837] text-white shadow-lg' : 'text-neutral-500 hover:bg-neutral-50'}">
      <span class="material-symbols-outlined text-lg">payments</span> Process Orders
    </a>
    <a href="${pageContext.request.contextPath}/PaymentServlet?view=history" 
       class="flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold transition-all ${activeView == 'history' ? 'bg-[#E31837] text-white shadow-lg' : 'text-neutral-500 hover:bg-neutral-50'}">
      <span class="material-symbols-outlined text-lg">history</span> History Archive
    </a>
  </div>

  <c:if test="${activeView == 'process'}">
  <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
    
    <!-- Left Column: Orders & History (8 cols) -->
    <div class="lg:col-span-7 space-y-8">

  <!-- Flash Messages -->
  <c:if test="${not empty sessionScope.paymentSuccess}">
  <div class="flex items-center gap-3 bg-green-50 border border-green-200 text-green-700 px-5 py-4 rounded-2xl mb-6 font-semibold text-sm">
    <span class="material-symbols-outlined text-green-500 text-xl">check_circle</span>
    ${sessionScope.paymentSuccess}
    <c:remove var="paymentSuccess" scope="session" />
  </div>
  </c:if>
  <c:if test="${not empty error}">
  <div class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-700 px-5 py-4 rounded-2xl mb-6 font-semibold text-sm">
    <span class="material-symbols-outlined text-red-500 text-xl">error</span>
    ${error}
  </div>
  </c:if>
  <c:if test="${not empty warning}">
  <div class="flex items-center gap-3 bg-amber-50 border border-amber-200 text-amber-700 px-5 py-4 rounded-2xl mb-6 font-semibold text-sm">
    <span class="material-symbols-outlined text-amber-500 text-xl">warning</span>
    ${warning}
  </div>
  </c:if>

      <div class="flex items-center gap-3 pb-4 mb-4 border-b border-neutral-200">
        <div class="w-10 h-10 bg-amber-100 rounded-xl flex items-center justify-center">
          <span class="material-symbols-outlined text-amber-600 text-xl">pending_actions</span>
        </div>
        <h2 class="font-display text-xl font-bold">Pending Orders</h2>
        <c:if test="${not empty pendingOrders}">
        <span class="bg-neutral-100 text-neutral-600 text-xs font-bold px-2 py-1 rounded-full">${fn:length(pendingOrders)}</span>
        </c:if>
      </div>

      <div class="flex flex-col gap-4">
        <c:forEach var="o" items="${pendingOrders}">
        <div class="order-card group bg-white border-2 border-neutral-100 rounded-3xl p-6 cursor-pointer transition-all hover:border-[#E31837] hover:shadow-lg active:scale-[0.99]" 
             id="order-${o.orderId}" 
             onclick="prefillPayment(${o.orderId}, ${o.totalAmount}, '${fn:escapeXml(o.customerName)}', '${fn:escapeXml(o.itemsDescription)}')">
          <div class="flex justify-between items-start">
            <div class="space-y-3">
              <div class="flex items-center gap-2">
                <span class="bg-[#E31837] text-white text-[10px] font-black px-2 py-0.5 rounded uppercase">#${o.orderId}</span>
                <span class="text-xs text-neutral-400 font-bold">${fn:substring(o.createdAt, 11, 16)}</span>
              </div>
              <div class="font-black text-lg text-neutral-800 flex items-center gap-2">
                <span class="material-symbols-outlined text-[16px] text-neutral-400">person</span>
                ${not empty o.customerName ? o.customerName : 'Unknown Customer'}
              </div>
              <div class="text-xs text-neutral-500 flex items-start gap-1.5">
                <span class="material-symbols-outlined text-[16px] text-neutral-400">receipt_long</span>
                <span class="line-clamp-1">${not empty o.itemsDescription ? o.itemsDescription : 'Items not specified'}</span>
              </div>
            </div>
            <div class="text-right flex flex-col justify-end">
              <div class="text-[10px] text-neutral-400 uppercase font-bold mb-0.5">Amount Due</div>
              <div class="font-black text-xl text-[#E31837]">KES ${o.totalAmount}</div>
            </div>
          </div>
        </div>
        </c:forEach>
        <c:if test="${empty pendingOrders}">
        <div class="bg-white rounded-3xl p-12 border border-neutral-100 text-center space-y-4">
          <div class="w-20 h-20 bg-neutral-50 rounded-full flex items-center justify-center mx-auto mb-2">
            <span class="material-symbols-outlined text-4xl text-neutral-300">fact_check</span>
          </div>
          <h3 class="font-display text-xl font-bold text-neutral-700">All caught up!</h3>
          <p class="text-neutral-500 max-w-xs mx-auto">There are no pending orders at the moment.</p>
        </div>
        </c:if>
      </div>
    </div> <!-- End Left Column -->

    <!-- Right Column: Payment Panel (4 cols) -->
    <div class="lg:col-span-5">
      <div class="sticky-panel space-y-6">
        <div class="bg-white rounded-3xl shadow-[0_20px_50px_rgba(0,0,0,0.1)] border border-neutral-100 overflow-hidden">
          <div class="bg-[#E31837] px-8 py-6 text-white">
            <div class="flex items-center gap-3">
              <span class="material-symbols-outlined text-3xl">point_of_sale</span>
              <h2 class="font-display text-xl font-bold uppercase tracking-tight">Payment Confirmation</h2>
            </div>
          </div>
          
          <div class="p-8">
            <div id="noSelectionState" class="${empty prefilledOrderId ? '' : 'hidden'} py-12 text-center space-y-4">
              <div class="w-16 h-16 bg-neutral-50 rounded-full flex items-center justify-center mx-auto text-neutral-300">
                <span class="material-symbols-outlined text-3xl">touch_app</span>
              </div>
              <p class="text-neutral-500 font-medium italic">Select a pending order from the left to begin processing payment.</p>
            </div>

            <div id="panelFormArea" class="${empty prefilledOrderId ? 'hidden' : ''}">
              <!-- Selection Summary -->
              <div class="bg-neutral-50 rounded-2xl p-5 mb-6 border border-neutral-100">
                <div class="flex justify-between items-start mb-4">
                  <span class="text-xs font-bold text-neutral-400 uppercase tracking-widest">Order Summary</span>
                  <span id="summaryOrderId" class="bg-[#E31837] text-white text-[10px] font-black px-2 py-0.5 rounded">#${prefilledOrderId}</span>
                </div>
                <div class="space-y-3">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-white rounded-lg flex items-center justify-center border border-neutral-100">
                      <span class="material-symbols-outlined text-lg text-neutral-400">person</span>
                    </div>
                    <div>
                      <div class="text-[10px] text-neutral-400 font-bold uppercase">Customer</div>
                      <div id="summaryCustomer" class="text-sm font-bold text-neutral-800">—</div>
                    </div>
                  </div>
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-white rounded-lg flex items-center justify-center border border-neutral-100">
                      <span class="material-symbols-outlined text-lg text-neutral-400">receipt_long</span>
                    </div>
                    <div>
                      <div class="text-[10px] text-neutral-400 font-bold uppercase">Items</div>
                      <div id="summaryItems" class="text-sm font-medium text-neutral-600 line-clamp-2">—</div>
                    </div>
                  </div>
                </div>
              </div>

              <form action="${pageContext.request.contextPath}/PaymentServlet" method="post" id="paymentForm" novalidate class="space-y-6">
                <input type="hidden" id="orderId" name="orderId" value="${prefilledOrderId}"/>
                
                <div class="space-y-2">
                  <label class="block text-xs font-black text-neutral-400 uppercase tracking-widest">Total Amount to Pay</label>
                  <div class="relative">
                    <span class="absolute left-6 top-1/2 -translate-y-1/2 text-2xl font-black text-neutral-400">KES</span>
                    <input type="number" id="amount" name="amount" min="0.01" step="0.01"
                           value="${prefilledAmount}" required
                           class="w-full pl-20 pr-6 py-5 bg-neutral-50 border-2 border-neutral-100 rounded-2xl text-3xl font-black text-neutral-800 focus:border-[#E31837] focus:ring-0 transition-all"/>
                  </div>
                </div>

                <div class="space-y-3">
                  <label class="block text-xs font-black text-neutral-400 uppercase tracking-widest">Payment Method</label>
                  <div class="grid grid-cols-2 gap-3">
                    <label class="method-card border-2 rounded-2xl p-4 cursor-pointer transition-all flex flex-col items-center gap-2 text-center
                                  ${selectedMethod == 'cash' || empty selectedMethod ? 'border-[#E31837] bg-rose-50' : 'border-neutral-100 bg-white hover:border-neutral-200'}">
                      <input type="radio" name="paymentMethod" value="cash" id="methodCash" ${selectedMethod == 'cash' || empty selectedMethod ? 'checked' : ''} onchange="toggleReference('cash')" class="hidden"/>
                      <span class="material-symbols-outlined text-3xl text-green-600">payments</span>
                      <span class="text-sm font-bold text-neutral-800">Cash</span>
                    </label>
                    <label class="method-card border-2 rounded-2xl p-4 cursor-pointer transition-all flex flex-col items-center gap-2 text-center
                                  ${selectedMethod == 'mobile_money' ? 'border-[#E31837] bg-rose-50' : 'border-neutral-100 bg-white hover:border-neutral-200'}">
                      <input type="radio" name="paymentMethod" value="mobile_money" id="methodMobile" ${selectedMethod == 'mobile_money' ? 'checked' : ''} onchange="toggleReference('mobile_money')" class="hidden"/>
                      <span class="material-symbols-outlined text-3xl text-blue-600">phone_iphone</span>
                      <span class="text-sm font-bold text-neutral-800">M-Pesa</span>
                    </label>
                  </div>
                  <input type="hidden" name="paymentMethod" id="paymentMethodHidden" value="${not empty selectedMethod ? selectedMethod : 'cash'}"/>
                </div>

                <div class="ref-group space-y-2" id="refGroup">
                  <label for="transactionReference" class="block text-xs font-black text-neutral-400 uppercase tracking-widest">M-Pesa Confirmation Code</label>
                  <div class="relative">
                    <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-neutral-400">confirmation_number</span>
                    <input type="text" id="transactionReference" name="transactionReference"
                           placeholder="e.g. QA12B3C4D5" maxlength="100"
                           class="w-full pl-12 pr-4 py-4 bg-neutral-50 border-2 border-neutral-100 rounded-xl text-sm font-bold focus:border-[#E31837] focus:ring-0"/>
                  </div>
                </div>

                <button type="submit"
                        class="w-full bg-[#E31837] hover:bg-[#b90027] text-white font-black py-5 rounded-2xl shadow-xl shadow-rose-200 hover:shadow-2xl hover:-translate-y-1 transition-all active:scale-[0.98] flex items-center justify-center gap-3">
                  <span class="material-symbols-outlined">verified_user</span>
                  <span>CONFIRM PAYMENT</span>
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
      </div>
    </div> <!-- End Right Column -->

  </div> <!-- End Grid -->
  </c:if>

  <!-- Payment History Section (Independent View) -->
  <c:if test="${activeView == 'history'}">
  <div class="bg-white rounded-3xl shadow-[0_20px_60px_rgba(0,0,0,0.05)] border border-neutral-100 overflow-hidden">
    <div class="px-6 py-4 border-b border-neutral-100 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="material-symbols-outlined text-[#E31837]">history</span>
        <h2 class="font-display font-bold text-lg uppercase tracking-tight">Recent Transactions</h2>
      </div>
    </div>
    <c:choose>
      <c:when test="${empty paymentHistory}">
    <div class="p-16 text-center">
      <span class="material-symbols-outlined text-4xl text-neutral-300 block mb-3">receipt_long</span>
      <p class="text-neutral-400 font-medium">No payments recorded yet.</p>
    </div>
      </c:when>
      <c:otherwise>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr>
            <th class="text-left px-5 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">#</th>
            <th class="text-left px-4 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">ID</th>
            <th class="text-left px-4 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">Order</th>
            <th class="text-left px-4 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">Customer & Items</th>
            <th class="text-right px-4 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">Amount</th>
            <th class="text-center px-4 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">Method & Ref</th>
            <th class="text-left px-4 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">Cashier</th>
            <th class="text-left px-5 py-3 font-bold text-neutral-500 uppercase tracking-wider text-[10px]">Timestamp</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-50">
          <c:forEach var="p" items="${paymentHistory}" varStatus="status">
          <tr class="hover:bg-neutral-50/50 transition-colors">
            <td class="px-5 py-3.5 text-neutral-400 text-xs">${status.count}</td>
            <td class="px-4 py-3.5 font-bold text-[#E31837] text-xs">#${p.paymentId}</td>
            <td class="px-4 py-3.5 text-neutral-600 font-bold text-xs">#${p.orderId}</td>
            <td class="px-4 py-3.5">
              <div class="font-bold text-neutral-700 text-xs">${not empty p.customerName ? p.customerName : 'Unknown'}</div>
              <div class="text-[10px] text-neutral-400 mt-0.5 line-clamp-1 max-w-[200px]" title="${p.itemsDescription}">
                ${not empty p.itemsDescription ? p.itemsDescription : '—'}
              </div>
            </td>
            <td class="px-4 py-3.5 text-right font-black text-neutral-800">KES ${p.amount}</td>
            <td class="px-4 py-3.5 text-center">
              <c:choose>
                <c:when test="${p.paymentMethod == 'mobile_money'}">
                  <div class="inline-flex items-center gap-1 bg-blue-50 text-blue-700 border border-blue-200 px-2 py-0.5 rounded text-[9px] font-black uppercase tracking-widest mb-1">
                    <span class="material-symbols-outlined text-[10px]">phone_iphone</span> M-Pesa
                  </div>
                  <div class="text-[10px] text-neutral-400 font-mono">${p.transactionReference}</div>
                </c:when>
                <c:otherwise>
                  <div class="inline-flex items-center gap-1 bg-green-50 text-green-700 border border-green-200 px-2 py-0.5 rounded text-[9px] font-black uppercase tracking-widest">
                    <span class="material-symbols-outlined text-[10px]">payments</span> Cash
                  </div>
                </c:otherwise>
              </c:choose>
            </td>
            <td class="px-4 py-3.5 text-neutral-500 text-xs">${p.cashierName}</td>
            <td class="px-5 py-3.5 text-neutral-400 text-[10px] font-bold">
              ${p.paymentDate}<br/>
              <span class="text-neutral-300 font-medium">${p.paymentTime}</span>
            </td>
          </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
    </c:otherwise>
    </c:choose>
  </div>
  </c:if>
</main>

<footer class="bg-neutral-950 text-neutral-500 text-center py-6 text-xs">
  © 2026 University Restaurant University Restaurant
</footer>

<script>
  function prefillPayment(orderId, amount, customer, items) {
    const orderIdEl = document.getElementById('orderId');
    if (!orderIdEl) return; // Not in process view

    // UI selection
    document.querySelectorAll('.order-card').forEach(el => el.classList.remove('order-card-selected'));
    const selectedCard = document.getElementById('order-' + orderId);
    if (selectedCard) selectedCard.classList.add('order-card-selected');

    // Panel visibility
    const noSelectionState = document.getElementById('noSelectionState');
    const panelFormArea = document.getElementById('panelFormArea');
    if (noSelectionState) noSelectionState.classList.add('hidden');
    if (panelFormArea) panelFormArea.classList.remove('hidden');

    // Populate Fields
    orderIdEl.value = orderId;
    document.getElementById('amount').value = amount.toFixed(2);
    
    // Summary
    document.getElementById('summaryOrderId').innerText = '#' + orderId;
    document.getElementById('summaryCustomer').innerText = customer;
    document.getElementById('summaryItems').innerText = items;

    // Smooth scroll to panel if mobile
    if (window.innerWidth < 1024) {
      window.scrollTo({ top: panelFormArea.offsetTop - 100, behavior: 'smooth' });
    }
  }

  // Sync radio UI cards with the hidden select
  function toggleReference(method) {
    var refGroup = document.getElementById('refGroup');
    var refInput = document.getElementById('transactionReference');
    var hiddenSel = document.getElementById('paymentMethodHidden');
    if (hiddenSel) hiddenSel.value = method;
    var cards = document.querySelectorAll('.method-card');
    cards.forEach(function(card) {
      var radio = card.querySelector('input[type=radio]');
      if (radio && radio.value === method) {
        card.classList.add('border-[#E31837]', 'bg-rose-50');
        card.classList.remove('border-neutral-100', 'bg-white');
        radio.checked = true;
      } else {
        card.classList.remove('border-[#E31837]', 'bg-rose-50');
        card.classList.add('border-neutral-100', 'bg-white');
      }
    });
    if (method === 'mobile_money') {
      refGroup.style.display = 'block';
      if (refInput) refInput.required = true;
    } else {
      refGroup.style.display = 'none';
      if (refInput) { refInput.required = false; refInput.value = ''; }
    }
  }

  // Init on load
  (function() {
    var sel = document.getElementById('paymentMethodHidden');
    if (sel) toggleReference(sel.value);
    // Wire up label clicks
    document.querySelectorAll('.method-card').forEach(function(card) {
      card.addEventListener('click', function() {
        var radio = card.querySelector('input[type=radio]');
        if (radio) toggleReference(radio.value);
      });
    });
  })();

  // Client-side validation
  var form = document.getElementById('paymentForm');
  if (form) {
    form.addEventListener('submit', function(e) {
      var orderId = document.getElementById('orderId').value.trim();
      var amount  = document.getElementById('amount').value.trim();
      var method  = document.getElementById('paymentMethodHidden').value;
      var ref     = document.getElementById('transactionReference') ? document.getElementById('transactionReference').value.trim() : '';
      if (!orderId || parseInt(orderId) <= 0) { alert('Please enter a valid Order ID.'); e.preventDefault(); return; }
      if (!amount || parseFloat(amount) <= 0) { alert('Please enter a valid amount greater than zero.'); e.preventDefault(); return; }
      if (method === 'mobile_money' && ref === '') { alert('Please enter the M-Pesa transaction reference.'); e.preventDefault(); return; }
    });
  }
</script>
</body>
</html>
