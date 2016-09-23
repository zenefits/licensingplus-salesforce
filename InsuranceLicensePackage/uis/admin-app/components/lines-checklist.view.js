import React, { Component } from 'react';
import { Link } from 'react-router';
import { CONFIGURATION_VIDEO_LINK, OBJECTPREFIX, SKIPCOMPLIANCE} from '../constants/constants';
import _ from 'lodash';
import Sidebar from './sidebar.container';

var _csvTemplateLink = (typeof StaticResource === 'undefined') ? '#' : StaticResource.CONFIGURATION_LOA;

export class LinesCheckView extends Component {
    constructor(props) {
        super(props)
    }

    renderButton() {
        var isLoaChecklistComplete = this.props.checklist[OBJECTPREFIX + 'download_spreadsheet__c']
            && this.props.checklist[OBJECTPREFIX + 'watch_configuration_video__c']
            && this.props.checklist[OBJECTPREFIX + 'send_spreadsheet__c']
            && this.props.checklist[OBJECTPREFIX + 'filled_spreadsheet__c'];

        const label = 'Configure Lines of Authority';
        
        if (isLoaChecklistComplete) {
            return <Link to='/lines' className='btn btn-warning btn-checklist' role='button'>{label}</Link>;
        }
        else {
            return (
                <div>
                    <Link to='/lines' className='btn btn-secondary secondary-disabled btn-checklist' role='button' onClick={e => e.preventDefault() }>{label}</Link>
                    <br/><br/>
                    <Link to='/compliancechecklist' className="skip" onClick={this.props.onSkipClick.bind(this) } >Skip ></Link>
                </div>
            )
        }
    }

    renderChecklist() {
        var checklistEmpty = !(OBJECTPREFIX + 'download_spreadsheet__c' in this.props.checklist)
        if (checklistEmpty) {
            return (
                <div className='col-sm-9 getting-started inside-container'>
                    <div className='checklist'>
                        <h2>Configure lines of authority</h2>
                        <hr/>
                    </div>
                </div>
            )
        } else {
            return (
                <div className='col-sm-9 getting-started inside-container'>
                    <div className='checklist'>
                        <h2>Configure lines of authority</h2>
                        <br/>
                        <div className='checkbox checkbox-container'>
                            <label>
                                <input type='checkbox' id='1' checked={this.props.checklist[OBJECTPREFIX + 'download_spreadsheet__c']} onChange={this.props.toggleChecklist.bind(this, OBJECTPREFIX + 'download_spreadsheet__c') }></input>
                                <label htmlFor='1' className='label-check'>Download the <a href={_csvTemplateLink}>configuration spreadsheet</a></label>
                            </label>
                        </div>
                        <div className='checkbox checkbox-container'>
                            <label>
                                <input type='checkbox' id='2' checked={this.props.checklist[OBJECTPREFIX + 'watch_configuration_video__c']} onChange={this.props.toggleChecklist.bind(this, OBJECTPREFIX + 'watch_configuration_video__c') }></input>
                                <label htmlFor='2' className='label-check'>Watch the <a href={CONFIGURATION_VIDEO_LINK} target='_blank'>configuration video</a></label>
                            </label>
                        </div>
                        <div className='checkbox checkbox-container'>
                            <label>
                                <input type='checkbox' id='3' checked={this.props.checklist[OBJECTPREFIX + 'send_spreadsheet__c']} onChange={this.props.toggleChecklist.bind(this, OBJECTPREFIX + 'send_spreadsheet__c') }></input>
                                <label htmlFor='3' className='label-check'>Send the spreadsheet to your compliance team</label>
                            </label>
                        </div>
                        <div className='checkbox checkbox-container'>
                            <label>
                                <input type='checkbox' id='4' checked={this.props.checklist[OBJECTPREFIX + 'filled_spreadsheet__c']} onChange={this.props.toggleChecklist.bind(this, OBJECTPREFIX + 'filled_spreadsheet__c') }></input>
                                <label htmlFor='4' className='label-check'>Get the completed spreadsheet back</label>
                            </label>
                        </div>
                        <br/>
                        <div>
                            {this.renderButton() }
                        </div>
                        <br/>
                    </div>

                </div>
            )
        }
    }

    render() {
        return (
            <div className='license-form'>
                <div>
                    <Sidebar activePage='lineschecklist'/>
                    {this.renderChecklist() }
                </div>
            </div>
        )
    }

}


export default LinesCheckView;