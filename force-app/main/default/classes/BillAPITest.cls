@isTest
public with sharing class BillAPITest {
  @isTest
  static void testBillAPICallout() {
    List<Account> accListtoInsert = new List<Account>();
    for (Integer i = 1; i <= 3; i++) {
      Account newAcc = new Account(Name = 'Account ' + i, Active__c = 'Yes');
      accListtoInsert.add(newAcc);
    }
    Database.insert(accListtoInsert, false);

    Test.startTest();
    //Set mock callout class
    Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());
    HttpResponse response = BillAPI.getBills();
    Test.stopTest();

    // Verify that the response received contains fake values
    String contentType = response.getHeader('Content-Type');
    Assert.isTrue(contentType == 'application/json');
    String actualValue = response.getBody();
    System.debug(response.getBody());
    String expectedValue =
      '[' +
      '{' +
      '"billId": "64fe8c72be1ae0125246d285",' +
      '"accountName": "Account 1",' +
      '"balance": "$336.08"' +
      '},' +
      '{' +
      '"billId": "64fe8c72703103b206105ebf",' +
      '"accountName": "Account 2",' +
      '"balance": "$151.97"' +
      '},' +
      '{' +
      '"billId": "64fe8c722fbe9ae981e5e418",' +
      '"accountName": "Account 3",' +
      '"balance": "$269.72"' +
      '}' +
      ']';
    Assert.areEqual(
      expectedValue,
      actualValue,
      'MockBillDetailResponse did not work'
    );
    Assert.areEqual(200, response.getStatusCode());
  }
}
