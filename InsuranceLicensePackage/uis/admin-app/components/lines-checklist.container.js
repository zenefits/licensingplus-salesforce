import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import { VIDEO_LINK, OBJECTPREFIX, SKIPLOA} from '../constants/constants';
import _ from 'lodash';
import LinesCheckView from './lines-checklist.view';

export class LinesCheckContainer extends Component {
    constructor(props) {
        super(props)
        this.toggleChecklist = this.toggleChecklist.bind(this);
        this.onSkipClick = this.onSkipClick.bind(this);
    }

    toggleChecklist(key) {
        var checklist = Object.assign({}, this.props.checklist);
        var value = checklist[key] ? !checklist[key] : true;
        checklist[key] = value;
        this.props.toggleChecklist(checklist);
    }

    onSkipClick() {
        var checklist = Object.assign({}, this.props.checklist);
        _.mapKeys(SKIPLOA, function (value, key) {
            checklist[key] = true;
        });
        this.props.toggleChecklist(checklist);
    }


    render() {
        return (
            <div className='license-form'>
                <div>
                    <LinesCheckView
                        toggleChecklist={this.toggleChecklist}
                        onSkipClick={this.onSkipClick}
                        checklist={this.props.checklist}
                        />
                </div>
            </div>
        )
    }

}

const mapStateToProps = (state) => {
    return {
        checklist: state.checklist
    }
}

const mapDispatchToProps = (dispatch) => {
    return {
        toggleChecklist: (checklist) => {
            dispatch(toggleChecklist(checklist));
        }
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(LinesCheckContainer)