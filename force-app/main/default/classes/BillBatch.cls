public with sharing class BillBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
  @testVisible
  public List<Id> receivesBillByEmail = new List<Id>();
  public final String query;

  public BillBatch(String query) {
    this.query = query;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    //this is a method that will query for all accounts that are active and have a value
    //for Bill_By_Email__c (Account.Active__c = \'Yes\' AND Bill_By_Email != null)
    //using the Database.getQueryLocator(String) method. Return the result of this method.
    //Hint: be sure to escape the single quotes surrounding \'Yes\' in your dynamic query!
    //query for the following fields:
    //Id, Bill_By_Email__c
    return Database.getQueryLocator(this.query);
  }

  public void execute(Database.BatchableContext bc, List<Account> scope) {
    //this is a method that will process the queried for records by preparing
    //a list of account Ids (this.receivesBillByEmail) to carry over to the finish method.
    //we will do this by iterating over scope and checking whether Bill_By_Email__c == TRUE.
    //This method will also call our BillAPI.getBills() method.
    for (Account accRec : scope) {
      if (accRec.Bill_By_Email__c == true) {
        this.receivesBillByEmail.add(accRec.Id);
      }
    }

    //Test context can not call a webservice method
    if (!Test.isRunningTest()) {
      BillAPI.getBills();
    }
  }

  public void finish(Database.BatchableContext bc) {
    //this is the final method of the class, that will be called after all processing in the
    //start and execute methods is complete. We will use this method to send an email to each
    //customer in the receivesBillByEmail list. First, we must query for the recently created bills for
    //each account with the following nested query:
    //[SELECT Id, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) FROM Account WHERE Id IN :this.receivesBillByEmail]
    List<Account> accwithBills = [
      SELECT Id, Email__c, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC)
      FROM Account
      WHERE Id IN :this.receivesBillByEmail
    ];

    //We will then iterate over the results of this query and associate the Id of the most recent bill (value) with the
    //corresponding Id of the account Id (key) in a Map<Id, Id> that we will call billMap, using the .put(Id, Id)
    //method of the Map class:
    //https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_map.htm

    Map<Id, Id> billMap = new Map<Id, Id>();
    for (Account accRec : accwithBills) {
      Id recentBillId = accRec.Bills__r.get(0).Id;
      billMap.put(accRec.Id, recentBillId);
    }

    //we will also create a Map<Id, String> called emailMap, where we'll hold the Account Id (key) and account email (value).
    Map<Id, String> emailMap = new Map<Id, String>();
    for (Account accRec : accwithBills) {
      emailMap.put(accRec.Id, accRec.Email__c);
    }

    //Next, we are going to prepare to call our BillEmailer.sendEmails(Map<String, Blob> emailsWithBills)
    //method. The String in the map, which we'll call sendMap,will be the Account.Email__c field result, and the Blob
    //will be the PDF attachment we are sending. We will achieve this by iterating over the keyset for
    //billMap, putting the email from the account in the key of the key-value pair, and use the following
    //to generate a PDF for each bill Id in the value of the key-value pair:
    //PageReference pageRef = new PageReference('/apex/BillVFP?id=' + [BILLID]);
    //Blob pdfBlob = pageRef.getContentAsPDF();
    //hint: you'll need to use the .get() method of the Map class a couple of times here.
    Map<String, Blob> sendMap = new Map<String, Blob>();
    for (Id accId : billMap.keySet()) {
      String emailAdd = emailMap.get(accId);
      Id billId = billMap.get(accId);
      PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
      Blob pdfBlob;

      //PageReference.getContentAsPDF() cannot work directly for a test so it is replaced by pdfBlob = blob.valueOf('Unit.Test')
      if (Test.isRunningTest()) {
        pdfBlob = Blob.valueOf('Unit.Test');
      } else {
        pdfBlob = pageRef.getContentAsPDF();
      }
      sendMap.put(emailAdd, pdfBlob);
    }

    //finally, we will call our BillEmailer.sendEmails(sendMap) method. Remember, this method is VOID,
    //so there will be no return value;
    BillEmailer.sendEmails(sendMap);
    for (String emailAddress : sendMap.keySet()) {
      System.debug(emailAddress);
    }
    System.debug('Size of the sendMap is:- ' + sendMap.size());
  }
}
