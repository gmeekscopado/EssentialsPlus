public class AccountUtility {
    
    public static void updateAccountType(List<Account> accounts) {
        for (Account acc : accounts) {
            if (acc.AnnualRevenue != null && acc.AnnualRevenue > 1000000) {
                acc.Type = 'Customer - Direct';
            } else {
                acc.Type = 'Prospect';
            }
        }
    }
    
    public static List<Account> getHighValueAccounts() {
        return [SELECT Id, Name, AnnualRevenue, Type 
                FROM Account 
                WHERE AnnualRevenue > 500000 
                ORDER BY AnnualRevenue DESC];
    }
    
    public static Integer countAccountsByType(String accountType) {
        if (String.isBlank(accountType)) {
            return 0;
        }
        
        return [SELECT COUNT() FROM Account WHERE Type = :accountType];
    }
}