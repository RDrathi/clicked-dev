@isTest
public with sharing class BillBatchTest {
  @TestSetup
  static void makeData() {
    List<Account> accList = new List<Account>();
    for (Integer i = 0; i <= 3; i++) {
      Account accRec = new Account(
        Name = 'Account ' + i,
        Active__c = 'Yes',
        Bill_By_Email__c = true,
        Email__c = 'rathindra.cetb@gmail.com'
      );
      accList.add(accRec);
    }
    Database.insert(accList);

    List<Bill__c> bList = new List<Bill__c>();

    for (Integer i = 0; i <= 3; i++) {
      Bill__c billRec = new Bill__c(
        Name = 'Test Bill Name' + i,
        Balance__c = 456.87,
        Account__c = accList[i].Id,
        Bill_Id__c = 'Test Bill Id - ' + i
      );
      bList.add(billRec);
    }
    Database.insert(bList);
  }

  @isTest
  static void testBatch() {
    String query = 'SELECT Id, Bill_By_Email__c FROM Account WHERE Account.Active__c = \'Yes\' AND Bill_By_Email__c != null';
    List<Account> accListTest = [
      SELECT Id, Bill_By_Email__c
      FROM Account
      WHERE Account.Active__c = 'Yes' AND Bill_By_Email__c != NULL
    ];
    Test.startTest();
    BillBatch bb = new BillBatch(query);
    Id batchId = Database.executeBatch(bb);
    Test.stopTest();
    Assert.areEqual(
      4,
      accListTest.size(),
      'Accounts did not get inserted successfully'
    );
  }
}
