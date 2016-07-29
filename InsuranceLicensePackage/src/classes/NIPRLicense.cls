public with sharing class NIPRLicense { 
    public String npnNumber {get;set;}
    public String className {get;set;}
    public Date effectiveDate {get;set;}
    public Date expirationDate {get;set;}
    public String state {get;set;}
    public Boolean isResidentLicense {get;set;}
    public String licenseNumber {get;set;}
    public Boolean isActive {get;set;}
    public List<LineOfAuthority> linesOfAuthority {get;set;}
    
    public NIPRLicense() {
    	this.linesOfAuthority = new List<LineOfAuthority>();
    }
    
    public class LineOfAuthority {
    	public String name {get;set;}
    	public Boolean isActive {get;set;}
    }
}