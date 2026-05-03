<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login – University Restaurant</title>
  <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
  <link href="https://fonts.googleapis.com/css2?family=Epilogue:wght@400;700;800;900&family=Be+Vietnam+Pro:wght@400;500;700&display=swap" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: { 'display': ['Epilogue'], 'body': ['Be Vietnam Pro'] }
        }
      }
    }
  </script>
  <style>
    .material-symbols-outlined { font-variation-settings: 'FILL' 0,'wght' 400,'GRAD' 0,'opsz' 24; }

    .glass-card {
      background: rgba(255,255,255,0.85);
      backdrop-filter: blur(24px);
      border: 1px solid rgba(255,255,255,0.5);
    }
  </style>
</head>
<body class="bg-[url('${pageContext.request.contextPath}/images/login_bg.jpg')] bg-cover bg-center min-h-screen flex flex-col font-body before:absolute before:inset-0 before:bg-black/40 before:z-[-1]">

<!-- Minimal Navbar -->
<nav class="flex justify-between items-center px-8 py-4 w-full z-10 relative">
  <a href="${pageContext.request.contextPath}/" class="text-2xl font-black italic tracking-tighter text-white font-display">
    University Restaurant
  </a>
  <a href="${pageContext.request.contextPath}/RegisterServlet"
     class="bg-white/10 hover:bg-white/20 text-white border border-white/30 px-5 py-2 rounded-lg font-bold text-sm transition-all backdrop-blur-sm">
    Sign Up
  </a>
</nav>

<!-- Auth Card -->
<div class="flex-1 flex items-center justify-center px-4 py-12">
  <div class="glass-card w-full max-w-md rounded-3xl shadow-[0_32px_80px_rgba(0,0,0,0.4)] p-10">

    <!-- Logo Mark -->
    <div class="flex flex-col items-center mb-8">
      <div class="w-16 h-16 bg-[#E31837] rounded-2xl flex items-center justify-center shadow-lg mb-4 rotate-3">
        <span class="material-symbols-outlined text-white text-3xl">local_fire_department</span>
      </div>
      <h1 class="font-display text-3xl font-black text-neutral-900">Welcome Back!</h1>
      <p class="text-neutral-500 mt-1 text-sm">Sign in to order your favourite meals</p>
    </div>

    <!-- Error / Success Alerts -->
    <c:if test="${not empty error}">
    <div class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-5 text-sm font-semibold">
      <span class="material-symbols-outlined text-red-500 text-xl">error</span>
      ${error}
    </div>
    </c:if>
    <c:if test="${not empty message}">
    <div class="flex items-center gap-3 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl mb-5 text-sm font-semibold">
      <span class="material-symbols-outlined text-green-500 text-xl">check_circle</span>
      ${message}
    </div>
    </c:if>

    <!-- Form -->
    <form action="${pageContext.request.contextPath}/LoginServlet" method="post" class="space-y-5">
      <div>
        <label for="email" class="block text-sm font-bold text-neutral-700 mb-1.5">Email Address</label>
        <div class="relative">
          <span class="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-neutral-400 text-xl">mail</span>
          <input id="email" type="email" name="email" value="${emailValue}"
                 placeholder="you@university.ac.ke" required autocomplete="email"
                 class="w-full pl-11 pr-4 py-3 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors bg-neutral-50 focus:bg-white"/>
        </div>
      </div>
      <div>
        <label for="password" class="block text-sm font-bold text-neutral-700 mb-1.5">Password</label>
        <div class="relative">
          <span class="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-neutral-400 text-xl">lock</span>
          <input id="password" type="password" name="password"
                 placeholder="Enter your password" required autocomplete="current-password"
                 class="w-full pl-11 pr-4 py-3 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors bg-neutral-50 focus:bg-white"/>
        </div>
      </div>
      
      <!-- Remember Me -->
      <div class="flex items-center justify-between">
        <label class="flex items-center gap-2 cursor-pointer group">
          <input type="checkbox" name="remember" class="w-4 h-4 rounded border-neutral-300 text-[#E31837] focus:ring-[#E31837]" ${not empty rememberChecked ? 'checked' : ''}/>
          <span class="text-xs font-bold text-neutral-600 group-hover:text-neutral-900 transition-colors">Remember Me</span>
        </label>
        <a href="#" class="text-xs font-bold text-[#E31837] hover:underline">Forgot Password?</a>
      </div>
      <button type="submit"
              class="w-full bg-[#E31837] hover:bg-[#b90027] text-white font-bold py-3.5 rounded-xl text-base shadow-[0_4px_16px_rgba(227,24,55,0.4)] hover:shadow-[0_6px_24px_rgba(227,24,55,0.6)] hover:-translate-y-0.5 transition-all active:scale-[0.98] flex items-center justify-center gap-2 mt-2">
        Login <span class="material-symbols-outlined text-xl">arrow_forward</span>
      </button>
    </form>

    <!-- Footer Links -->
    <div class="mt-6 text-center space-y-2 text-sm text-neutral-500">
      <p>Don't have an account?
        <a href="${pageContext.request.contextPath}/RegisterServlet" class="text-[#E31837] font-bold hover:underline">Register here</a>
      </p>
      <p><a href="${pageContext.request.contextPath}/" class="hover:text-[#E31837] transition-colors">← Back to Home</a></p>
    </div>
  </div>
</div>

<!-- Footer -->
<div class="text-center pb-6 text-white/40 text-xs">
  © 2026 University Restaurant University Restaurant
</div>

</body>
</html>
