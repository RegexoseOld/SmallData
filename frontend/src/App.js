// frontend/src/App.js

import Utterance from './components/Utterance';
import React, { Component } from "react";
import fetch from "node-fetch";


class App extends Component {
    render() {
        return (
            <div>
                <Utterance/>
            </div>
        );
    }
}

export default App;
