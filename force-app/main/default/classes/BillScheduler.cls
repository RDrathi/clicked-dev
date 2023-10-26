public with sharing class BillScheduler implements System.Schedulable {
  public void execute(SchedulableContext ctx) {
    String query = 'SELECT Id, Bill_By_Email__c FROM Account WHERE Account.Active__c = \'Yes\' AND Bill_By_Email != null';
    BillBatch bb = new BillBatch(query);
    Id batchId = Database.executeBatch(bb);
  }
}
