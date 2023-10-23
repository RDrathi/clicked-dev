public with sharing class RecTypeController {
  public String recordTypeId { get; set; }
  public String status { get; set; }

  public PageReference testRecordType() {
    Case x = [SELECT id FROM case WITH SECURITY_ENFORCED LIMIT 1];
    recordTypeId = 'RecordType ID for Case is ' + x.recordTypeID;
    return null;
  }

  public PageReference testStatus() {
    Case x = [SELECT id, Status FROM case WITH SECURITY_ENFORCED LIMIT 1];
    this.status = 'Status of this Case is ' + x.Status;
    return null;
  }
}
