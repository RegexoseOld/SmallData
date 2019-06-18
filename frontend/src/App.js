// frontend/src/App.js

import React, { Component } from "react";
import Modal from "./components/Modal";
import axios from "axios";

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      viewCompleted: false,
      activeItem: {
        text: "",
        category: ""
      },
      utteranceList: []
    };
  }

  componentDidMount() {
    this.refreshList();
  }

  refreshList = () => {
    axios
      .get("http://localhost:8000/api/utterances/")
      .then(res => this.setState({ utteranceList: res.data }))
      .catch(err => console.log(err));
  };

  renderItems = () => {
    const { viewCompleted } = this.state;
    const newItems = this.state.utteranceList;
    return newItems.map(item => (
      <li
        key={item.id}
        className="list-group-item d-flex justify-content-between align-items-center">
        <span className={`utterance-text mr-2`}>
          {item.text}
        </span>
        <span className={`utterance-category mr-2`}>
          {item.category.name}
        </span>

        <span>
          <button
            onClick={() => this.editItem(item)}
            className="btn btn-secondary mr-2"
          >
            {" "}Edit{" "}
          </button>
          <button
            onClick={() => this.handleDelete(item)}
            className="btn btn-danger"
          >
            Delete{" "}
          </button>
        </span>
      </li>
    ));
  };

  toggle = () => {
    this.setState({ modal: !this.state.modal });
  };

  handleSubmit = item => {
    this.toggle();
    if (item.id) {
      axios
        .put(`http://localhost:8000/api/utterances/${item.id}/`, item)
        .then(res => this.refreshList());
      return;
    }
    axios
      .post("http://localhost:8000/api/utterances/", item)
      .then(res => this.refreshList());
  };

  handleDelete = item => {
    axios
      .delete(`http://localhost:8000/api/utterances/${item.id}`)
      .then(res => this.refreshList());
  };

  createUtterance = () => {
    const item = { text: ""};
    this.setState({ activeItem: item, modal: !this.state.modal });
  };

  editItem = item => {
    this.setState({ activeItem: item, modal: !this.state.modal });
  };

  render() {
    return (
      <main className="content">
        <h1 className="text-white text-uppercase text-center my-4">Small Data</h1>
        <div className="row ">
          <div className="col-md-6 col-sm-10 mx-auto p-0">
            <div className="card p-3">
              <div className="">
                <button onClick={this.createUtterance} className="btn btn-primary">
                  Add Utterance
                </button>
              </div>
              Existing Utterances
              <ul className="list-group list-group-flush">
                {this.renderItems()}
              </ul>
            </div>
          </div>
        </div>
        {this.state.modal ? (
          <Modal
            activeItem={this.state.activeItem}
            toggle={this.toggle}
            onSave={this.handleSubmit}
          />
        ) : null}
      </main>
    );
  }
}
export default App;
