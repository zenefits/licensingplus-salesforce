import * as types from './action-types';

export function openCsv(previewRows, fileName) {
  return {
    type: types.OPEN_CSV,
    previewRows: previewRows,
    fileName: fileName
  };
}

export function cancelPreview() {
  return {
    type: types.CANCEL_PREVIEW,
    previewRows: []
  };
}

export function insertLinesOfAuth(previewRows) {
  return function (dispatch) {
    return ComplianceController.insertLinesOfAuth(previewRows, (sfdcRows) => {
      dispatch({
        type: types.LINES_OF_AUTH_INSERTED,
        sfdcRows: sfdcRows
      })
    })
  }
}

export function deleteLineOfAuth(row) {
  return function (dispatch) {
    return ComplianceController.deleteLineOfAuth(row, () => {
      dispatch({
        type: types.LINE_OF_AUTH_DELETED,
        row: row
      })
    })
  }
}

export function getLinesOfAuth() {
  return function (dispatch) {
    return ComplianceController.getLinesOfAuth((sfdcRows) => {
      dispatch({
        type: types.LINES_OF_AUTH_RECEIVED,
        sfdcRows: sfdcRows
      })
    })
  }
}