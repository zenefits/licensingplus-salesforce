global with sharing class EmailUtils {
    
    global static void sendEmail(List<String> recipients, String displayName, String subject, String body, Boolean useHtml, 
    							Messaging.EmailFileAttachment[] fileAttachments) {                   
        // build singleEmailMessage
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(recipients);
        email.setSubject(subject);              
        
        if (displayName!=null) {
        	email.setSenderDisplayName(displayName);
        }  
        
        if (useHtml) {
          	email.setHtmlBody(body);
        } else {
        	email.setPlainTextBody(body);  
        }
        
        if (fileAttachments!=null && !fileAttachments.isEmpty()) {
          	email.setFileAttachments(fileAttachments);
        }
        
        try {
            Messaging.sendEmail(new List<Messaging.Email>{email});
        } catch (Exception emailExc) {
        	LogUtils.logError('EmailUtils', 'sendEmail', emailExc.getMessage());
            LogUtils.logError('EmailUtils', 'sendEmail', 'Email Body\n\n: ' + body);
        }
    }
}