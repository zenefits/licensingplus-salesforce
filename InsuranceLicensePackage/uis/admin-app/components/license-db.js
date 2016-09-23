import React, { Component } from 'react';
import _ from 'lodash';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import { parseString } from 'xml2js';
import { uploadError,readXml, importLicenseData, uploadStarted, updateProgressValue, uploadSuccess, updateMaintenanceMode, showInvalidDbToast, hideInvalidDbToast } from '../actions/upload-actions';
import { ProgressBar } from 'react-bootstrap';
import { DB_VIDEO_LINK } from '../constants/constants';
import Utils from '../utils/utils';
import { hideToast } from '../actions/upload-actions';
import { Tooltip } from 'reactstrap';
import Promise from 'promise';
import Sidebar from './sidebar.container';
import {OBJECTPREFIX } from '../constants/constants';
import { toggleChecklist } from '../actions/checklist-actions';
export class Upload extends Component {
    constructor(props) {
        super(props);
        this.handleChange = this.handleChange.bind(this);
        this.exportToCSV = this.exportToCSV.bind(this);
        this.toggle = this.toggle.bind(this);
        this.doneClick = this.doneClick.bind(this);
        this.processChunks = this.processChunks.bind(this);
        this.hideInvalidToast = this.hideInvalidToast.bind(this);
        this.state = {
            tooltipOpen: false
        };
    } 

    exportToCSV() {
        Utils.exportToCSV('datatable', 'errorMessages.csv');
    }

    doneClick() {
        var checklist = Object.assign({}, this.props.checklist);
        checklist[OBJECTPREFIX + "completed_setup__c"] = true;
        this.props.toggleChecklist(checklist);
        this.props.updateMaintenanceMode();
    }

    toggle() {
        this.setState({
            tooltipOpen: !this.state.tooltipOpen
        });
    }

    processChunks(chunks, progressBarValue) {
        var processChunks = this.processChunks;
        var props = this.props;
        if (chunks.length > 0) {
            new Promise(function (resolve, reject) {
                props.importLicenseData(chunks[0].chunk, function () {
                    props.updateProgressValue(100 - (progressBarValue * (chunks.length - 1)), true);
                    chunks.splice(0, 1);
                    processChunks(chunks, progressBarValue);
                    resolve();
                });
            });
        } else {
            if (props.errorMessages.length === 0) {
                props.updateProgressValue(100, true);
                setTimeout(function () {
                    props.uploadSuccess();
                }, 300);
            } else {
                props.updateProgressValue(100, true);
                setTimeout(function () {
                    props.uploadError();
                }, 300);
                this.exportToCSV();
            }
        }
    }

    handleChange(event) {
        var props = this.props;
        var exportToCSV = this.exportToCSV;
        var file = event.target.files[0];
        var reader = new FileReader();
        var processChunks = this.processChunks;
        const CHUNK_SIZE = 100;
        props.uploadStarted();
        reader.readAsText(file);
        reader.onload = function () {
            var xmlString = reader.result;
            parseString(xmlString, (err, result) => {
                props.readXml(result, file.name);
                if (!_.isUndefined(result.SCB_Report) && !_.isUndefined(result.SCB_Report.SCB_Report_Body) && !_.isUndefined(result.SCB_Report.SCB_Report_Body[0]) && !_.isUndefined(result.SCB_Report.SCB_Report_Body[0].SCB_Producer)) {
                    var xmlData = _
                        .chain(result.SCB_Report.SCB_Report_Body[0].SCB_Producer)
                        .reduce((memo, producer, index) => {
                            if (producer.License) {
                                var licenses = _.map(producer.License, (license, index) => {
                                    var lineOfAuthority = [];
                                    if (license.LOA) {
                                        _.map(license.LOA, (loa, index) => {
                                            lineOfAuthority.push({
                                                name: loa['$'].LOA_Name,
                                                isActive: loa['$'].LOA_Status === 'Active' ? true : false
                                            });
                                        });
                                    }
                                    return {
                                        npnNumber: producer['$'].National_Producer_Number,
                                        className: license['$'].Class,
                                        effectiveDate: !_.isEmpty(license['$'].License_Issue_Date) ? new Date(Utils.formatSfdcDate(license['$'].License_Issue_Date)).toUTCString() : null,
                                        expirationDate: !_.isEmpty(license['$'].License_Expiration_Date) ? new Date(Utils.formatSfdcDate(license['$'].License_Expiration_Date)).toUTCString() : null,
                                        niprUpdateDate: new Date().toUTCString(),
                                        state: license['$'].State_Code,
                                        isResidentLicense: license['$'].Resident_Indicator === 'Y' ? true : false,
                                        licenseNumber: license['$'].License_Number,
                                        isActive: license['$'].Active === 'Y' ? true : false,
                                        linesOfAuthority: lineOfAuthority
                                    }
                                });
                                return memo.concat(licenses);
                            }
                            return memo;
                        }, [])
                        .value();
                    var chunkedXml = [];
                    chunkedXml = _.chunk(_.sortBy(xmlData, 'isResidentLicense').reverse(), CHUNK_SIZE);
                    var progressBarValue = CHUNK_SIZE / chunkedXml.length;
                    var promiseArray = [];
                    chunkedXml.map((item, i) => {
                        promiseArray.push({ 'id': i, 'chunk': item });
                    });

                    processChunks(promiseArray, progressBarValue);
                } else {
                    props.showInvalidToast();
                }
            });
        };
    }

    hideToast(event) {
        event.preventDefault();
        this.props.hideToast();
    }

    hideInvalidToast(event) {
        event.preventDefault();
        this.props.hideInvalidToast();
    }

    renderPregressBar() {
        if (this.props.showProgress ) {
            return (
                <ProgressBar active bsStyle="warning" now={this.props.progressBarValue} />
            )
        }
    }

    renderChooseFileForm() {
        if (!this.props.showProgress) {
            return (
                <form onChange={this.handleChange.bind(this) }>
                    <label className='file'>
                        <span className='csvInput'></span>
                        <input type='file' id='csvInput' title='' accept="text/xml"/>
                        <span className='file-custom' title={this.props.fileName} data-file-name={this.props.fileName}><span className="choose-button">Choose File</span></span>
                    </label>
                </form>
            )
        }
    }

    renderToast() {
        if (this.props.showToast) {
            return (
                <div className='row'>
                    <div className='alert alert-success toast' >
                        <a onClick={this.props.hideToast.bind(null) } >Dismiss</a>
                        <strong className='fa fa-check'></strong> Upload completed successfully.
                    </div>
                </div>
            );
        }
    }

    renderInvalidToast() {
        if (this.props.showInvalidDbToast) {
            return (
                <div className='row'>
                    <div className='alert alert-danger toast' >
                        <a onClick={this.hideInvalidToast } >Dismiss</a>
                        <strong className='fa fa-exclamation-triangle'></strong>File is not in proper format.
                    </div>
                </div>
            );
        }
    }

    renderNav() {
        return (
            <Sidebar activePage='db'/>
        );
    }

    render() {
        return (
            <div className='license-form'>
                {this.renderToast() }
                {this.renderInvalidToast() }
                <div>
                    { this.renderNav() }

                    <div className='col-md-9 inside-container'>
                        <h4 className="sub-heading">License Database Maintenance <small><span id="helpToolTipDb" className='fa fa-question-circle question-icon-size'></span></small></h4>
                        <Tooltip placement="top left" isOpen={this.state.tooltipOpen} target="helpToolTipDb" toggle={this.toggle}>
                            Use NIPR PDB reports to batch upload licenses for one of multiple producers.
                        </Tooltip>
                        <p><a href={DB_VIDEO_LINK} target='_blank'>Watch our tutorial video on License Database maintenance</a></p>
                        <br></br>
                        <h5>Upload Your NIPR PDB Batch XML File</h5>
                        <div className="license-db-div">
                            { this.renderChooseFileForm() }
                            { this.renderPregressBar() }
                            <h5 className="license-db-text">We recommend that you delete all existing licenses
                                <br></br>
                                and start with a fresh NIPR PDB batch report
                            </h5>
                        </div>
                        <div className='row'>
                            <div className='col-md-12'>
                                <Link to='/complete' className={this.props.isMaintainanceMode ? 'btn donebtn-visibility' : 'btn btn-orange'} role='button' onClick={this.doneClick.bind(this) }>Done</Link>
                                <table className='hidden' id="datatable">
                                    <thead>
                                        <tr>
                                            <th><b>Code</b></th>
                                            <th><b>Message</b></th>
                                            <th><b>Is Success</b></th>
                                            <th><b>Key</b></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {
                                            this.props.errorMessages.map(function (item, i) {
                                                return (
                                                    <tr key={i}>
                                                        <td>{item.errorCode}</td>
                                                        <td>{item.errorMessage}</td>
                                                        <td>{item.isSuccess.toString() }</td>
                                                        <td>{item.key}</td>
                                                    </tr>
                                                );
                                            }, this)
                                        }
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

const mapStateToProps = (state) => {
    return {
        xmlReceived: state.xmlReceived,
        showProgress: state.showProgress,
        insertedProcedures: state.insertedProcedures,
        fileName: state.fileName,
        progressBarValue: state.progressBarValue,
        errorMessages: state.errorMessages,
        showToast: state.showToast,
        checklist: state.checklist,
        isMaintainanceMode: state.isMaintainanceMode,
        showInvalidDbToast: state.showInvalidDbToast
    };
}

const mapDispatchToProps = (dispatch) => {
    return {
        readXml: (xmlReceived, fileName) => {
            dispatch(readXml(xmlReceived, fileName));
        },
        importLicenseData: (procedures, callback) => {
            dispatch(importLicenseData(procedures, callback));
        },
        updateProgressValue: (progressValue, showProgress) => {
            dispatch(updateProgressValue(progressValue, showProgress));
        },
        uploadStarted: () => {
            dispatch(uploadStarted());
        },
        uploadSuccess: () => {
            dispatch(uploadSuccess());
        },
        uploadError: () => {
            dispatch(uploadError());
        },
        hideToast: () => {
            dispatch(hideToast());
        },
        updateMaintenanceMode: () => {
            dispatch(updateMaintenanceMode());
        },
        showInvalidToast: () => {
            dispatch(showInvalidDbToast());
        },
        hideInvalidToast: () => {
            dispatch(hideInvalidDbToast());
        },
        toggleChecklist: (checklist) => {
            dispatch(toggleChecklist(checklist));
        },
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(Upload);
