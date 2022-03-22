trigger CaseBeforeTrigger on Case (before update, before insert) {

    CaseBeforeTriggerHandler handler = new CaseBeforeTriggerHandler();

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate){
            handler.OnBeforeUpdate(Trigger.new);
        }
    }
}