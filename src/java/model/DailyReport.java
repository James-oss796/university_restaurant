// Member E (Reports & Admin Dashboard) should implement this file

package model;

public class DailyReport {
    private int reportId;
    private String reportDate;
    private int totalOrders;
    private double totalRevenue;
    private double cashPayments;
    private double mobileMoneyPayments;
    private int breakfastOrders;
    private int lunchOrders;
    private int dinnerOrders;
    private int avgWaitTime;

    // Getters and Setters
    public int getReportId() { return reportId; }
    public void setReportId(int reportId) { this.reportId = reportId; }

    public String getReportDate() { return reportDate; }
    public void setReportDate(String reportDate) { this.reportDate = reportDate; }

    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }

    public double getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }

    public double getCashPayments() { return cashPayments; }
    public void setCashPayments(double cashPayments) { this.cashPayments = cashPayments; }

    public double getMobileMoneyPayments() { return mobileMoneyPayments; }
    public void setMobileMoneyPayments(double mobileMoneyPayments) { this.mobileMoneyPayments = mobileMoneyPayments; }

    public int getBreakfastOrders() { return breakfastOrders; }
    public void setBreakfastOrders(int breakfastOrders) { this.breakfastOrders = breakfastOrders; }

    public int getLunchOrders() { return lunchOrders; }
    public void setLunchOrders(int lunchOrders) { this.lunchOrders = lunchOrders; }

    public int getDinnerOrders() { return dinnerOrders; }
    public void setDinnerOrders(int dinnerOrders) { this.dinnerOrders = dinnerOrders; }

    public int getAvgWaitTime() { return avgWaitTime; }
    public void setAvgWaitTime(int avgWaitTime) { this.avgWaitTime = avgWaitTime; }
}
