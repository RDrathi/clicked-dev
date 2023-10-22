/**
 * @author - Rathindra Dakua
 * @description - Mock class that will make fire when external callouts are made in a test context
 */
@isTest
public with sharing class YourHttpCalloutMockImpl implements HttpCalloutMock {
  /**
   * @description - Creates a mock response for a callout in a test context
   * @param req An HTTPRequest called from the code
   * @return HTTPResponse A response that mocks what would be actually returned from an external system
   */
  public HttpResponse respond(HttpRequest req) {
    System.debug('Mock class has fired');
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setStatusCode(200);
    response.setBody(MockBillDetailResponse.billAPIResponse);
    return response;
  }
}
