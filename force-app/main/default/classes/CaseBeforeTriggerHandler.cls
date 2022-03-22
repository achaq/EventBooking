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


    public void onBeforeUpdate(List<Case> casesBeforeUpdate) {
        for (Case caseUpdated : [SELECT AccountId, Status FROM Case where id in:casesBeforeUpdate]){
            if(caseUpdated.Status == 'Closed'){
                ExternalSystemService service = new ExternalSystemService();
                service.registerAttendees(caseUpdated);
            }
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
