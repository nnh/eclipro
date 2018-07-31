import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'
import { Button, Modal } from 'react-bootstrap'

class History extends React.Component {
  constructor(props) {
    super(props);
    this.onClick = this.onClick.bind(this);
  }

  render() {
    return (
      <tr>
        <td>{this.props.content.no_seq} {this.props.content.title}</td>
        <td>{this.props.index}</td>
        <td>{this.props.version.whodunnit}</td>
        <td>{this.props.version.created_at}</td>
        <td>
          {
            this.props.version.revert_url && (
              <Button bsStyle='warning' href={`${this.props.version.revert_url}&index=${this.props.index}`} data-confirm={this.props.buttons[2]} >
                {this.props.buttons[0]}
              </Button>)
          }
        </td>
        <td>
          <Button data-url={`${this.props.version.compare_url}?index=${this.props.index}`} onClick={this.onClick}>
            {this.props.buttons[1]}
          </Button>
        </td>
      </tr>
    );
  }

  onClick(e) {
    fetch(e.target.dataset.url, {
      mode: 'cors',
      credentials: 'include'
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.props.showCompare(true, json.data);
    });
  }
}

class HistoryCompare extends React.Component {
  constructor(props) {
    super(props);
    this.onClick = this.onClick.bind(this);
  }

  render() {
    return (
      <div>
        <div className='text-right'>
          <Button onClick={this.onClick}>{this.props.text}</Button>
        </div>
        <hr />
        <div dangerouslySetInnerHTML={{__html: this.props.data}}></div>
      </div>
    );
  }

  onClick() {
    this.props.showCompare(false, null);
  }
}

class ShowHistoryButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: false,
      content: null,
      compare: null,
      showCompare: false
    }
    this.handleClose = this.handleClose.bind(this);
    this.handleShow = this.handleShow.bind(this);
    this.showCompare = this.showCompare.bind(this);

    this.getContent();
  }

  handleClose() {
    this.setState({ show: false });
  }

  handleShow() {
    this.setState({ show: true });
  }

  getContent() {
    fetch(this.props.modalData.url, {
      mode: 'cors',
      credentials: 'include'
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.setState({ content: json })
    });
  }

  showCompare(show, compare) {
    this.setState({
      showCompare: show,
      compare: compare
    });
  }

  render() {
    const head =
      <tr>
        {this.props.modalData.headers.map((header, index) => { return <th key={`header_index_${index}`}>{header}</th>; })}
      </tr>;

    const histories = this.state.content ? (this.state.content.versions.map((version, index) => {
      return <History content={this.state.content} version={version} index={index} buttons={this.props.modalData.buttons}
                      key={`history_${version.id}`} showCompare={this.showCompare} />;
    })) : [];

    const compare = this.state.compare ?
      <HistoryCompare data={this.state.compare} text={this.props.modalData.backText} showCompare={this.showCompare} /> : null;

    return (
      <span>
        <Button onClick={this.handleShow}>{ this.props.text }</Button>
        <Modal show={this.state.show} onHide={this.handleClose}>
          <Modal.Header closeButton>
            <Modal.Title>{this.props.modalData.title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <div className={this.state.showCompare ? 'hidden' : ''}>
              <table className='table'>
                <thead>{head}</thead>
                <tbody>{histories.reverse()}</tbody>
              </table>
            </div>
            <div className={this.state.showCompare ? '' : 'hidden'}>{compare}</div>
          </Modal.Body>
        </Modal>
      </span>
    );
  }
}

export { ShowHistoryButton }
