/**
 * @description Utility class for creating test data
 */
public class TestDataFactory {
    /**
     * @description Creates a test user with the specified profile
     * @param profileName The name of the profile to assign
     * @return User The created test user
     */
    public static User createTestUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        
        User u = new User(Alias = 'standt', 
                         Email='standarduser@testorg.com',
                         EmailEncodingKey='UTF-8', 
                         LastName='Testing', 
                         LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US', 
                         ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName=uniqueUserName);
        insert u;
        return u;
    }
}