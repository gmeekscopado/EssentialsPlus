/**
 * @description Provider class for Account data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_AccountProvider {
    
    /**
     * @description Finds or creates account for lead conversion
     * @param companyName Company name from lead
     * @param leadData Lead information for account creation
     * @return Account ID
     */
    public static Id findOrCreateAccount(String companyName, Lead leadData) {
        try {
            // First, try to find existing account
            List<Account> existingAccounts = [
                SELECT Id, Name 
                FROM Account 
                WHERE Name = :companyName 
                LIMIT 1
            ];
            
            if (!existingAccounts.isEmpty()) {
                return existingAccounts[0].Id;
            }
            
            // Create new account if not found
            Account newAccount = new Account(
                Name = companyName,
                Industry = leadData.Industry,
                Phone = leadData.Phone,
                Type = 'Prospect',
                OwnerId = leadData.OwnerId
            );
            
            insert newAccount;
            return newAccount.Id;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error finding/creating account: ' + e.getMessage());
            throw new AcmeDataException('Failed to find or create account: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets high-priority accounts for sales focus
     * @return List of high-priority accounts
     */
    public static List<Account> getHighPriorityAccounts() {
        try {
            return [
                SELECT Id, Name, Industry, AnnualRevenue, Type,
                       Owner.Name, Owner.Email
                FROM Account 
                WHERE Type IN ('Customer - Direct', 'Customer - Channel')
                AND AnnualRevenue > 1000000
                ORDER BY AnnualRevenue DESC
                LIMIT 25
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving high-priority accounts: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve accounts: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}