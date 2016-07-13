import * as types from './action-types';

export function toggleChecklist(checklist) {
  return function (dispatch) {
    return LicensingPlus.ComplianceController.toggleChecklist(checklist, function () {
      dispatch({
        type: types.TOGGLE_CHECKLIST,
        checklist: checklist
      })
    })
  }
}