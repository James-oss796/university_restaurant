<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"admin".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<User> usersList = (List<User>) request.getAttribute("usersList");
    String ctxPath = request.getContextPath();
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>User Management – University Restaurant</title>
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
    /* Modal styles */
    .modal { display: none; }
    .modal.active { display: flex; }
  </style>
</head>
<body class="bg-[#fcf9f8] font-body text-neutral-800 min-h-screen flex flex-col">

<!-- Admin Navbar -->
<nav class="flex justify-between items-center px-8 py-4 w-full sticky top-0 z-50 bg-white border-b border-neutral-100 shadow-[0_4px_12px_rgba(227,24,55,0.05)]">
  <a href="<%= ctxPath %>/" class="text-2xl font-black italic tracking-tighter text-[#E31837] font-display">University Restaurant</a>
  <div class="hidden md:flex items-center gap-8 font-display">
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="<%= ctxPath %>/ReportServlet">Reports</a>
    <a class="text-neutral-500 hover:text-[#E31837] transition-colors" href="<%= ctxPath %>/AdminMenuServlet">Menu Items</a>
    <a class="text-[#E31837] border-b-2 border-[#E31837] pb-1 font-bold" href="<%= ctxPath %>/AdminUserServlet">Users</a>
  </div>
  <div class="flex items-center gap-3">
    <div class="hidden md:flex items-center gap-2 bg-purple-50 border border-purple-200 text-purple-700 px-3 py-1.5 rounded-lg text-xs font-bold">
      <span class="material-symbols-outlined text-base">admin_panel_settings</span>Admin
    </div>
    <span class="text-sm font-bold text-neutral-600 hidden md:inline">👤 <%= sessionUser.getName() %></span>
    <a href="<%= ctxPath %>/LogoutServlet" class="material-symbols-outlined p-2 rounded-full hover:bg-neutral-100 text-neutral-500 transition-all" title="Logout">logout</a>
  </div>
</nav>

<!-- Page Header Banner -->
<div class="bg-gradient-to-br from-neutral-900 to-[#521570] pt-10 pb-14 px-8 text-white relative overflow-hidden">
  <div class="absolute right-0 top-0 opacity-10 pointer-events-none">
    <span class="material-symbols-outlined text-[280px] absolute -top-12 -right-12">manage_accounts</span>
  </div>
  <div class="max-w-6xl mx-auto relative z-10 flex flex-col md:flex-row md:items-end justify-between gap-4">
    <div>
      <span class="bg-white/20 text-white font-bold px-4 py-1 rounded-full text-xs mb-3 inline-block backdrop-blur-md">USER MANAGEMENT</span>
      <h1 class="font-display text-4xl font-black mb-2">Manage Users</h1>
      <p class="text-white/70 text-sm">Create and manage Cashiers, Admins, and Student accounts.</p>
    </div>
    <button onclick="openModal('addModal')"
            class="inline-flex items-center gap-2 bg-[#E31837] text-white font-bold px-6 py-3 rounded-xl hover:-translate-y-0.5 transition-all shadow-[0_4px_16px_rgba(227,24,55,0.4)]">
      <span class="material-symbols-outlined">person_add</span> Create User
    </button>
  </div>
</div>

<main class="flex-1 max-w-6xl mx-auto w-full px-4 -mt-6 pb-16">

  <!-- Flash Messages -->
  <% if (successMsg != null) { %>
  <div class="flex items-center gap-3 bg-green-50 border border-green-200 text-green-700 px-5 py-4 rounded-2xl mb-6 font-semibold text-sm">
    <span class="material-symbols-outlined text-green-500 text-xl">check_circle</span>
    <%= successMsg %>
  </div>
  <% } %>
  <% if (errorMsg != null) { %>
  <div class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-700 px-5 py-4 rounded-2xl mb-6 font-semibold text-sm">
    <span class="material-symbols-outlined text-red-500 text-xl">error</span>
    <%= errorMsg %>
  </div>
  <% } %>

  <!-- Users Table -->
  <div class="bg-white rounded-3xl shadow-[0_8px_40px_rgba(0,0,0,0.08)] border border-neutral-100 overflow-hidden">
    <% if (usersList == null || usersList.isEmpty()) { %>
    <div class="p-16 text-center">
      <div class="w-20 h-20 bg-neutral-100 rounded-full flex items-center justify-center mx-auto mb-5">
        <span class="material-symbols-outlined text-neutral-400 text-4xl">group</span>
      </div>
      <h3 class="font-display text-xl font-bold text-neutral-700 mb-2">No Users Found</h3>
      <button onclick="openModal('addModal')" class="bg-[#E31837] text-white px-6 py-2.5 rounded-lg font-bold text-sm hover:-translate-y-0.5 transition-all">Create User</button>
    </div>
    <% } else { %>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-neutral-50">
          <tr>
            <th class="text-left px-6 py-4 font-bold text-neutral-500 uppercase tracking-wider text-xs">Name</th>
            <th class="text-left px-4 py-4 font-bold text-neutral-500 uppercase tracking-wider text-xs">Contact</th>
            <th class="text-center px-4 py-4 font-bold text-neutral-500 uppercase tracking-wider text-xs">Role</th>
            <th class="text-center px-4 py-4 font-bold text-neutral-500 uppercase tracking-wider text-xs">Status</th>
            <th class="text-right px-6 py-4 font-bold text-neutral-500 uppercase tracking-wider text-xs">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-neutral-50">
          <% for (User u : usersList) { %>
          <tr class="hover:bg-neutral-50/50 transition-colors">
            <td class="px-6 py-3">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-[#E31837]/10 text-[#E31837] flex items-center justify-center font-bold font-display">
                  <%= u.getName().substring(0, 1).toUpperCase() %>
                </div>
                <div>
                  <div class="font-bold text-neutral-900"><%= u.getName() %></div>
                  <% if (u.getStudentId() != null && !u.getStudentId().isEmpty()) { %>
                  <div class="text-xs text-neutral-400 mt-0.5">ID: <%= u.getStudentId() %></div>
                  <% } %>
                </div>
              </div>
            </td>
            <td class="px-4 py-3">
              <div class="text-neutral-700 font-medium"><%= u.getEmail() %></div>
              <div class="text-xs text-neutral-500 mt-0.5"><%= u.getPhoneNumber() != null ? u.getPhoneNumber() : "—" %></div>
            </td>
            <td class="px-4 py-3 text-center">
              <% if ("admin".equals(u.getRole())) { %>
                <span class="inline-block px-2.5 py-1 bg-purple-50 text-purple-700 text-xs font-bold rounded-md uppercase tracking-wider">Admin</span>
              <% } else if ("cashier".equals(u.getRole())) { %>
                <span class="inline-block px-2.5 py-1 bg-blue-50 text-blue-700 text-xs font-bold rounded-md uppercase tracking-wider">Cashier</span>
              <% } else { %>
                <span class="inline-block px-2.5 py-1 bg-neutral-100 text-neutral-600 text-xs font-bold rounded-md uppercase tracking-wider">Student</span>
              <% } %>
            </td>
            <td class="px-4 py-3 text-center">
              <% if (u.isActive()) { %>
              <span class="inline-flex items-center gap-1 bg-green-50 text-green-700 border border-green-200 px-2.5 py-1 rounded-full text-xs font-bold">
                <span class="w-1.5 h-1.5 rounded-full bg-green-500"></span> Active
              </span>
              <% } else { %>
              <span class="inline-flex items-center gap-1 bg-neutral-100 text-neutral-500 border border-neutral-200 px-2.5 py-1 rounded-full text-xs font-bold">
                <span class="w-1.5 h-1.5 rounded-full bg-neutral-400"></span> Inactive
              </span>
              <% } %>
            </td>
            <td class="px-6 py-3 text-right">
              <button onclick='openEditModal(<%= u.getUserId() %>, "<%= u.getName().replace("\"", "&quot;") %>", "<%= u.getEmail() %>", "<%= u.getPhoneNumber() != null ? u.getPhoneNumber() : "" %>", "<%= u.getRole() %>", <%= u.isActive() %>)'
                      class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors" title="Edit User">
                <span class="material-symbols-outlined text-[18px]">edit</span>
              </button>
              
              <% if (u.getUserId() != sessionUser.getUserId()) { %>
                  <% if (u.isActive()) { %>
                  <form action="<%= ctxPath %>/AdminUserServlet" method="post" class="inline-block ml-1">
                    <input type="hidden" name="action" value="deactivate" />
                    <input type="hidden" name="user_id" value="<%= u.getUserId() %>" />
                    <button type="submit" class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-colors" title="Deactivate User" onclick="return confirm('Deactivate this user?');">
                      <span class="material-symbols-outlined text-[18px]">block</span>
                    </button>
                  </form>
                  <% } else { %>
                  <form action="<%= ctxPath %>/AdminUserServlet" method="post" class="inline-block ml-1">
                    <input type="hidden" name="action" value="activate" />
                    <input type="hidden" name="user_id" value="<%= u.getUserId() %>" />
                    <button type="submit" class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-green-50 text-green-600 hover:bg-green-100 transition-colors" title="Activate User" onclick="return confirm('Activate this user?');">
                      <span class="material-symbols-outlined text-[18px]">check_circle</span>
                    </button>
                  </form>
                  <% } %>
              <% } else { %>
                  <span class="inline-block ml-1 w-8 h-8"></span> <!-- placeholder for alignment -->
              <% } %>
            </td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <% } %>
  </div>
</main>

<footer class="bg-neutral-950 text-neutral-500 text-center py-6 text-xs mt-auto">
  © 2026 University Restaurant
</footer>

<!-- Add Modal -->
<div id="addModal" class="modal fixed inset-0 z-[100] items-center justify-center bg-neutral-900/50 backdrop-blur-sm p-4">
  <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden transform transition-all">
    <div class="px-6 py-5 border-b border-neutral-100 flex justify-between items-center bg-neutral-50">
      <h3 class="font-display font-bold text-lg">Create New User</h3>
      <button onclick="closeModal('addModal')" class="text-neutral-400 hover:text-neutral-700 transition-colors">
        <span class="material-symbols-outlined">close</span>
      </button>
    </div>
    <form action="<%= ctxPath %>/AdminUserServlet" method="post" class="p-6">
      <input type="hidden" name="action" value="add" />
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-bold text-neutral-700 mb-1.5">Full Name <span class="text-[#E31837]">*</span></label>
          <input type="text" name="name" required class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors"/>
        </div>
        <div>
          <label class="block text-sm font-bold text-neutral-700 mb-1.5">Email Address <span class="text-[#E31837]">*</span></label>
          <input type="email" name="email" required class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors"/>
        </div>
        <div>
          <label class="block text-sm font-bold text-neutral-700 mb-1.5">Phone Number</label>
          <input type="text" name="phone_number" class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors"/>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-bold text-neutral-700 mb-1.5">Role <span class="text-[#E31837]">*</span></label>
            <select name="role" required class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors bg-white">
              <option value="student">Student</option>
              <option value="cashier">Cashier</option>
              <option value="admin">Admin</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-bold text-neutral-700 mb-1.5">Password <span class="text-[#E31837]">*</span></label>
            <input type="password" name="password" required class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors"/>
          </div>
        </div>
        <div class="flex items-center mt-2">
          <input type="checkbox" name="is_active" id="addActive" value="true" checked class="w-4 h-4 text-[#E31837] border-neutral-300 rounded focus:ring-[#E31837]">
          <label for="addActive" class="ml-2 block text-sm font-bold text-neutral-700">Account Active</label>
        </div>
      </div>
      <div class="mt-8 flex justify-end gap-3">
        <button type="button" onclick="closeModal('addModal')" class="px-5 py-2.5 text-sm font-bold text-neutral-500 hover:text-neutral-800 transition-colors">Cancel</button>
        <button type="submit" class="bg-[#E31837] text-white px-6 py-2.5 rounded-xl font-bold text-sm hover:bg-[#b90027] transition-colors shadow-md">Create User</button>
      </div>
    </form>
  </div>
</div>

<!-- Edit Modal -->
<div id="editModal" class="modal fixed inset-0 z-[100] items-center justify-center bg-neutral-900/50 backdrop-blur-sm p-4">
  <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden transform transition-all">
    <div class="px-6 py-5 border-b border-neutral-100 flex justify-between items-center bg-neutral-50">
      <h3 class="font-display font-bold text-lg">Edit User</h3>
      <button onclick="closeModal('editModal')" class="text-neutral-400 hover:text-neutral-700 transition-colors">
        <span class="material-symbols-outlined">close</span>
      </button>
    </div>
    <form action="<%= ctxPath %>/AdminUserServlet" method="post" class="p-6">
      <input type="hidden" name="action" value="edit" />
      <input type="hidden" name="user_id" id="editUserId" />
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-bold text-neutral-700 mb-1.5">Full Name <span class="text-[#E31837]">*</span></label>
          <input type="text" name="name" id="editName" required class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors"/>
        </div>
        <div>
          <label class="block text-sm font-bold text-neutral-700 mb-1.5">Email Address <span class="text-[#E31837]">*</span></label>
          <input type="email" name="email" id="editEmail" required class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors"/>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-bold text-neutral-700 mb-1.5">Phone Number</label>
            <input type="text" name="phone_number" id="editPhone" class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors"/>
          </div>
          <div>
            <label class="block text-sm font-bold text-neutral-700 mb-1.5">Role <span class="text-[#E31837]">*</span></label>
            <select name="role" id="editRole" required class="w-full px-4 py-2.5 border-2 border-neutral-200 rounded-xl text-sm focus:border-[#E31837] focus:ring-0 transition-colors bg-white">
              <option value="student">Student</option>
              <option value="cashier">Cashier</option>
              <option value="admin">Admin</option>
            </select>
          </div>
        </div>
        <div class="flex items-center mt-2">
          <input type="checkbox" name="is_active" id="editActive" value="true" class="w-4 h-4 text-[#E31837] border-neutral-300 rounded focus:ring-[#E31837]">
          <label for="editActive" class="ml-2 block text-sm font-bold text-neutral-700">Account Active</label>
        </div>
      </div>
      <div class="mt-8 flex justify-end gap-3">
        <button type="button" onclick="closeModal('editModal')" class="px-5 py-2.5 text-sm font-bold text-neutral-500 hover:text-neutral-800 transition-colors">Cancel</button>
        <button type="submit" class="bg-[#E31837] text-white px-6 py-2.5 rounded-xl font-bold text-sm hover:bg-[#b90027] transition-colors shadow-md">Save Changes</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openModal(id) { document.getElementById(id).classList.add('active'); }
  function closeModal(id) { document.getElementById(id).classList.remove('active'); }
  
  function openEditModal(id, name, email, phone, role, isActive) {
    document.getElementById('editUserId').value = id;
    document.getElementById('editName').value = name;
    document.getElementById('editEmail').value = email;
    document.getElementById('editPhone').value = phone;
    document.getElementById('editRole').value = role;
    document.getElementById('editActive').checked = isActive;
    openModal('editModal');
  }

  // Close modals on escape key or clicking outside
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') { closeModal('addModal'); closeModal('editModal'); }
  });
  document.querySelectorAll('.modal').forEach(function(modal) {
    modal.addEventListener('click', function(e) {
      if (e.target === this) closeModal(this.id);
    });
  });
</script>
</body>
</html>
