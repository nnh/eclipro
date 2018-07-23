import React from 'react'
import { Modal } from 'react-bootstrap'

export default class CustomModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = { show: false };
  }

  componentDidMount() {
    this.props.selector.addEventListener('click', (e) => {
      this.handleShow(e);
    });
  }

  handleClose(e) {
    this.setState({ show: false });
  }

  handleShow(e) {
    this.setState({ show: true });
    if (this.props.event) { this.props.event(); }
  }

  render() {
    return (
      <Modal show={this.state.show} onHide={(e) => { this.handleClose(e) }}>
        <Modal.Header closeButton>
          <Modal.Title>{this.props.title}</Modal.Title>
        </Modal.Header>
        <Modal.Body className={this.props.className}>
        </Modal.Body>
      </Modal>
    );
  }
}
