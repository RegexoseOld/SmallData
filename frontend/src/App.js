// frontend/src/App.js

import React, { Component } from "react";
import fetch from "node-fetch";


class App extends Component {
    constructor(props) {
        super(props);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleSubmit(e) {
        e.preventDefault();
        let userData =  this.input.value;
        fetch("http://localhost:8000/api/utterances/", {
            method: "POST",
            body: JSON.stringify({text: userData}),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
        }).then(response => {
            (response.json().then(data => {alert('You said: ' + data['text'] +
                '.\n Machine thinks: ' + data['category']['name'])
            }).then(val => this.resetForm()))
        });
    }

    resetForm() {
        this.input.value = "";
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
                    <textarea type="text" style={{width: 350}} ref={(input) => this.input = input} />
                </form>
                </div>

                <div className="row ">
                    <input type="submit" value="Submit" />
                </div>

                </div>
            </main>
        );
    }


}

export default App;
