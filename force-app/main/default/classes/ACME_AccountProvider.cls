/**
 * @description Provider class for Account data access operations
 * @author ACME Corporation
 * @date 2024
 */
public with sharing class ACME_AccountProvider {
    
    /**
     * @description Finds or creates account for lead conversion
     * @param leadData Lead information for account creation
     * @return Account ID
     */
    public static Id findOrCreateAccount(Lead leadData) {
        try {
            // Try to find existing account - WITH CRUD/FLS CHECK
            List<Account> existingAccounts = [
                SELECT Id, Name, Website
                FROM Account 
                WHERE Name = :leadData.Company 
                LIMIT 1
            ];
            
            // Strip inaccessible fields based on user permissions
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.READABLE,
                existingAccounts
            );
            
            List<Account> accessibleAccounts = securityDecision.getRecords();
            
            if (!accessibleAccounts.isEmpty()) {
                return accessibleAccounts[0].Id;
            }
            
            // Create new account if not found - WITH CRUD/FLS CHECK
            Account newAccount = new Account(
                Name = leadData.Company,
                Website = leadData.Website,
                Phone = leadData.Phone,
                Industry = leadData.Industry,
                AnnualRevenue = leadData.AnnualRevenue,
                NumberOfEmployees = leadData.NumberOfEmployees,
                OwnerId = leadData.OwnerId
            );
            
            // Check if user has create permission
            if (!Schema.sObjectType.Account.isCreateable()) {
                throw new AcmeDataException('Insufficient permissions to create Account');
            }
            
            // Strip inaccessible fields before insert
            SObjectAccessDecision createDecision = Security.stripInaccessible(
                AccessType.CREATABLE,
                new List<Account>{ newAccount }
            );
            
            insert createDecision.getRecords();
            return createDecision.getRecords()[0].Id;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error finding/creating account: ' + e.getMessage());
            throw new AcmeDataException('Failed to find or create account: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets high-value accounts for reporting
     * @return List of high-value accounts
     */
    public static List<Account> getHighValueAccounts() {
        try {
            // Query with CRUD/FLS check
            List<Account> accounts = [
                SELECT Id, Name, AnnualRevenue, Industry, Owner.Name, Owner.Email
                FROM Account 
                WHERE AnnualRevenue > 1000000
                ORDER BY AnnualRevenue DESC
                LIMIT 50
            ];
            
            // Strip inaccessible fields
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.READABLE,
                accounts
            );
            
            return securityDecision.getRecords();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving high-value accounts: ' + e.getMessage());
            throw new AcmeDataException('Failed to retrieve accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Custom exception for data access errors
     */
    public class AcmeDataException extends Exception {}
}