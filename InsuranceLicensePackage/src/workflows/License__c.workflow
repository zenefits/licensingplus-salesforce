<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>License_Expiring_in_N_days</fullName>
        <description>License Expiring in N days</description>
        <protected>false</protected>
        <recipients>
            <field>Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>License_Templates/License_Expires_in_N_days</template>
    </alerts>
    <alerts>
        <fullName>Populate_License</fullName>
        <description>Populate License #</description>
        <protected>false</protected>
        <recipients>
            <field>Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>License_Templates/Populate_License</template>
    </alerts>
    <fieldUpdates>
        <fullName>Generate_License_Name</fullName>
        <field>Name</field>
        <formula>Owner:User.FirstName &amp; &quot; &quot; &amp; Owner:User.LastName &amp; &quot; &quot; &amp; TEXT(State__c) &amp; &quot; License&quot;</formula>
        <name>Generate License Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Manager_Email</fullName>
        <field>Manager_Email__c</field>
        <formula>Owner:User.Manager.Email</formula>
        <name>Populate Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Generate License Name</fullName>
        <actions>
            <name>Generate_License_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>License Expiring Soon - N days</fullName>
        <active>false</active>
        <formula>AND(   Status__c = &apos;Active&apos;,   NOT(ISBLANK(Expiration_Date__c)),   Owner:User.IsActive )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Manager Email</fullName>
        <actions>
            <name>Populate_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
