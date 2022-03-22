public with sharing class CaseBeforeTriggerHandler {

    public CaseBeforeTriggerHandler() {
    }
    
    public void onBeforeInsert(List<Case> casesBeforeInsert) {
        List<Id> accountIds;
        for (Case caseInserted: casesBeforeInsert){
                accountIds.add(caseInserted.AccountId);
            }

        Map<ID, Account> accounts = new Map<ID, Account>([SELECT ID, (select id from contacts) FROM Account where id in :accountIds]);
        for (Case caseInserted : casesBeforeInsert){
            if(caseInserted != null && caseInserted.AccountId != null){
                Account account = accounts.get(caseInserted.AccountId);
                Integer contactsSize = account.Contacts.size();
                caseErrorsHandler(caseInserted,contactsSize);
            }
            else {
                caseInserted.addError('You cannot create a request without attaching an account');
            }
        }
    }


    public static void onBeforeUpdate(List<Case> casesBeforeUpdate) {
        List<Id> accountIds = new List<Id>();
        for (Case caseUpdated : casesBeforeUpdate){
            if(caseUpdated.Status == 'Closed'){
                accountIds.add(caseUpdated.AccountId);
            }
        }
        if (accountIds.size()>0){
            ExternalSystemService.registerAttendees(accountIds);
        }
    }


    public void caseErrorsHandler(Case caseBeforeInsert, Integer contactsSize) {

        if(contactsSize == 0) {

            caseBeforeInsert.addError('You cannot create a request for accounts without contacts');

        } else if(caseBeforeInsert.Origin == 'Web' && contactsSize >= 2) {

            caseBeforeInsert.addError('Web request are only allowed to have one attendee');
        
        } else if(caseBeforeInsert.Origin == 'Phone' && contactsSize >= 4) {

            caseBeforeInsert.addError('Phone request are only allowed to have three attendee');
        }
    }

}
