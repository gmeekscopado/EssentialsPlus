/**
 * @description HTTP Mock for testing Bill.com vendor integration
 * @author Copado Demo
 * @date 2025-12-05
 */
@isTest
public class BillComVendorHttpMock implements HttpCalloutMock {
    
    private Integer statusCode;
    private String status;
    private String body;
    
    /**
     * @description Constructor with custom response parameters
     */
    public BillComVendorHttpMock(Integer statusCode, String status, String body) {
        this.statusCode = statusCode;
        this.status = status;
        this.body = body;
    }
    
    /**
     * @description Default constructor for success response
     */
    public BillComVendorHttpMock() {
        this(200, 'OK', '{"success": true, "vendorId": "VENDOR123"}');
    }
    
    /**
     * @description Responds to HTTP callout with configured response
     */
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.statusCode);
        res.setStatus(this.status);
        res.setBody(this.body);
        return res;
    }
}