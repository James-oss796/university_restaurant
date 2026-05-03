package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/university_restaurant?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASS = "admin123";
    
    private static final int INITIAL_POOL_SIZE = 10;
    private static final int MAX_POOL_SIZE = 20;
    
    private static BlockingQueue<Connection> pool = new ArrayBlockingQueue<>(MAX_POOL_SIZE);

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            for (int i = 0; i < INITIAL_POOL_SIZE; i++) {
                pool.offer(createNewConnection());
            }
        } catch (Exception e) {
            System.err.println("Failed to initialize connection pool: " + e.getMessage());
        }
    }

    private static Connection createNewConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static Connection getConnection() throws SQLException {
        Connection conn = null;
        try {
            // Try to get an existing connection from the pool
            conn = pool.poll(100, TimeUnit.MILLISECONDS);
            
            // If pool is empty, create a new one if we haven't exceeded MAX somehow, 
            // but since ArrayBlockingQueue bounds it, we just create a temporary one.
            if (conn == null || conn.isClosed()) {
                conn = createNewConnection();
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new SQLException("Interrupted while waiting for a database connection", e);
        }
        
        final Connection finalConn = conn;
        // Wrap the connection using a dynamic proxy to return it to the pool on close()
        return (Connection) java.lang.reflect.Proxy.newProxyInstance(
            Connection.class.getClassLoader(),
            new Class<?>[]{Connection.class},
            (proxy, method, args) -> {
                if ("close".equals(method.getName())) {
                    releaseConnection(finalConn);
                    return null;
                }
                try {
                    return method.invoke(finalConn, args);
                } catch (java.lang.reflect.InvocationTargetException e) {
                    throw e.getCause();
                }
            }
        );
    }
    
    static void releaseConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    // Try to return to pool; if full, just close it.
                    if (!pool.offer(conn)) {
                        conn.close();
                    }
                }
            } catch (SQLException e) {
                // Ignore close errors
            }
        }
    }
}
