public  class ExternalSystemService {

    public static void registerAttendees(List<Id> AccountIds){
    
        List<Contact> attendees = [SELECT id,name, email FROM Contact WHERE AccountId in :AccountIds];
        List<Contact> contactsToMail = new List<Contact>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ReservationExternalSystem');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object

        HttpResponse response;

        for(Contact c : attendees){
            request.setBody('{"name":"'+ c.Email + '-' + c.Name  +'}');
            response = http.send(request);
          
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus());
            }
            else {
                contactsToMail.add(c);
            }
        }
        notifyAttendeesByEmail(contactsToMail);
    
    }

    public static void notifyAttendeesByEmail(List<Contact> contacts){

        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        for(Contact c : contacts){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { c.Email };
            message.optOutPolicy = 'FILTER';
            message.subject = 'The Event Booked';
            message.plainTextBody = 'hello ' + c.Name+ ', the Event is booked ';
            lstMails.add(message);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMails);

        for(Messaging.SendEmailResult result : results){
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }

}
