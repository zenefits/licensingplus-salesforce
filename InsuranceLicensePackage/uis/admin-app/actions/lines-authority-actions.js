import * as types from './action-types';
import { CLASSPREFIX } from '../constants/constants';

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
    return eval(CLASSPREFIX).insertLinesOfAuth(previewRows, (sfdcRows) => {
      dispatch({
        type: types.LINES_OF_AUTH_INSERTED,
        sfdcRows: sfdcRows
      })
    })
  }
}

export function deleteLineOfAuth(row) {
  return function (dispatch) {
    return eval(CLASSPREFIX).deleteLineOfAuth(row, () => {
      dispatch({
        type: types.LINE_OF_AUTH_DELETED,
        row: row
      })
    })
  }
}

export function getLinesOfAuth() {
  return function (dispatch) {
    return eval(CLASSPREFIX).getLinesOfAuth((sfdcRows) => {
      dispatch({
        type: types.LINES_OF_AUTH_RECEIVED,
        sfdcRows: sfdcRows
      })
    })
  }
}

export function showInvalidToast() {
  return {
    type: types.SHOW_INVALID_TOAST
  };
}

export function hideInvalidToast() {
  return {
    type: types.HIDE_INVALID_TOAST
  };
}

export function showInvalidFileToast() {
  return {
    type: types.SHOW_INVALID_FILE_TOAST
  };
}

export function hideInvalidFileToast() {
  return {
    type: types.HIDE_INVALID_FILE_TOAST
  };
}