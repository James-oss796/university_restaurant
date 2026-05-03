# University Restaurant System Setup Guide

This document provides step-by-step instructions to set up and run the University Restaurant application on a local machine.

## 1. Prerequisites
- **Java Development Kit (JDK)**: Version 17 or higher (the project is configured for modern Java).
- **Apache Tomcat**: Version 10.x (supports Jakarta EE 10).
- **MySQL Server**: Version 8.0 or higher.
- **NetBeans IDE**: (Recommended) For easy project management and deployment.

## 2. Database Setup
1. Open your MySQL client (e.g., MySQL Workbench or Command Line).
2. Locate the schema file: `src/java/database_schema.sql`.
3. Execute the entire script. This will:
   - Create the `university_restaurant` database.
   - Set up all tables (`users`, `menu_items`, `orders`, `payments`, etc.).
   - Pre-populate the system with default accounts and sample data for reports.

### Default Login Credentials
| Role    | Email                    | Password     |
|---------|--------------------------|--------------|
| Admin   | `admin@university.ac.ke`  | `Admin@2026` |
| Cashier | `cashier@university.ac.ke`| `Cashier@2026`|
| Student | `student@example.com`    | `Student@2026`|

## 3. Library Installation
The system requires the following libraries to be added to the project's classpath:

### Required JARs:
1. **MySQL Connector/J**: `mysql-connector-j-9.x.x.jar`
   - Purpose: Database connectivity.
   - [Download here](https://dev.mysql.com/downloads/connector/j/)

2. **Jakarta JSTL 3.0**: `jakarta.servlet.jsp.jstl-api-3.0.0.jar` & `jakarta.servlet.jsp.jstl-3.0.1.jar`
   - Purpose: Standard Tag Library for JSP (Modern tags like `<c:forEach>`).
   - **Direct Downloads**:
     - [Download JSTL API 3.0.0 (JAR)](https://repo1.maven.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar)
     - [Download JSTL Implementation 3.0.1 (JAR)](https://repo1.maven.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar)



### How to add in NetBeans:
1. Right-click on the project in the **Projects** pane.
2. Select **Properties** > **Libraries**.
3. Under the **Compile** tab, click **Add JAR/Folder**.
4. Select the following three files you downloaded:
   - `mysql-connector-j-9.x.x.jar`
   - `jakarta.servlet.jsp.jstl-api-3.0.0.jar`
   - `jakarta.servlet.jsp.jstl-3.0.1.jar`
5. Click **OK**.
6. Go to the **Run** category in the same Properties window and ensure **Apache Tomcat 10.x** (or higher) is selected. This provides the core Jakarta Servlet 6.0 libraries.


## 4. Configuration
Ensure the database connection details are correct in:
`src/java/model/dao/DBConnection.java`

Update the following variables if your MySQL setup differs:
- `URL`: `jdbc:mysql://localhost:3306/university_restaurant`
- `USER`: `root`
- `PASS`: `admin123` (As configured in DBConnection.java)

## 5. Deployment
1. Open the project in NetBeans.
2. Clean and Build the project (`Shift + F11`).
3. Right-click the project and select **Run**.
4. The application will launch at: `http://localhost:8080/UniversityRestaurant/`

## 6. Project Structure
- `src/java/controller`: Servlets handling logic and routing.
- `src/java/model`: Data models (POJOs) and DAOs (Direct database access).
- `web/`: JSP files for the frontend, CSS, and Image assets.
- `web/WEB-INF`: Configuration files (e.g., `web.xml`).

---
**Note for Partners**: After cloning, verify that your NetBeans is pointing to a valid Tomcat 10 installation to avoid "Class not found" errors for Jakarta packages.
