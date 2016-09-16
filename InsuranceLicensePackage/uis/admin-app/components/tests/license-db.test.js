import expect from 'expect';
import React from 'react';
import {shallow} from 'enzyme';
import {Upload} from '../license-db';
import { ProgressBar } from 'react-bootstrap';

var props = {
    tooltipOpen: false,
    xmlReceived: {},
    showProgress: false,
    insertedProcedures: [],
    fileName: '',
    progressBarValue: 0,
    errorMessages: [],
    showToast: false,
    readXml: () => { return Promise.resolve(); },
    importLicenseData: () => { return Promise.resolve(); },
    updateProgressValue: () => { return Promise.resolve(); },
    uploadStarted: () => { return Promise.resolve(); },
    uploadSuccess: () => { return Promise.resolve(); },
    hideToast: () => { return Promise.resolve(); },
    handleChange: () => { }
};
function setup(props) {
    return shallow(<Upload  {...props}/>);
}

describe('License-db Component Tests', () => {
    it('renders License-db component', () => {
        const wrapper = setup(props);
        expect(wrapper.find('h4').first().text()).toEqual('License Database Maintenance ');
    });

    it('should display Choose File Option ', () => {
        const wrapper = setup(props)
        expect(wrapper.find('.file').length).toEqual(1);
    });

    it('should not display Choose File Option ', () => {
        props.showProgress = true;
        const wrapper = setup(props)
        expect(wrapper.find('.file').length).toEqual(0);
    })

    it('should display toaster', () => {
        props.showToast = true;
        const wrapper = setup(props);
        expect(wrapper.find('.alert').length).toEqual(1);
    });

    it('should not display toaster', () => {
        props.showToast = false;
        const wrapper = setup(props);
        expect(wrapper.find('.alert').length).toEqual(0);
    });

    it('should show ProgressBar ', () => {
        props.showProgress = true;
        const wrapper = setup(props);
        expect(wrapper.containsMatchingElement(<ProgressBar active bsStyle="warning" now={0} />)).toEqual(true)
    });

    it('should not show ProgressBar ', () => {
        props.showProgress = false;
        const wrapper = setup(props);
        expect(wrapper.containsMatchingElement(<ProgressBar active bsStyle="warning" now={0} />)).toEqual(false)

    });

});