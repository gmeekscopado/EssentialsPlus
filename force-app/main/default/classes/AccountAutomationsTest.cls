@IsTest
public class AccountAutomationsTest {
    
    @IsTest
    static void testSetDefaultDescription() {
        // Test when description is blank
        Account acc1 = new Account(Name = 'Test Account 1');
        acc1 = AccountAutomations.setDefaultDescription(acc1);
        System.assertEquals('Default description', acc1.Description, 'Description should be set to default when blank');
        
        // Test when description is not blank
        Account acc2 = new Account(Name = 'Test Account 2', Description = 'Existing Description');
        acc2 = AccountAutomations.setDefaultDescription(acc2);
        System.assertEquals('Existing Description', acc2.Description, 'Existing description should not be changed');
    }
    
    @IsTest
    static void testSetDefaultBillingAddress() {
        // Test when billing address is blank
        Account acc1 = new Account(Name = 'Test Account 1');
        acc1 = AccountAutomations.setDefaultBillingAddress(acc1);
        System.assertEquals('Basauri, 6', acc1.BillingStreet, 'Billing Street should be set to default when blank');
        System.assertEquals('Madrid', acc1.BillingState, 'Billing State should be set to default when blank');
        System.assertEquals('28023', acc1.BillingPostalCode, 'Billing Postal Code should be set to default when blank');
        
        // Test when billing address is not blank
        Account acc2 = new Account(Name = 'Test Account 2', BillingStreet = 'Existing Street');
        acc2 = AccountAutomations.setDefaultBillingAddress(acc2);
        System.assertEquals('Existing Street', acc2.BillingStreet, 'Existing Billing Street should not be changed');
    }
    
    @IsTest
    static void testSetDefaultShippingAddress() {
        // Test when shipping address is blank
        Account acc1 = new Account(Name = 'Test Account 1');
        acc1 = AccountAutomations.setDefaultShippingAddress(acc1);
        System.assertEquals('Basauri, 6', acc1.ShippingStreet, 'Shipping Street should be set to default when blank');
        System.assertEquals('Madrid', acc1.ShippingState, 'Shipping State should be set to default when blank');
        System.assertEquals('28023', acc1.ShippingPostalCode, 'Shipping Postal Code should be set to default when blank');
        
        // Test when shipping address is not blank
        Account acc2 = new Account(Name = 'Test Account 2', ShippingStreet = 'Existing Street');
        acc2 = AccountAutomations.setDefaultShippingAddress(acc2);
        System.assertEquals('Existing Street', acc2.ShippingStreet, 'Existing Shipping Street should not be changed');
    }
    
    @IsTest
    static void testSetDefaultPhone() {
        // Test when phone is blank
        Account acc1 = new Account(Name = 'Test Account 1');
        acc1 = AccountAutomations.setDefaultPhone(acc1);
        System.assertEquals('688456789', acc1.Phone, 'Phone should be set to default when blank');
        
        // Test when phone is not blank
        Account acc2 = new Account(Name = 'Test Account 2', Phone = '123456789');
        acc2 = AccountAutomations.setDefaultPhone(acc2);
        System.assertEquals('123456789', acc2.Phone, 'Existing phone should not be changed');
    }
    
    @IsTest
    static void testSetDefaultURL() {
        // Test when website is blank
        Account acc1 = new Account(Name = 'Test Account 1');
        acc1 = AccountAutomations.setDefaultURL(acc1);
        System.assertEquals('https://www.copa.do', acc1.Website, 'Website should be set to default when blank');
        
        // Test when website is not blank
        Account acc2 = new Account(Name = 'Test Account 2', Website = 'https://www.example.com');
        acc2 = AccountAutomations.setDefaultURL(acc2);
        System.assertEquals('https://www.example.com', acc2.Website, 'Existing website should not be changed');
    }
}