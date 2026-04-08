package model;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Payment model class.
 *
 * Database table: payments
 * Columns: payment_id, order_id, cashier_id, amount, payment_method,
 *          transaction_reference, payment_date, payment_time
 *
 * payment_method is constrained to ENUM('cash', 'mobile_money') in MySQL.
 * transaction_reference is required for mobile_money, optional for cash.
 */
public class Payment {

    // ---------------------------------------------------------------
    // Constants for payment method values (mirrors DB ENUM)
    // ---------------------------------------------------------------
    public static final String METHOD_CASH         = "cash";
    public static final String METHOD_MOBILE_MONEY = "mobile_money";

    // ---------------------------------------------------------------
    // Fields
    // ---------------------------------------------------------------
    private int    paymentId;
    private int    orderId;
    private int    cashierId;
    private double amount;
    private String paymentMethod;          // "cash" | "mobile_money"
    private String transactionReference;   // M-Pesa ref or empty for cash
    private String paymentDate;            // Stored as String (yyyy-MM-dd)
    private String paymentTime;            // Stored as String (HH:mm:ss)

    // Optional: cashier name joined from users table (not a DB column)
    private String cashierName;

    // ---------------------------------------------------------------
    // Constructors
    // ---------------------------------------------------------------

    /** Default no-arg constructor (required by DAO layer). */
    public Payment() {}

    /**
     * Convenience constructor for creating a payment before persisting.
     * paymentId, paymentDate, paymentTime are set by the DB / DAO.
     */
    public Payment(int orderId, int cashierId, double amount,
                   String paymentMethod, String transactionReference) {
        this.orderId              = orderId;
        this.cashierId            = cashierId;
        this.amount               = amount;
        this.paymentMethod        = paymentMethod;
        this.transactionReference = transactionReference;
    }

    // ---------------------------------------------------------------
    // Business helpers
    // ---------------------------------------------------------------

    /**
     * Returns true if this payment is a mobile money transaction.
     * Useful in JSP to conditionally display the reference field.
     */
    public boolean isMobileMoney() {
        return METHOD_MOBILE_MONEY.equals(paymentMethod);
    }

    /**
     * Returns the amount rounded to 2 decimal places as a double.
     * Prevents floating-point display issues in JSP.
     */
    public double getAmountRounded() {
        return BigDecimal.valueOf(amount)
                         .setScale(2, RoundingMode.HALF_UP)
                         .doubleValue();
    }

    /**
     * Returns a human-readable label for the payment method.
     * e.g. "cash" → "Cash", "mobile_money" → "Mobile Money"
     */
    public String getPaymentMethodLabel() {
        if (METHOD_CASH.equals(paymentMethod))         return "Cash";
        if (METHOD_MOBILE_MONEY.equals(paymentMethod)) return "Mobile Money";
        return paymentMethod;
    }

    // ---------------------------------------------------------------
    // Getters & Setters
    // ---------------------------------------------------------------

    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getCashierId() { return cashierId; }
    public void setCashierId(int cashierId) { this.cashierId = cashierId; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getTransactionReference() { return transactionReference; }
    public void setTransactionReference(String transactionReference) {
        this.transactionReference = transactionReference;
    }

    public String getPaymentDate() { return paymentDate; }
    public void setPaymentDate(String paymentDate) { this.paymentDate = paymentDate; }

    public String getPaymentTime() { return paymentTime; }
    public void setPaymentTime(String paymentTime) { this.paymentTime = paymentTime; }

    public String getCashierName() { return cashierName; }
    public void setCashierName(String cashierName) { this.cashierName = cashierName; }

    @Override
    public String toString() {
        return "Payment{paymentId=" + paymentId
             + ", orderId=" + orderId
             + ", cashierId=" + cashierId
             + ", amount=" + amount
             + ", method=" + paymentMethod
             + ", ref=" + transactionReference + "}";
    }
}
