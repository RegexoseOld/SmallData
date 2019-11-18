// frontend/src/App.js

import React, { Component } from "react";
import fetch from "node-fetch";


class App extends Component {
    constructor(props) {
        super(props);
        this.state = {
            text: ''
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleSubmit(e) {
        e.preventDefault();
        fetch("http://localhost:8000/api/utterances/", {
            method: "POST",
            body: JSON.stringify(this.state),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
        }).then(response => {
            (response.json().then(data => {alert('You said: ' + data['text'] +
                '\n Machine thinks: ' + data['category']['name'])
            }).then(val => this.resetForm()))
        });
    }

    handleChange(event) {
        this.setState({text: event.target.value});
    }

    resetForm() {
        this.setState({text: ''});
    }

    render() {
        return (
            <main className="content">
                <div className="col-md-6 col-sm-10 mx-auto p-0">
                <h1 className="text-black text-uppercase text-center my-4">Small Data</h1>
                <div className="row ">
                <label>
                    Please enter your utterance:
                </label>
                </div>

                <div className="row ">
                <form onSubmit={this.handleSubmit}>
                    <textarea type="text" style={{width: 350}}
                              onChange={this.handleChange}
                              value={this.state.text}
                    />
                    <div>
                    <input type="submit" value="Submit" />
                    </div>
                </form>
                </div>

                </div>
            </main>
        );
    }

}

export default App;
