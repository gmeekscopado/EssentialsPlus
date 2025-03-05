/**
 * @description Test class for ContactUtility
 * @author TestAgent
 * @date 2025-02-25
 */
@isTest
private class ContactUtilityTest {
    
    private static User standardUser;
    
    /**
     * @description Test setup method to create test user
     */
    @TestSetup
    static void setupTestData() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        standardUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@copado.com',
            Username = 'testuser' + DateTime.now().getTime() + '@copado.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardUserProfile.Id
        );
        insert standardUser;
    }
    
    /**
     * @description Test data setup method
     * @return List<Contact> List of test contacts
     */
    private static List<Contact> createTestContacts() {
        List<Contact> testContacts = new List<Contact>{
            new Contact(
                FirstName = 'Test1',
                LastName = 'Contact1',
                Email = 'test1@example.com'
            ),
            new Contact(
                FirstName = 'Test2',
                LastName = 'Contact2',
                Email = 'test2@copado.com'
            ),
            new Contact(
                FirstName = 'Test3',
                LastName = 'Contact3',
                Email = null
            ),
            new Contact(
                FirstName = 'Test4',
                LastName = 'Contact4',
                Email = 'invalidEmail'
            )
        };
        return testContacts;
    }
    
    /**
     * @description Tests updating email domains for contacts with valid emails
     */
    @isTest
    static void testUpdateEmailDomainsValid() {
        // Arrange
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        List<Contact> testContacts = createTestContacts();
        
        // Act
        Test.startTest();
        System.runAs(testUser) {
            List<Contact> updatedContacts = ContactUtility.updateEmailDomains(testContacts);
            
            // Assert
            System.assertEquals(2, updatedContacts.size(), 
                'Should return 2 contacts with valid email domains');
            System.assertEquals('example.com', updatedContacts[0].Email_Domain__c, 
                'First contact should have example.com domain');
            System.assertEquals('copado.com', updatedContacts[1].Email_Domain__c, 
                'Second contact should have copado.com domain');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests handling of null and invalid email addresses
     */
    @isTest
    static void testUpdateEmailDomainsInvalid() {
        // Arrange
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName = 'Test', LastName = 'Null', Email = null),
            new Contact(FirstName = 'Test', LastName = 'Invalid', Email = 'invalidEmail')
        };
        
        // Act
        Test.startTest();
        System.runAs(testUser) {
            List<Contact> updatedContacts = ContactUtility.updateEmailDomains(testContacts);
            
            // Assert
            System.assertEquals(0, updatedContacts.size(), 
                'Should return 0 contacts for invalid/null emails');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests with empty contact list
     */
    @isTest
    static void testUpdateEmailDomainsEmptyList() {
        // Arrange
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        List<Contact> testContacts = new List<Contact>();
        
        // Act
        Test.startTest();
        System.runAs(testUser) {
            List<Contact> updatedContacts = ContactUtility.updateEmailDomains(testContacts);
            
            // Assert
            System.assertEquals(0, updatedContacts.size(), 
                'Should return empty list for empty input');
        }
        Test.stopTest();
    }
}