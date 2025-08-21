@isTest
public class AccountUtilityTest {
    
    @testSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>();
        
        // Very high revenue account
        testAccounts.add(new Account(
            Name = 'Enterprise Corp',
            AnnualRevenue = 2500000,
            Type = 'Other',
            Industry = 'Technology'
        ));
        
        // High revenue account
        testAccounts.add(new Account(
            Name = 'High Revenue Corp',
            AnnualRevenue = 1500000,
            Type = 'Other',
            Industry = 'Manufacturing'
        ));
        
        // Medium revenue account
        testAccounts.add(new Account(
            Name = 'Medium Business',
            AnnualRevenue = 750000,
            Type = 'Other',
            Industry = 'Healthcare'
        ));
        
        // Low revenue account
        testAccounts.add(new Account(
            Name = 'Small Business Inc',
            AnnualRevenue = 50000,
            Type = 'Other',
            Industry = 'Retail'
        ));
        
        // Account with null revenue
        testAccounts.add(new Account(
            Name = 'Unknown Revenue Co',
            Type = 'Other',
            Industry = 'Consulting'
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
        
        // Verify very high revenue account
        Account veryHighRevAccount = [SELECT Type FROM Account WHERE Name = 'Enterprise Corp'];
        System.assertEquals('Customer - Channel', veryHighRevAccount.Type, 'Very high revenue account should be Customer - Channel');
        
        // Verify high revenue account
        Account highRevAccount = [SELECT Type FROM Account WHERE Name = 'High Revenue Corp'];
        System.assertEquals('Customer - Direct', highRevAccount.Type, 'High revenue account should be Customer - Direct');
        
        // Verify medium revenue account
        Account mediumRevAccount = [SELECT Type FROM Account WHERE Name = 'Medium Business'];
        System.assertEquals('Customer - Direct', mediumRevAccount.Type, 'Medium revenue account should be Customer - Direct');
        
        // Verify low revenue account
        Account lowRevAccount = [SELECT Type FROM Account WHERE Name = 'Small Business Inc'];
        System.assertEquals('Other', lowRevAccount.Type, 'Low revenue account should be Other');
        
        // Verify null revenue account
        Account nullRevAccount = [SELECT Type FROM Account WHERE Name = 'Unknown Revenue Co'];
        System.assertEquals('Other', nullRevAccount.Type, 'Null revenue account should be Other');
    }
    
    @isTest
    static void testGetHighValueAccounts() {
        Test.startTest();
        List<Account> highValueAccounts = AccountUtility.getHighValueAccounts();
        Test.stopTest();
        
        System.assertEquals(2, highValueAccounts.size(), 'Should return 2 high value accounts');
        
        // Verify ordering (ASC by Name)
        System.assertEquals('Enterprise Corp', highValueAccounts[0].Name, 'First account should be alphabetically first');
        System.assertEquals('High Revenue Corp', highValueAccounts[1].Name, 'Second account should be alphabetically second');
        
        // Verify Industry field is included and has values
        System.assertEquals('Technology', highValueAccounts[0].Industry, 'First account should have Technology industry');
        System.assertEquals('Manufacturing', highValueAccounts[1].Industry, 'Second account should have Manufacturing industry');
    }
    
    @isTest
    static void testCountAccountsByType() {
        // Update accounts to have specific types and revenue
        List<Account> accounts = [SELECT Id, AnnualRevenue FROM Account WHERE AnnualRevenue != null LIMIT 2];
        for (Account acc : accounts) {
            acc.Type = 'Customer - Direct';
            if (acc.AnnualRevenue == null) {
                acc.AnnualRevenue = 100000;
            }
        }
        update accounts;
        
        Test.startTest();
        Integer count = AccountUtility.countAccountsByType('Customer - Direct');
        Integer zeroCount = AccountUtility.countAccountsByType('Nonexistent Type');
        Integer nullCount = AccountUtility.countAccountsByType(null);
        Integer blankCount = AccountUtility.countAccountsByType('');
        Test.stopTest();
        
        System.assertEquals(2, count, 'Should count 2 Customer - Direct accounts with revenue > 0');
        System.assertEquals(0, zeroCount, 'Should return 0 for nonexistent type');
        System.assertEquals(0, nullCount, 'Should return 0 for null input');
        System.assertEquals(0, blankCount, 'Should return 0 for blank input');
    }
    
    @isTest
    static void testSetAccountRating() {
        List<Account> accounts = [SELECT Id, Name, AnnualRevenue, Rating FROM Account];
        
        Test.startTest();
        AccountUtility.setAccountRating(accounts);
        Test.stopTest();
        
        update accounts;
        
        // Verify high revenue accounts get Hot rating
        Account highRevAccount = [SELECT Rating FROM Account WHERE Name = 'Enterprise Corp'];
        System.assertEquals('Hot', highRevAccount.Rating, 'High revenue account should have Hot rating');
        
        // Verify lower revenue accounts get Warm rating
        Account lowRevAccount = [SELECT Rating FROM Account WHERE Name = 'Small Business Inc'];
        System.assertEquals('Warm', lowRevAccount.Rating, 'Low revenue account should have Warm rating');
        
        // Verify null revenue accounts get Warm rating
        Account nullRevAccount = [SELECT Rating FROM Account WHERE Name = 'Unknown Revenue Co'];
        System.assertEquals('Warm', nullRevAccount.Rating, 'Null revenue account should have Warm rating');
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
    
    @isTest
    static void testSetAccountRatingEmptyList() {
        List<Account> emptyList = new List<Account>();
        
        Test.startTest();
        AccountUtility.setAccountRating(emptyList);
        Test.stopTest();
        
        // No exception should be thrown
        System.assertEquals(0, emptyList.size(), 'Empty list should remain empty');
    }
}