/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 02-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
trigger Task on Task(after insert, after update, after delete) {
  if (Trigger.isInsert) {
    countOpenTasks_TriggerHandler.handlerAfterInsert(Trigger.new);
  }
  if (Trigger.isUpdate) {
    countOpenTasks_TriggerHandler.handlerAfterUpdate(Trigger.old, Trigger.new);
  }
  if (Trigger.isDelete) {
    countOpenTasks_TriggerHandler.handlerAfterDelete(Trigger.old);
  }
}
