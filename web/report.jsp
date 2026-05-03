<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.util.List, java.util.Map, model.DailyReport, model.User, model.dao.DailyReportDAO" %>
<%
    // Authorization handled by SessionFilter
    
    // Core Report Data
    List<DailyReport> reports = (List<DailyReport>) request.getAttribute("reports");
    if (reports == null) {
        DailyReportDAO dao = new DailyReportDAO();
        reports = dao.getAllReports();
        request.setAttribute("reports", reports);
    }
    
    // Calculate totals for stat cards using JSTL later or just here briefly
    double totalRev = 0; int totalOrders = 0;
    for (DailyReport r : reports) {
        totalRev += r.getTotalRevenue();
        totalOrders += r.getTotalOrders();
    }
    request.setAttribute("totalRev", totalRev);
    request.setAttribute("totalOrders", totalOrders);
    request.setAttribute("reportDays", reports.size());
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Admin Dashboard – University Restaurant</title>
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
    
    @media print {
        .no-print { display: none !important; }
        body { background: white !important; }
        .shadow-sm, .shadow-md, .shadow-2xl, .shadow-\[0_8px_40px_rgba\(0\,0\,0\,0\.08\)\] { box-shadow: none !important; border: 1px solid #e5e5e5; }
        * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
    }
  </style>
</head>
<body class="bg-[#fcf9f8] font-body text-neutral-800 min-h-screen flex flex-col">

<!-- Admin Navbar -->
<nav class="no-print flex justify-between items-center px-8 py-4 w-full sticky top-0 z-50 bg-white border-b border-neutral-100 shadow-[0_4px_12px_rgba(227,24,55,0.05)]">
  <a href="${pageContext.request.contextPath}/" class="text-2xl font-black italic tracking-tighter text-[#E31837] font-display">University Restaurant</a>
  <div class="hidden md:flex items-center gap-8 font-display">
    <a class="text-[#E31837] border-b-2 border-[#E31837] pb-1 font-bold" href="${pageContext.request.contextPath}/ReportServlet">Reports</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/AdminMenuServlet">Menu Items</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="${pageContext.request.contextPath}/AdminUserServlet">Users</a>
  </div>
  <div class="flex items-center gap-3">
    <div class="hidden md:flex items-center gap-2 bg-purple-50 border border-purple-200 text-purple-700 px-3 py-1.5 rounded-lg text-xs font-bold">
      <span class="material-symbols-outlined text-base">admin_panel_settings</span>Admin
    </div>
    <span class="text-sm font-bold text-neutral-600 hidden md:inline">👤 ${sessionScope.user.name}</span>
    <a href="${pageContext.request.contextPath}/LogoutServlet" class="material-symbols-outlined p-2 rounded-full hover:bg-neutral-100 text-neutral-500 transition-all" title="Logout">logout</a>
  </div>
</nav>

<!-- Page Header Banner -->
<div class="no-print bg-gradient-to-br from-neutral-900 to-[#521570] pt-10 pb-14 px-8 text-white relative overflow-hidden">
  <div class="absolute right-0 top-0 opacity-10 pointer-events-none">
    <span class="material-symbols-outlined text-[280px] absolute -top-12 -right-12">bar_chart</span>
  </div>
  <div class="max-w-6xl mx-auto relative z-10 flex flex-col md:flex-row md:items-end justify-between gap-4">
    <div>
      <span class="bg-white/20 text-white font-bold px-4 py-1 rounded-full text-xs mb-3 inline-block backdrop-blur-md">ADMIN DASHBOARD</span>
      <h1 class="font-display text-4xl font-black mb-2">System Analytics</h1>
      <p class="text-white/70 text-sm">Comprehensive view of restaurant activity, sales trends, and menu performance.</p>
    </div>
    <button onclick="window.print()" class="inline-flex items-center gap-2 bg-white/20 hover:bg-white/30 text-white border border-white/30 font-bold px-5 py-2.5 rounded-xl transition-all backdrop-blur-md text-sm">
      <span class="material-symbols-outlined text-lg">print</span> Print / Export PDF
    </button>
  </div>
</div>

<main class="flex-1 max-w-6xl mx-auto w-full px-4 md:px-8 -mt-6 pb-16">

  <!-- Stat Cards -->
  <div class="grid grid-cols-1 sm:grid-cols-3 gap-5 mb-8">
    <div class="bg-white rounded-2xl shadow-[0_4px_20px_rgba(0,0,0,0.06)] border border-neutral-100 p-6">
      <div class="flex items-center justify-between mb-4">
        <div class="w-12 h-12 bg-[#E31837]/10 rounded-xl flex items-center justify-center">
          <span class="material-symbols-outlined text-[#E31837] text-2xl">payments</span>
        </div>
        <span class="text-xs font-bold text-neutral-400 uppercase tracking-wider">Total Revenue</span>
      </div>
      <div class="font-display text-3xl font-black text-neutral-900">KES ${totalRev}</div>
    </div>
    <div class="bg-white rounded-2xl shadow-[0_4px_20px_rgba(0,0,0,0.06)] border border-neutral-100 p-6">
      <div class="flex items-center justify-between mb-4">
        <div class="w-12 h-12 bg-amber-100 rounded-xl flex items-center justify-center">
          <span class="material-symbols-outlined text-amber-600 text-2xl">receipt_long</span>
        </div>
        <span class="text-xs font-bold text-neutral-400 uppercase tracking-wider">Total Orders</span>
      </div>
      <div class="font-display text-3xl font-black text-neutral-900">${totalOrders}</div>
    </div>
    <div class="bg-white rounded-2xl shadow-[0_4px_20px_rgba(0,0,0,0.06)] border border-neutral-100 p-6">
      <div class="flex items-center justify-between mb-4">
        <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
          <span class="material-symbols-outlined text-green-600 text-2xl">calendar_month</span>
        </div>
        <span class="text-xs font-bold text-neutral-400 uppercase tracking-wider">Report Days</span>
      </div>
      <div class="font-display text-3xl font-black text-neutral-900">${reportDays}</div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
      
      <!-- 1. Sales Trends -->
      <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden flex flex-col">
          <div class="px-6 py-4 border-b border-neutral-100 flex items-center gap-2 bg-neutral-50">
            <span class="material-symbols-outlined text-[#E31837]">trending_up</span>
            <h2 class="font-display font-bold">1. Recent Sales Trends</h2>
          </div>
          <div class="p-6 flex-1">
              <table class="w-full text-sm">
                  <thead>
                      <tr class="border-b-2 border-neutral-100">
                          <th class="text-left pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Date</th>
                          <th class="text-right pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Revenue Generated</th>
                      </tr>
                  </thead>
                  <tbody class="divide-y divide-neutral-50">
                      <c:forEach var="entry" items="${salesTrends}">
                          <tr>
                              <td class="py-3 font-bold text-neutral-700">${entry.key}</td>
                              <td class="py-3 text-right font-bold text-[#E31837]">KES ${entry.value}</td>
                          </tr>
                      </c:forEach>
                      <c:if test="${empty salesTrends}">
                          <tr><td colspan="2" class="py-8 text-center text-neutral-400 italic">No recent sales data available.</td></tr>
                      </c:if>
                  </tbody>
              </table>
          </div>
      </div>

      <!-- 2. Order Status Breakdown -->
      <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden flex flex-col">
          <div class="px-6 py-4 border-b border-neutral-100 flex items-center gap-2 bg-neutral-50">
            <span class="material-symbols-outlined text-amber-600">pie_chart</span>
            <h2 class="font-display font-bold">2. Orders by Status</h2>
          </div>
          <div class="p-6 flex-1">
              <table class="w-full text-sm">
                  <thead>
                      <tr class="border-b-2 border-neutral-100">
                          <th class="text-left pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Status</th>
                          <th class="text-right pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Count</th>
                      </tr>
                  </thead>
                  <tbody class="divide-y divide-neutral-50">
                      <c:forEach var="entry" items="${orderStatusBreakdown}">
                          <tr>
                              <td class="py-3 font-bold text-neutral-700 capitalize">${entry.key}</td>
                              <td class="py-3 text-right font-bold text-neutral-900">${entry.value} orders</td>
                          </tr>
                      </c:forEach>
                      <c:if test="${empty orderStatusBreakdown}">
                          <tr><td colspan="2" class="py-6 text-center text-neutral-400">No data available</td></tr>
                      </c:if>
                  </tbody>
              </table>
          </div>
      </div>

      <!-- 3. Revenue by Payment Method -->
      <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden flex flex-col">
          <div class="px-6 py-4 border-b border-neutral-100 flex items-center gap-2 bg-neutral-50">
            <span class="material-symbols-outlined text-green-600">account_balance_wallet</span>
            <h2 class="font-display font-bold">3. Revenue Analytics by Method</h2>
          </div>
          <div class="p-6 flex-1">
              <table class="w-full text-sm">
                  <thead>
                      <tr class="border-b-2 border-neutral-100">
                          <th class="text-left pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Method</th>
                          <th class="text-right pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Total Collected</th>
                      </tr>
                  </thead>
                  <tbody class="divide-y divide-neutral-50">
                      <c:forEach var="entry" items="${revenueByMethod}">
                          <tr>
                              <td class="py-3 font-bold text-neutral-700 capitalize">${fn:replace(entry.key, '_', ' ')}</td>
                              <td class="py-3 text-right font-bold text-[#E31837]">KES ${entry.value}</td>
                          </tr>
                      </c:forEach>
                      <c:if test="${empty revenueByMethod}">
                          <tr><td colspan="2" class="py-6 text-center text-neutral-400">No data available</td></tr>
                      </c:if>
                  </tbody>
              </table>
          </div>
      </div>

      <!-- 4. Top Users -->
      <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden flex flex-col">
          <div class="px-6 py-4 border-b border-neutral-100 flex items-center gap-2 bg-neutral-50">
            <span class="material-symbols-outlined text-blue-600">groups</span>
            <h2 class="font-display font-bold">4. User Activity (Top 5 Customers)</h2>
          </div>
          <div class="p-6 flex-1">
              <table class="w-full text-sm">
                  <thead>
                      <tr class="border-b-2 border-neutral-100">
                          <th class="text-left pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Customer Name</th>
                          <th class="text-center pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Orders</th>
                          <th class="text-right pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Total Spent</th>
                      </tr>
                  </thead>
                  <tbody class="divide-y divide-neutral-50">
                      <c:forEach var="uMap" items="${topUsers}">
                          <tr>
                              <td class="py-3 font-bold text-neutral-700">${uMap.name}</td>
                              <td class="py-3 text-center"><span class="bg-neutral-100 text-neutral-700 px-2 py-1 rounded font-bold text-xs">${uMap.order_count}</span></td>
                              <td class="py-3 text-right font-bold text-[#E31837]">KES ${uMap.total_spent}</td>
                          </tr>
                      </c:forEach>
                      <c:if test="${empty topUsers}">
                          <tr><td colspan="3" class="py-6 text-center text-neutral-400">No data available</td></tr>
                      </c:if>
                  </tbody>
              </table>
          </div>
      </div>
  </div>

  <!-- 5. Menu Performance -->
  <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden mb-8">
      <div class="px-6 py-4 border-b border-neutral-100 flex items-center gap-2 bg-neutral-50">
        <span class="material-symbols-outlined text-purple-600">restaurant_menu</span>
        <h2 class="font-display font-bold">5. Menu Item Performance (Top 10)</h2>
      </div>
      <div class="p-6">
          <table class="w-full text-sm">
              <thead>
                  <tr class="border-b-2 border-neutral-100">
                      <th class="text-left pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Item Name</th>
                      <th class="text-center pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Quantity Sold</th>
                      <th class="text-right pb-3 font-bold text-neutral-500 uppercase tracking-wider text-xs">Total Revenue Generated</th>
                  </tr>
              </thead>
              <tbody class="divide-y divide-neutral-50">
                  <c:forEach var="m" items="${menuPerformance}">
                      <tr class="hover:bg-neutral-50/50 transition-colors">
                          <td class="py-4 font-bold text-neutral-800">${m.name}</td>
                          <td class="py-4 text-center"><span class="bg-purple-50 text-purple-700 px-2 py-1 rounded font-bold text-xs">${m.qty_sold} items</span></td>
                          <td class="py-4 text-right font-bold text-[#E31837]">KES ${m.revenue}</td>
                      </tr>
                  </c:forEach>
                  <c:if test="${empty menuPerformance}">
                      <tr><td colspan="3" class="py-6 text-center text-neutral-400">No data available</td></tr>
                  </c:if>
              </tbody>
          </table>
      </div>
  </div>

  <!-- 6. Raw Daily Reports Log -->
  <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden">
    <div class="px-6 py-4 border-b border-neutral-100 flex items-center gap-2 bg-neutral-50">
      <span class="material-symbols-outlined text-neutral-500">table_rows</span>
      <h2 class="font-display font-bold">6. Raw Daily Operations Log</h2>
    </div>

    <c:choose>
      <c:when test="${empty reports}">
        <div class="p-16 text-center">
          <div class="w-20 h-20 bg-neutral-100 rounded-full flex items-center justify-center mx-auto mb-5">
            <span class="material-symbols-outlined text-neutral-400 text-4xl">inventory_2</span>
          </div>
          <h3 class="font-display text-xl font-bold text-neutral-700 mb-2">No Reports Yet</h3>
        </div>
      </c:when>
      <c:otherwise>
        <div class="overflow-x-auto">
          <table class="w-full text-sm">
            <thead class="bg-neutral-50">
              <tr>
                <th class="text-left px-6 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Date</th>
                <th class="text-center px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Total Orders</th>
                <th class="text-right px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Revenue (KES)</th>
                <th class="text-center px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Breakfast</th>
                <th class="text-center px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Lunch</th>
                <th class="text-center px-4 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Dinner</th>
                <th class="text-right px-6 py-3.5 font-bold text-neutral-500 uppercase tracking-wider text-xs">Avg Wait (min)</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-neutral-50">
              <c:forEach var="r" items="${reports}">
              <tr class="hover:bg-neutral-50/50 transition-colors">
                <td class="px-6 py-4 font-bold text-neutral-700">${r.reportDate}</td>
                <td class="px-4 py-4 text-center">
                  <span class="inline-flex items-center justify-center w-8 h-8 bg-neutral-100 text-neutral-700 font-bold rounded-lg text-sm">${r.totalOrders}</span>
                </td>
                <td class="px-4 py-4 text-right font-display font-bold text-[#E31837]">KES ${r.totalRevenue}</td>
                <td class="px-4 py-4 text-center text-neutral-600">${r.breakfastOrders}</td>
                <td class="px-4 py-4 text-center text-neutral-600">${r.lunchOrders}</td>
                <td class="px-4 py-4 text-center text-neutral-600">${r.dinnerOrders}</td>
                <td class="px-6 py-4 text-right text-neutral-500">${r.avgWaitTime} min</td>
              </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</main>

<footer class="no-print bg-neutral-950 text-neutral-500 text-center py-6 text-xs mt-auto">
  © 2026 University Restaurant
</footer>
</body>
</html>
