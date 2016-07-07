import React, { Component } from 'react';
import { connect } from 'react-redux';
import Papa from 'papaparse';
import * as constants from '../constants/constants';
import Utils from '../utils/utils';
import { Link } from 'react-router';
import { deleteLineOfAuth, cancelPreview, getLinesOfAuth, insertLinesOfAuth, openCsv } from '../actions/lines-authority-actions';
import {hideToast} from '../actions/object-rule-set-actions'; 

class LinesAuthority extends Component {
  constructor() {
    super();
     this.state = {
      showToast: false,
     }
    this.deleteLineOfAuth = this.deleteLineOfAuth.bind(this);
    this.cancelPreview = this.cancelPreview.bind(this);
  }

  componentDidMount() {
    // javascript remoting to get existing lines of auth values
    this.props.getLinesOfAuth();
  }

  hideToast(event) {
    event.preventDefault();
    this.props.hideToast();
  }

  renderToast() {
    if (this.props.showToast) {
      return (
        <div className='alert alert-danger toast' >
          <a onClick={this.props.hideToast.bind(null) }>Dismiss</a>
          <strong className='glyphicon glyphicon-alert'></strong> Something went wrong, check the CSV format is correct
        </div>
      );
    }
  }

  openCsv( ev ) {
    var file = ev.target.files[ 0 ];
    var config = {
      header: true,
      dynamicTyping: true,
      complete: (results) => {
        var previewRows = results.data.map( ( row, index ) => {
            // return mapObj( obj, csv2SfdcMap )
            row = Utils.lowKey(row);
            var uniqueName = row['loa name'] + this.props.sfdcRows.length + index;
            return {
              name: uniqueName,
              loa_name__c: row['loa name'],
              type__c: row.type
            }
          })
          .filter( ( obj ) => {
            return (obj.loa_name__c && obj.type__c) ? true : false;
          });

        this.props.openCsv(previewRows, file.name);
      }
    }

    Papa.parse( file, config );
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
      if(this.isPreviewMode()){
        row = (
          <tr key={index}>
            <td>{loaRow.loa_name__c}</td>
            <td>{loaRow.type__c}</td>
          </tr>
        );
      }
      else {
        row = (
          <tr key={index}>
            <td>{_.unescape(loaRow.loa_name__c)}</td>
            <td>
              {_.unescape(loaRow.type__c)}
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
      preview = (<div className='heading-table'><h3>Lines Of Authority</h3><small>These are your saved items.</small></div>);
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
    var links = (
      <div className='salesforce-link-lines'>
        <p>
          <small><span className='glyphicon glyphicon-question-sign'></span> Need more help?<a className='link' href={constants.VIDEO_LINK} target='_blank'>Watch our video!</a></small>
        </p>
        <p>
          <a className='link' href='/'>Return to Salesforce</a>
        </p>
      </div>
    )
    var back = (
      <h4>
        <Link to={`/checklist`}>
          &lt; Back to Checklist
        </Link>
      </h4>
    )

    var sideNavigation = (
      <div className='col-sm-3 zenefits-nav'>
        {back}
        <h1>Configure lines of authority</h1>
        <p>Make sure your compliance team has filled out the spreadsheet and classified your lines of authority into master groups.</p>
        {links}
      </div>
    );

    if (this.props.checklistComplete) {
      sideNavigation = (
        <div className='col-sm-3 zenefits-nav'>
          {back}
          <ul className='nav nav-pills nav-stacked'>
            <li role='presentation'><Link to={`/rules`}>Compliance Rules</Link></li>
            <li role='presentation' className='active'><Link to={`/lines`}>Lines of Authority</Link></li>
          </ul>
          {links}
        </div>
      );
    }
    return (
      <div className='license-form'>
        {this.renderToast()}
        <div className='row'>
          {sideNavigation}
          <div className='col-sm-9 inside-container'>
            <h4>Configure lines of authority</h4>
            <p>
              <small>Upload your lines of authority spreadsheet.</small>
            </p>
            <br/>
            <form onChange={this.openCsv.bind(this) }>
              <label className='file'>
              <span className='csvInput'></span>
                <input type='file' id='csvInput' title=' '/>
                <span className='file-custom' data-file-name={this.props.fileName}>Choose file</span>
              </label>
            </form>
            <hr/>
            {this.renderDataTable() }
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
    fileName: state.fileName
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
    }
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(LinesAuthority)