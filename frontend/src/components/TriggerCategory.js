// frontend/src/components/Utterance.js

import React, { Component, Fragment } from "react";
import Select from 'react-select';
import fetch from "node-fetch";

type State = {
    isClearable: boolean,
    isDisabled: boolean,
    isLoading: boolean,
    isRtl: boolean,
    isSearchable: boolean,
};

const techCompanies = [
    { label: "Apple", value: 1 },
    { label: "Facebook", value: 2 },
    { label: "Netflix", value: 3 },
    { label: "Tesla", value: 4 },
    { label: "Amazon", value: 5 },
    { label: "Alphabet", value: 6 },
];

export default class TriggerCategory extends Component<*, State> {
    constructor(props) {
        super(props);
        this.state = {
            categoryID: techCompanies[0]
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleSubmit(e) {
        e.preventDefault();
        let ID = this.state.categoryID;
        fetch("http://localhost:8000/api/categories/" + ID +  "/trigger", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
        }).then(response => {
            (response.json().then(data => {
                alert('message: ' + data['message'])
            }))
        });
    }

    handleChange(event) {
        this.setState({categoryID: event.value})
    }

    render() {
        const {
            isSearchable,
            isDisabled,
            isLoading,
        } = this.state;
        return (
            <form onSubmit={this.handleSubmit}>
                Please select the category to send!
                <Fragment>
                <Select
                    className="basic-single"
                    classNamePrefix="select"
                    defaultValue={techCompanies[0]}
                    isDisabled={isDisabled}
                    isLoading={isLoading}
                    isSearchable={isSearchable}
                    name="color"
                    options={techCompanies}
                    onChange={this.handleChange}
                />
                <div>
                    <input type="submit" value="Submit" />
                </div>
                </Fragment>
            </form>
        );
    }
}
