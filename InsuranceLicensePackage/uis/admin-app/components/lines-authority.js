import React, { Component } from 'react';
import { connect } from 'react-redux';
import Papa from 'papaparse';
import * as constants from '../constants/constants';
import { OBJECTPREFIX } from '../constants/constants';
import Utils from '../utils/utils';
import { Link } from 'react-router';
import { deleteLineOfAuth, cancelPreview, getLinesOfAuth, insertLinesOfAuth, openCsv, showInvalidToast, hideInvalidToast, hideInvalidFileToast, showInvalidFileToast } from '../actions/lines-authority-actions';
import {hideToast} from '../actions/object-rule-set-actions';
import Sidebar from './sidebar.container';

export class LinesAuthority extends Component {
  constructor() {
    super();
    this.state = {
      showToast: false,
    }
    this.deleteLineOfAuth = this.deleteLineOfAuth.bind(this);
    this.cancelPreview = this.cancelPreview.bind(this);
    this.hideNiprInvalidToast = this.hideNiprInvalidToast.bind(this);
    this.hideNiprInvalidFileToast = this.hideNiprInvalidFileToast.bind(this);
  }

  componentDidMount() {
    // javascript remoting to get existing lines of auth values
    this.props.getLinesOfAuth();
    this.props.hideNiprInvalidToast();
  }

  hideToast(event) {
    event.preventDefault();
    this.props.hideToast();
  }

  hideNiprInvalidToast(event) {
    event.preventDefault();
    this.props.hideNiprInvalidToast();
  }

  hideNiprInvalidFileToast(event) {
    event.preventDefault();
    this.props.hideNiprInvalidFileToast();
  }

  renderToast() {
    if (this.props.showToast) {
      return (
        <div className='alert alert-danger toast' >
          <a onClick={this.props.hideToast.bind(null) }>Dismiss</a>
          <strong className='fa fa-exclamation-triangle'></strong> Something went wrong, check the CSV format is correct
        </div>
      );
    }
  }

  renderInvalidToast() {
    if (this.props.showInvalidToast) {
      return (
        <div className='alert alert-danger toast' >
          <a onClick={this.hideNiprInvalidToast }>Dismiss</a>
          <strong className='fa fa-exclamation-triangle'></strong>Invalid File
        </div>
      );
    }
  }

  renderInvalidFileToast() {
    if (this.props.showInvalidFileToast) {
      return (
        <div className='alert alert-danger toast' >
          <a onClick={this.hideNiprInvalidFileToast }>Dismiss</a>
          <strong className='fa fa-exclamation-triangle'></strong>File columns should be equal to 2.
        </div>
      );
    }
  }

  openCsv(ev) {
    var file = ev.target.files[0];
    if (file.name.toLowerCase().indexOf('.csv') !== -1) {
      var config = {
        header: true,
        dynamicTyping: true,
        complete: (results) => {
          if (!_.isUndefined(results.data) && !_.isUndefined(results.data[0])) {
            var count = Object.keys(results.data[0]).length;
            if (count == 2) {
              var previewRows = results.data.map((row, index) => {           
                // return mapObj( obj, csv2SfdcMap )
                row = Utils.lowKey(row);
                var uniqueName = row['loa name'].substring(0, 30) + this.props.sfdcRows.length + index;
                return {
                  name: uniqueName,
                  [OBJECTPREFIX + 'loa_name__c']: row['loa name'],
                  [OBJECTPREFIX + 'type__c']: row.type
                }
              })
                .filter((obj) => {
                  return (obj[OBJECTPREFIX + 'loa_name__c'] && obj[OBJECTPREFIX + 'type__c']) ? true : false;
                });
              this.props.openCsv(previewRows, file.name);

            } else {
              this.props.showNiprInvalidFileToast();
            }
          }
        }
      }
      Papa.parse(file, config);
    } else {
      this.props.showNiprInvalidToast();
    }
  }

  insertLinesOfAuth() {
    this.props.insertLinesOfAuth(this.props.previewRows);
  }

  deleteLineOfAuth(row) {
    this.props.deleteLineOfAuth(row);
  }
  cancelPreview() {
    this.props.cancelPreview();
  }

  renderLoaRows() {
    let dataRows = (this.props.previewRows.length > 0) ? this.props.previewRows : this.props.sfdcRows
    let rows = dataRows.map((loaRow, index) => {
      let row;
      if (this.isPreviewMode()) {
        row = (
          <tr key={index} className={index % 2 == 0 ? 'row-odd' : 'row-even'}>
            <td>{loaRow[OBJECTPREFIX + 'loa_name__c']}</td>
            <td>{loaRow[OBJECTPREFIX + 'type__c']}</td>
          </tr>
        );
      }
      else {
        row = (
          <tr key={index} className= {index % 2 == 0 ? 'row-odd' : 'row-even'}>
            <td>{_.unescape(loaRow[OBJECTPREFIX + 'loa_name__c']) }</td>
            <td>
              {_.unescape(loaRow[OBJECTPREFIX + 'type__c']) }
            </td>
            <td>
              <button type='button' className='add-btn' onClick={this.deleteLineOfAuth.bind(null, loaRow) }>-</button>
            </td>
          </tr>
        );
      }
      return row;
    })

    return rows;
  }

  isPreviewMode() {
    return this.props.previewRows.length > 0;
  }

  renderDataTable() {
    let upload, dataTable, preview, cancel;
    if (this.isPreviewMode()) {
      preview = (<div className='heading-table'><h3>Preview</h3></div>);
      upload = <input onClick={this.insertLinesOfAuth.bind(this) } className='btn btn-orange' type='button' value='Save' />;
      cancel = <input className='btn btn-white' onClick={this.cancelPreview.bind(this) } type='button' value='Cancel' />;

      dataTable = (
        <table className='table'>
          <thead>
            <tr>
              <th> Line of Authority </th>
              <th> Master Category </th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this.renderLoaRows() }
          </tbody>
        </table>
      );
    }
    else if (this.props.sfdcRows && this.props.sfdcRows.length > 0) {
      preview = (<div className='heading-table'><h5>Preview Spreadsheet</h5></div>);
      dataTable = (
        <table className='table'>
          <thead>
            <tr>
              <th> Line of Authority </th>
              <th> Master Category </th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this.renderLoaRows() }
          </tbody>
        </table>
      );
    }

    return (
      <span className='data-table'>
        {preview}
        {dataTable}
        <hr/>
        {upload}
        {cancel}
      </span>
    );
  }
  render() {
    var nextButton;
    if (this.props.isMaintainanceMode || this.isPreviewMode()) {
      nextButton = true;
    } else {
      nextButton = false;
    }
    return (
      <div className='license-form div-float'>
        {this.renderToast() }
        {this.renderInvalidToast() }
        {this.renderInvalidFileToast() }
        <div>
          <Sidebar activePage='lines' checklistComplete={this.props.checklistComplete}/>
          <div className='col-sm-9 inside-container'>
            <h4 className="sub-heading">Upload Your Lines of Authority Spreadsheet</h4>
            <br/>
            <form onChange={this.openCsv.bind(this) }>
              <label className='file'>
                <span className='csvInput'></span>
                <input type='file' id='csvInput' title=' '/>
                <span className='file-custom choose-button' data-file-name={this.props.fileName}>Choose File</span>
              </label>
            </form>
            {this.renderDataTable() }
            <Link to={`/compliancechecklist`} className={nextButton ? 'btn donebtn-visibility' : 'btn btn-warning btn-right next-button'}>
              Next
            </Link>
          </div>
        </div>
        <hr />

      </div>);
  }
}

const mapStateToProps = (state) => {
  return {
    checklistComplete: state.checklistComplete,
    previewRows: state.previewRows,
    sfdcRows: state.sfdcRows,
    showToast: state.showToast,
    fileName: state.fileName,
    isMaintainanceMode: state.isMaintainanceMode,
    showInvalidToast: state.showInvalidToast,
    showInvalidFileToast: state.showInvalidFileToast
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    openCsv: (previewRows, fileName) => {
      dispatch(openCsv(previewRows, fileName));
    },
    insertLinesOfAuth: (previewRows) => {
      dispatch(insertLinesOfAuth(previewRows));
    },
    deleteLineOfAuth: (row) => {
      dispatch(deleteLineOfAuth(row));
    },
    cancelPreview: () => {
      dispatch(cancelPreview());
    },
    getLinesOfAuth: () => {
      dispatch(getLinesOfAuth());
    },
    hideToast: () => {
      dispatch(hideToast());
    },
    hideNiprInvalidToast: () => {
      dispatch(hideInvalidToast());
    },
    showNiprInvalidToast: () => {
      dispatch(showInvalidToast());
    },
    hideNiprInvalidFileToast: () => {
      dispatch(hideInvalidFileToast());
    },
    showNiprInvalidFileToast: () => {
      dispatch(showInvalidFileToast());
    }
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(LinesAuthority)