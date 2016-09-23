import React, { Component } from 'react';
import { Link } from 'react-router';
import { NIPR_VIDEO_LINK, OBJECTPREFIX, SKIPCOMPLIANCE} from '../constants/constants';
import _ from 'lodash';
import Sidebar from './sidebar.container';

export class NiprCheckView extends Component {
    constructor(props) {
        super(props);
    }

    toggle() {
        this.setState({
            tooltipOpen: !this.state.tooltipOpen
        });
    }

    renderChecklist() {
        let renderBtn
        if (this.props.checklist[OBJECTPREFIX + 'nipr_setup__c']) {
            renderBtn = (<Link to='/nipr' className='link btn btn-warning btn-checklist'  role='button'>Setup </Link>)
        }
        else {
            renderBtn = (
                <div>
                    <Link to='/nipr' className='btn btn-secondary secondary-disabled btn-checklist' role='button' onClick={e => e.preventDefault() }>Setup</Link>
                    <br/><br/>
                    <Link to='/complete' className="skip" onClick={this.props.onSkipClick.bind(this) }>Skip ></Link>
                </div>
            )
        }
        return (
            <div className='col-sm-9 getting-started inside-container'>
                <div className='checklist'>
                    <h2 >Integrate NIPR</h2>
                    <hr/>
                    <div className='checkbox checkbox-container'>
                        <label>
                            <input type='checkbox'  checked={this.props.checklist[OBJECTPREFIX + 'nipr_setup__c']} id='7' onChange={this.props.toggleChecklist.bind(this, OBJECTPREFIX + 'nipr_setup__c') } ></input>
                            <label htmlFor='7' className='label-check'> Watch our video on <a href={NIPR_VIDEO_LINK} target='_blank'>setting up NIPR integration</a></label>
                        </label>
                    </div>
                    <div>
                        {renderBtn}
                    </div>
                </div>
            </div>
        )
    }

    render() {
        return (
            <div className='license-form'>
                <div >
                    <Sidebar activePage='niprchecklist'/>
                    {this.renderChecklist() }
                </div>
            </div>
        )
    }

}


export default NiprCheckView;