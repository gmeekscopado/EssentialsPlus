public class AccountUtility {
    
    public static void updateAccountType(List<Account> accounts) {
        for (Account acc : accounts) {
            // Different logic - conflicting implementation
            if (acc.AnnualRevenue != null && acc.AnnualRevenue > 2000000) {
                acc.Type = 'Customer - Channel';
            } else if (acc.AnnualRevenue != null && acc.AnnualRevenue > 500000) {
                acc.Type = 'Customer - Direct';
            } else {
                acc.Type = 'Other';
            }
        }
    }
    
    public static List<Account> getHighValueAccounts() {
        // Different threshold - conflicting implementation
        return [SELECT Id, Name, AnnualRevenue, Type, Industry 
                FROM Account 
                WHERE AnnualRevenue > 1000000 
                ORDER BY Name ASC];
    }
    
    public static Integer countAccountsByType(String accountType) {
        if (String.isBlank(accountType)) {
            return 0;
        }
        
        // Added additional filtering - conflicting implementation
        return [SELECT COUNT() FROM Account 
                WHERE Type = :accountType AND AnnualRevenue > 0];
    }
    
    // New method in conflicting version
    public static void setAccountRating(List<Account> accounts) {
        for (Account acc : accounts) {
            if (acc.AnnualRevenue != null && acc.AnnualRevenue > 1000000) {
                acc.Rating = 'Hot';
            } else {
                acc.Rating = 'Warm';
            }
        }
    }
}