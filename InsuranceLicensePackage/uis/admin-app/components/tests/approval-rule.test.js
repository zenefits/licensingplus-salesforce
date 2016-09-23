import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {ApprovalView} from '../approval-rule.view';

function setup() {
    const props = {
        licenseApprovalFileds: [],
        licenseRuleLogic: {},
        errors: false,
        validationUserList: [],
        validationUser: {},
        niprSyncConfig: {},
        licencesRuleObject: {},
        approvalProcessList: [],
        automatic_license_approval: false,
        getLicenseApprovalRule: () => { },
        getLicenseApprovalFields: () => { },
        selectLicenseChange: () => { },
        addLicenseRule: () => { },
        deleteLicenseRule: () => { },
        changeLicenseRuleLogic: () => { },
        toggleChangeActivateLicense: () => { },
        toggleChangeForceExpire: () => { },
        saveLicenseApprovalRuleSetResult: () => { },
        onChangeApprovalProcess: () => { },
        getValidationUser: () => { },
        setValidationUser: () => { },
        getApprovalProcesses: () => { },
        approvalProcessFields: () => { },
        cancelLicenseApprovalRuleSetResult: () => { },
    };

    return shallow(<ApprovalView  {...props}/>);
}

describe('ApprovalView Tests', () => {
    it('renders ApprovalView component', () => {
        const wrapper = setup();
        expect(wrapper.find('h4').first().text()).toEqual('License Approval Criteria  <Tooltip />');
    });
    it('save button should be disabled', () => {
        const wrapper = setup();
        expect(wrapper.containsMatchingElement(<input className='btn btn-orange' type='button' disabled={true}  value='Save & Next' />)).toEqual(true)
    });
    it('advance rule table should be hidden', () => {
        const wrapper = setup();
        expect(wrapper.find('.data-table').length).toEqual(0);
    });
    it('advance rule table should be shown', () => {
        const wrapper = setup();
        wrapper.setProps({
            automatic_license_approval: true
        });
        expect(wrapper.find('.data-table').length).toEqual(1);
        const tableHeaders = wrapper.find('.data-table').find('thead').children().first().children();
        
        expect(tableHeaders.length).toEqual(5);
        expect(tableHeaders.at(0).text()).toEqual('Rule Number');
        expect(tableHeaders.at(1).text()).toEqual('Insurance License');
        expect(tableHeaders.at(2).text()).toEqual('Operator');
        expect(tableHeaders.at(3).text()).toEqual('Value');
        expect(tableHeaders.at(4).text()).toEqual('');
    });
});
