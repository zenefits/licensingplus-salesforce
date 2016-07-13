import * as types from './action-types';
import { hashHistory } from 'react-router';

export function getChecklist(pathname) {
  return (dispatch) => {
    return LicensingPlus.ComplianceController.getChecklist((checklist) => {
      var checklistComplete = checklist.licensingplus__download_spreadsheet__c
        && checklist.licensingplus__watch_configuration_video__c
        && checklist.licensingplus__send_spreadsheet__c
        && checklist.licensingplus__filled_spreadsheet__c
        && checklist.licensingplus__watch_video__c
        && checklist.licensingplus__set_approvals__c
        && checklist.licensingplus__watch_compliance_video__c;

      dispatch({
        type: types.CHECKLIST_RECEIVED,
        checklist: checklist,
        checklistComplete: checklistComplete
      });

      if(pathname === '/'){
        //do redirecting from app view.
        if(checklistComplete) {
          hashHistory.push('/rules');
        }
        else {
          hashHistory.push('/welcome');
        }
      }
    })
  }
}