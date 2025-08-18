@isTest
public class AccountUtilityTest {
    
    @testSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>();
        
        // High revenue account
        testAccounts.add(new Account(
            Name = 'High Revenue Corp',
            AnnualRevenue = 1500000,
            Type = 'Other'
        ));
        
        // Low revenue account
        testAccounts.add(new Account(
            Name = 'Small Business Inc',
            AnnualRevenue = 50000,
            Type = 'Other'
        ));
        
        // Medium revenue account
        testAccounts.add(new Account(
            Name = 'Medium Enterprise',
            AnnualRevenue = 750000,
            Type = 'Other'
        ));
        
        // Account with null revenue
        testAccounts.add(new Account(
            Name = 'Unknown Revenue Co',
            Type = 'Other'
        ));
        
        insert testAccounts;
    }
    
    @isTest
    static void testUpdateAccountType() {
        List<Account> accounts = [SELECT Id, Name, AnnualRevenue, Type FROM Account];
        
        Test.startTest();
        AccountUtility.updateAccountType(accounts);
        Test.stopTest();
        
        update accounts;
        
        // Verify high revenue account
        Account highRevAccount = [SELECT Type FROM Account WHERE Name = 'High Revenue Corp'];
        System.assertEquals('Customer - Direct', highRevAccount.Type, 'High revenue account should be Customer - Direct');
        
        // Verify low revenue account
        Account lowRevAccount = [SELECT Type FROM Account WHERE Name = 'Small Business Inc'];
        System.assertEquals('Prospect', lowRevAccount.Type, 'Low revenue account should be Prospect');
        
        // Verify null revenue account
        Account nullRevAccount = [SELECT Type FROM Account WHERE Name = 'Unknown Revenue Co'];
        System.assertEquals('Prospect', nullRevAccount.Type, 'Null revenue account should be Prospect');
    }
    
    @isTest
    static void testGetHighValueAccounts() {
        Test.startTest();
        List<Account> highValueAccounts = AccountUtility.getHighValueAccounts();
        Test.stopTest();
        
        System.assertEquals(2, highValueAccounts.size(), 'Should return 2 high value accounts');
        
        // Verify ordering (DESC by AnnualRevenue)
        System.assertEquals('High Revenue Corp', highValueAccounts[0].Name, 'First account should be highest revenue');
        System.assertEquals('Medium Enterprise', highValueAccounts[1].Name, 'Second account should be medium revenue');
    }
    
    @isTest
    static void testCountAccountsByType() {
        // Update accounts to have specific types
        List<Account> accounts = [SELECT Id FROM Account LIMIT 2];
        for (Account acc : accounts) {
            acc.Type = 'Customer - Direct';
        }
        update accounts;
        
        Test.startTest();
        Integer count = AccountUtility.countAccountsByType('Customer - Direct');
        Integer zeroCount = AccountUtility.countAccountsByType('Nonexistent Type');
        Integer nullCount = AccountUtility.countAccountsByType(null);
        Integer blankCount = AccountUtility.countAccountsByType('');
        Test.stopTest();
        
        System.assertEquals(2, count, 'Should count 2 Customer - Direct accounts');
        System.assertEquals(0, zeroCount, 'Should return 0 for nonexistent type');
        System.assertEquals(0, nullCount, 'Should return 0 for null input');
        System.assertEquals(0, blankCount, 'Should return 0 for blank input');
    }
    
    @isTest
    static void testUpdateAccountTypeEmptyList() {
        List<Account> emptyList = new List<Account>();
        
        Test.startTest();
        AccountUtility.updateAccountType(emptyList);
        Test.stopTest();
        
        // No exception should be thrown
        System.assertEquals(0, emptyList.size(), 'Empty list should remain empty');
    }
}