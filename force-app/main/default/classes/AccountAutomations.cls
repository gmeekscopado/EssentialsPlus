public class AccountAutomations {
    public static Account setDefaultDescription(Account a) {
        if (String.isBlank(a.Description)) {
            a.Description = 'Default description';
        }
        return a;
    }
    
    public static Account setDefaultBillingAddress(Account a) {
        if (String.isBlank(a.BillingStreet)) {
            a.BillingStreet = 'Basauri, 6';
            a.BillingState = 'Madrid';
            a.BillingPostalCode = '28023';
        }
        return a;
    }
    
    public static Account setDefaultShippingAddress(Account a) {
        if (String.isBlank(a.ShippingStreet)) {
            a.ShippingStreet = 'Basauri, 6';
            a.ShippingState = 'Madrid';
            a.ShippingPostalCode = '28023';
        }
        return a;
    }
    
    public static Account setDefaultPhone(Account a) {
        if (String.isBlank(a.Phone)) {
            a.Phone = '688456789';
        }
        return a;
    }
    
    public static Account setDefaultURL(Account a) {
        if (String.isBlank(a.Website)) {
            a.Website = 'https://www.copa.do';
        }
        return a;
    }
}