import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { VIDEO_LINK, OBJECTPREFIX, SKIPCOMPLIANCE} from '../constants/constants';
import _ from 'lodash';
import MaintainaceSidebar from './sidebar.maintainance.view';
var _csvTemplateLink = (typeof StaticResource === 'undefined') ? '#' : StaticResource.CONFIGURATION_LOA;
class CheckListComplete extends Component {
    constructor(props) {
        super(props)
    }

    renderCompliance() {
        return (
                <div className='checklist'>
                    <h2>Activate compliance rules</h2>
                    <div className='checkbox checkbox-container'>
                        <label className="padding-zero">
                            <label htmlFor='5' className='font-big'> Watch our video on <a href={VIDEO_LINK} target='_blank'>compliance rules best practices</a></label>
                        </label>
                    </div>
                    <div className='checkbox checkbox-container'>
                        <label  className="padding-zero">
                            <label htmlFor='5' className='font-big'>Enable Compliance Rules on <Link to={'/extend'} target='_blank'>custom objects</Link></label>
                        </label>
                    </div>
                    <br/>
                </div>
        )
    }

    renderLines() {
        return (
                <div className='checklist'>
                    <h2>Configure lines of authority</h2>
                    <div className='checkbox checkbox-container'>
                        <label className="padding-zero">
                            <label htmlFor='1' className='font-big'>Download the <a href={_csvTemplateLink}>configuration spreadsheet</a></label>
                        </label>
                    </div>
                    <div className='checkbox checkbox-container'>
                        <label className="padding-zero">
                            <label htmlFor='2' className='font-big'>Watch our <a href={VIDEO_LINK} target='_blank'>configuration video</a></label>
                        </label>
                    </div>
                    <div className='checkbox checkbox-container'>
                        <label  className="padding-zero">
                            <label htmlFor='3' className='font-big'>Send the spreadsheet to your compliance team</label>
                        </label>
                    </div>
                    <div className='checkbox checkbox-container'>
                        <label  className="padding-zero">
                            <label htmlFor='4' className='font-big'>Get the completed spreadsheet back</label>
                        </label>
                    </div>
                    <br/>
                </div>
        )
    }

    renderNipr() {
        return (
                <div className='checklist'>
                    <h2>Integrate NIPR </h2>
                    <div className='checkbox checkbox-container'>
                        <label  className="padding-zero">
                            <label htmlFor='7' className='font-big'>Watch our video on <a href="#/nipr">setting up NIPR integration</a></label>
                        </label>
                    </div>
                </div>
        )
    }

    render() {
        return (
            <div className='license-form'>
                <div>
                    <MaintainaceSidebar activePage='checklistcomplete' disableLink={true}/>
                     <div className='col-sm-9 getting-started inside-container'>
                    {this.renderLines() }
                    {this.renderCompliance() }
                    {this.renderNipr() }
                    </div>
                </div>
            </div>
        )
    }

}

export default CheckListComplete 