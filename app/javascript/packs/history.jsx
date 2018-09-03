import React from 'react'
import ReactDOM from 'react-dom'
import { Button, Modal } from 'react-bootstrap'
import { fetchWithCors } from './custom_fetch'

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
              <Button bsStyle='warning' href={`${this.props.version.revert_url}&index=${this.props.index}`} data-confirm={I18n.t('js.history.confirm')} >
                {I18n.t('js.history.revert')}
              </Button>)
          }
        </td>
        <td>
          <Button onClick={this.onClick}>{I18n.t('js.history.compare')}</Button>
        </td>
      </tr>
    );
  }

  onClick() {
    fetchWithCors(`${this.props.version.compare_url}?index=${this.props.index}`).then((json) => {
      this.props.onShowCompare(true, json.data || '');
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
          <Button onClick={this.onClick}>{I18n.t('js.history.back')}</Button>
        </div>
        <hr />
        <div dangerouslySetInnerHTML={{__html: this.props.data}}></div>
      </div>
    );
  }

  onClick() {
    this.props.onShowCompare(false, '');
  }
}

class ShowHistoryButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: false,
      content: { versions: [] },
      compare: '',
      showCompare: false
    }
    this.handleClose = this.handleClose.bind(this);
    this.handleShow = this.handleShow.bind(this);
    this.onShowCompare = this.onShowCompare.bind(this);

    this.getContent();
  }

  handleClose() {
    this.setState({ show: false });
  }

  handleShow() {
    this.setState({ show: true });
  }

  getContent() {
    fetchWithCors(this.props.url).then((json) => {
      this.setState({ content: json || { versions: [] } })
    });
  }

  onShowCompare(show, compare) {
    this.setState({
      showCompare: show,
      compare: compare
    });
  }

  render() {
    const head =
      <tr>{I18n.t('js.history.headers').map((header, index) => <th key={`header_index_${index}`}>{header}</th>)}</tr>;

    const histories = this.state.content.versions.map((version, index) =>
      <History content={this.state.content} version={version} index={index}
               key={`history_${version.id}`} onShowCompare={this.onShowCompare} />
    )

    const content = this.state.compare && this.state.showCompare ?
      <HistoryCompare data={this.state.compare} onShowCompare={this.onShowCompare} />
      : (
        <table className='table'>
          <thead>{head}</thead>
          <tbody>{histories.reverse()}</tbody>
        </table>
      );

    return (
      <span>
        <Button onClick={this.handleShow}>{I18n.t('js.history.history')}</Button>
        <Modal show={this.state.show} onHide={this.handleClose}>
          <Modal.Header closeButton>
            <Modal.Title>{I18n.t('js.history.history')}</Modal.Title>
          </Modal.Header>
          <Modal.Body>{content}</Modal.Body>
        </Modal>
      </span>
    );
  }
}

export { ShowHistoryButton }
