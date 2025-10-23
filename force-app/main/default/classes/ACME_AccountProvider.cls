/**
 * @description Provider class for Account-related operations with CRUD validation
 * @author ACME Development Team
 * @date 2024
 */
public with sharing class ACME_AccountProvider {
    
    /**
     * @description Retrieves all accounts from the database with CRUD validation
     * @return List<Account> List of all accounts the user has access to
     * @throws AuraHandledException when user lacks read access to Account object
     */
    public static List<Account> getAllAccounts() {
        try {
            // CRUD validation before SOQL operation
            if (!Schema.sObjectType.Account.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to read Account records');
            }
            
            return [SELECT Id, Name, Type, Industry, Phone, Website 
                   FROM Account 
                   ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves accounts by their IDs with CRUD validation
     * @param accountIds Set of Account IDs to retrieve
     * @return List<Account> List of accounts matching the provided IDs
     * @throws AuraHandledException when user lacks read access or invalid parameters
     */
    public static List<Account> getAccountsByIds(Set<Id> accountIds) {
        try {
            if (accountIds == null || accountIds.isEmpty()) {
                throw new AuraHandledException('Account IDs cannot be null or empty');
            }
            
            // CRUD validation before SOQL operation
            if (!Schema.sObjectType.Account.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to read Account records');
            }
            
            return [SELECT Id, Name, Type, Industry, Phone, Website, BillingAddress
                   FROM Account 
                   WHERE Id IN :accountIds
                   ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts by IDs: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates new account records with CRUD validation
     * @param accounts List of Account records to create
     * @return List<Account> List of created accounts with IDs
     * @throws AuraHandledException when user lacks create access or DML fails
     */
    public static List<Account> createAccounts(List<Account> accounts) {
        try {
            if (accounts == null || accounts.isEmpty()) {
                throw new AuraHandledException('Accounts list cannot be null or empty');
            }
            
            // CRUD validation before DML operation
            if (!Schema.sObjectType.Account.isCreateable()) {
                throw new AuraHandledException('Insufficient permissions to create Account records');
            }
            
            insert accounts;
            return accounts;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating accounts: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error creating accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates existing account records with CRUD validation
     * @param accounts List of Account records to update
     * @return List<Account> List of updated accounts
     * @throws AuraHandledException when user lacks update access or DML fails
     */
    public static List<Account> updateAccounts(List<Account> accounts) {
        try {
            if (accounts == null || accounts.isEmpty()) {
                throw new AuraHandledException('Accounts list cannot be null or empty');
            }
            
            // CRUD validation before DML operation
            if (!Schema.sObjectType.Account.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update Account records');
            }
            
            update accounts;
            return accounts;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating accounts: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error updating accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Deletes account records with CRUD validation
     * @param accountIds Set of Account IDs to delete
     * @throws AuraHandledException when user lacks delete access or DML fails
     */
    public static void deleteAccounts(Set<Id> accountIds) {
        try {
            if (accountIds == null || accountIds.isEmpty()) {
                throw new AuraHandledException('Account IDs cannot be null or empty');
            }
            
            // CRUD validation before DML operation
            if (!Schema.sObjectType.Account.isDeletable()) {
                throw new AuraHandledException('Insufficient permissions to delete Account records');
            }
            
            List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Id IN :accountIds];
            delete accountsToDelete;
        } catch (DmlException e) {
            throw new AuraHandledException('Error deleting accounts: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error deleting accounts: ' + e.getMessage());
        }
    }
}
