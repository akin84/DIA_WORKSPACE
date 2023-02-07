/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 02-06-2023
 * @last modified by  : Ferdi AKIN
 **/
trigger Task on Task(after insert, after update, after delete) {
  if (Trigger.isInsert) {
    OpenTasksCountTriggerHandler.handlerAfterInsert(Trigger.new);
  }
  if (Trigger.isUpdate) {
    OpenTasksCountTriggerHandler.handlerAfterUpdate(
      Trigger.oldMap,
      Trigger.new
    );
  }
  if (Trigger.isDelete) {
    OpenTasksCountTriggerHandler.handlerAfterDelete(Trigger.old);
  }
}
