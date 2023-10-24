public with sharing class BillControllerExt {
  private final Bill__c billRec;
  public List<Bill__c> billList { get; set; }

  public BillControllerExt(ApexPages.StandardController controller) {
    this.billRec = (Bill__c) controller.getRecord();
    Id accId = billRec.Account__c;
    billList = [
      SELECT Bill_Number__c, Balance__c, Bill_Id__c
      FROM Bill__c
      WHERE Account__c = :accId
    ];
  }
}
