/**
 * @description       :
 * @author            : Ferdi AKIN
 * @group             :
 * @last modified on  : 02-13-2023
 * @last modified by  : Ferdi AKIN
 **/
public with sharing class OpenTasksOnAccountQueue implements System.Queueable {
  List<Account> rltdAccounts = new List<Account>();

  public OpenTasksOnAccountQueue(List<Account> lstAcc) {
    if (lstAcc != null)
      rltdAccounts = lstAcc;
  }

  public void execute(QueueableContext context) {
    List<Account> updatedAccounts = new List<Account>();

    for (Account acc : rltdAccounts) {
      Integer openEmailTask = 0;
      Integer openCallTask = 0;
      Integer openMeetingTask = 0;
      Integer openOtherTask = 0;
      for (Task tsk : acc.Tasks) {
        if (tsk.Status != 'Completed') {
          if (tsk.Type == 'Email') {
            openEmailTask++;
          } else if (tsk.Type == 'Call') {
            openCallTask++;
          } else if (tsk.Type == 'Meeting') {
            openMeetingTask++;
          } else {
            openOtherTask++;
          }
        }
        acc.Open_Tasks_Email__c = openEmailTask;
        acc.Open_Tasks_Call__c = openCallTask;
        acc.Open_Tasks_Meeting__c = openMeetingTask;
        acc.Open_Tasks_Other__c = openOtherTask;
      }
      updatedAccounts.add(acc);
    }
    update updatedAccounts;
  }
}
