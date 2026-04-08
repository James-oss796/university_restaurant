<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.MenuItem" %>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"student".equals(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    List<MenuItem> menuItems = (List<MenuItem>) request.getAttribute("menuItems");
    if (menuItems == null) {
        response.sendRedirect(request.getContextPath() + "/MenuServlet");
        return;
    }

    String errorMsg = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu | University Restaurant</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles.css">
</head>
<body>
    <jsp:include page="layout.jsp" />

    <main class="page-shell">
        <% if (menuItems.isEmpty()) { %>
            <section class="card">
                <h2 class="section-title">Menu Unavailable</h2>
                <div class="empty-state">
                    No menu items are currently available. Add menu data to the database and refresh this page.
                </div>
            </section>
        <% } else { %>
            <form action="${pageContext.request.contextPath}/OrderServlet" method="post" id="menuForm" class="menu-layout">
                <section class="card menu-board">
                    <div class="menu-board-head">
                        <div>
                            <h2 class="section-title">Today's Menu</h2>
                            <p class="section-subtitle">Choose your meal, adjust quantities with the controls, and review the live total before placing the order.</p>
                        </div>
                        <div class="menu-board-note">Freshly prepared campus favourites</div>
                    </div>

                    <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                        <div class="alert alert-error"><%= errorMsg %></div>
                    <% } %>

                    <section class="menu-section">
                        <div class="menu-section-head">
                            <h3>Breakfast</h3>
                            <p>Light and energizing options for the morning rush.</p>
                        </div>
                        <div class="menu-grid">
                            <% for (MenuItem item : menuItems) {
                                   if ("breakfast".equals(item.getMealPeriod())) {
                                       pageContext.setAttribute("item", item);
                            %>
                                <article class="menu-card" data-menu-item data-name="${item.name}" data-price="${item.price}">
                                    <span class="menu-chip">Breakfast</span>
                                    <h4>${item.name}</h4>
                                    <p>${item.description}</p>
                                    <div class="menu-card-footer">
                                        <div class="menu-price">KES <%= String.format("%.2f", item.getPrice()) %></div>
                                        <div class="quantity-picker">
                                            <button class="qty-btn" type="button" data-step="-1" aria-label="Reduce ${item.name} quantity">-</button>
                                            <input class="qty-input" type="number" name="qty_${item.menuId}" min="0" value="0" readonly>
                                            <button class="qty-btn" type="button" data-step="1" aria-label="Increase ${item.name} quantity">+</button>
                                        </div>
                                    </div>
                                </article>
                            <%     }
                               }
                            %>
                        </div>
                    </section>

                    <section class="menu-section">
                        <div class="menu-section-head">
                            <h3>Lunch</h3>
                            <p>Balanced meals prepared for the busiest part of the day.</p>
                        </div>
                        <div class="menu-grid">
                            <% for (MenuItem item : menuItems) {
                                   if ("lunch".equals(item.getMealPeriod())) {
                                       pageContext.setAttribute("item", item);
                            %>
                                <article class="menu-card" data-menu-item data-name="${item.name}" data-price="${item.price}">
                                    <span class="menu-chip">Lunch</span>
                                    <h4>${item.name}</h4>
                                    <p>${item.description}</p>
                                    <div class="menu-card-footer">
                                        <div class="menu-price">KES <%= String.format("%.2f", item.getPrice()) %></div>
                                        <div class="quantity-picker">
                                            <button class="qty-btn" type="button" data-step="-1" aria-label="Reduce ${item.name} quantity">-</button>
                                            <input class="qty-input" type="number" name="qty_${item.menuId}" min="0" value="0" readonly>
                                            <button class="qty-btn" type="button" data-step="1" aria-label="Increase ${item.name} quantity">+</button>
                                        </div>
                                    </div>
                                </article>
                            <%     }
                               }
                            %>
                        </div>
                    </section>

                    <section class="menu-section">
                        <div class="menu-section-head">
                            <h3>Dinner</h3>
                            <p>Hearty selections for evening service and late pickups.</p>
                        </div>
                        <div class="menu-grid">
                            <% for (MenuItem item : menuItems) {
                                   if ("dinner".equals(item.getMealPeriod())) {
                                       pageContext.setAttribute("item", item);
                            %>
                                <article class="menu-card" data-menu-item data-name="${item.name}" data-price="${item.price}">
                                    <span class="menu-chip">Dinner</span>
                                    <h4>${item.name}</h4>
                                    <p>${item.description}</p>
                                    <div class="menu-card-footer">
                                        <div class="menu-price">KES <%= String.format("%.2f", item.getPrice()) %></div>
                                        <div class="quantity-picker">
                                            <button class="qty-btn" type="button" data-step="-1" aria-label="Reduce ${item.name} quantity">-</button>
                                            <input class="qty-input" type="number" name="qty_${item.menuId}" min="0" value="0" readonly>
                                            <button class="qty-btn" type="button" data-step="1" aria-label="Increase ${item.name} quantity">+</button>
                                        </div>
                                    </div>
                                </article>
                            <%     }
                               }
                            %>
                        </div>
                    </section>

                    <section class="menu-section">
                        <div class="menu-section-head">
                            <h3>All Day</h3>
                            <p>Quick add-ons and favourites available throughout the day.</p>
                        </div>
                        <div class="menu-grid">
                            <% for (MenuItem item : menuItems) {
                                   if ("all_day".equals(item.getMealPeriod())) {
                                       pageContext.setAttribute("item", item);
                            %>
                                <article class="menu-card" data-menu-item data-name="${item.name}" data-price="${item.price}">
                                    <span class="menu-chip">All Day</span>
                                    <h4>${item.name}</h4>
                                    <p>${item.description}</p>
                                    <div class="menu-card-footer">
                                        <div class="menu-price">KES <%= String.format("%.2f", item.getPrice()) %></div>
                                        <div class="quantity-picker">
                                            <button class="qty-btn" type="button" data-step="-1" aria-label="Reduce ${item.name} quantity">-</button>
                                            <input class="qty-input" type="number" name="qty_${item.menuId}" min="0" value="0" readonly>
                                            <button class="qty-btn" type="button" data-step="1" aria-label="Increase ${item.name} quantity">+</button>
                                        </div>
                                    </div>
                                </article>
                            <%     }
                               }
                            %>
                        </div>
                    </section>
                </section>

                <aside class="card order-sidebar">
                    <h2 class="section-title">Order Summary</h2>
                    <p class="section-subtitle">Your total updates instantly as you select quantities.</p>

                    <div class="summary-stat">
                        <span>Items Selected</span>
                        <strong id="summaryCount">0</strong>
                    </div>
                    <div class="summary-stat total">
                        <span>Total</span>
                        <strong id="summaryTotal">KES 0.00</strong>
                    </div>

                    <div id="summaryList" class="summary-list empty-state">
                        No items selected yet.
                    </div>

                    <div class="actions actions-column">
                        <button class="btn btn-primary" id="reviewOrderButton" type="submit" disabled>Review Order</button>
                        <a class="btn btn-light" href="${pageContext.request.contextPath}/NotificationServlet">Notifications</a>
                    </div>
                </aside>
            </form>
        <% } %>
    </main>

    <script>
        (function () {
            var form = document.getElementById('menuForm');
            if (!form) return;

            var totalNode = document.getElementById('summaryTotal');
            var countNode = document.getElementById('summaryCount');
            var listNode = document.getElementById('summaryList');
            var reviewButton = document.getElementById('reviewOrderButton');
            var cards = form.querySelectorAll('[data-menu-item]');

            function formatMoney(value) {
                return 'KES ' + value.toFixed(2);
            }

            function updateSummary() {
                var total = 0;
                var count = 0;
                var rows = [];

                cards.forEach(function (card) {
                    var input = card.querySelector('.qty-input');
                    var quantity = parseInt(input.value || '0', 10);
                    var price = parseFloat(card.dataset.price || '0');
                    var name = card.dataset.name || 'Item';

                    if (quantity > 0) {
                        count += quantity;
                        total += price * quantity;
                        rows.push('<div class="summary-line"><span>' + name + ' x' + quantity + '</span><strong>' + formatMoney(price * quantity) + '</strong></div>');
                    }
                });

                countNode.textContent = count;
                totalNode.textContent = formatMoney(total);
                reviewButton.disabled = count === 0;

                if (rows.length === 0) {
                    listNode.className = 'summary-list empty-state';
                    listNode.textContent = 'No items selected yet.';
                } else {
                    listNode.className = 'summary-list';
                    listNode.innerHTML = rows.join('');
                }
            }

            form.querySelectorAll('.qty-btn').forEach(function (button) {
                button.addEventListener('click', function () {
                    var input = button.parentElement.querySelector('.qty-input');
                    var current = parseInt(input.value || '0', 10);
                    var step = parseInt(button.dataset.step || '0', 10);
                    var next = Math.max(0, current + step);
                    input.value = next;
                    updateSummary();
                });
            });

            updateSummary();
        })();
    </script>
</body>
</html>
