import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'
import { Button } from 'react-bootstrap'

class Protocol extends React.Component {
  constructor(props) {
    super(props);
    this.onTrClick = this.onTrClick.bind(this);
  }

  onTrClick(e) {
    window.location = e.target.parentElement.dataset.link;
  }

  render() {
    return (
      <tr className='clickable-tr' data-link={this.props.data.section_url} onClick={this.onTrClick}>
        <td>{this.props.data.title}</td>
        <td>{this.props.data.my_role}</td>
        <td>{this.props.data.principal_investigator}</td>
        <td>{this.props.data.status}</td>
        <td>{this.props.data.version}</td>
        <td><Button href={this.props.data.show_url}>{this.props.buttons[0]}</Button></td>
        <td>{this.props.data.export_url && (<Button href={this.props.data.export_url}>{this.props.buttons[1]}</Button>)}</td>
        <td><Button href={this.props.data.clone_url}>{this.props.buttons[2]}</Button></td>
      </tr>
    );
  }
}

class ProtocolIndex extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      word: '',
      data: []
    }
    this.onChange = this.onChange.bind(this);
    this.onKeyPress = this.onKeyPress.bind(this);
    this.filtering = this.filtering.bind(this);

    this.filtering();
  }

  onChange(e) {
    this.setState({ word: e.target.value });
  }

  onKeyPress(e) {
    if (e.charCode == 13) this.filtering();
  }

  filtering() {
    fetch(`${this.props.url}.json?protocol_name_filter=${this.state.word}`, {
      mode: 'cors',
      credentials: 'include'
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.setState({ data: json });
    });
  }

  render() {
    const head = <tr>{this.props.headers.map((header, index) => { return <th key={`header_${index}`}>{header}</th>; })}</tr>;

    const body = this.state.data ? this.state.data.map((protocol) => {
      return <Protocol data={protocol} buttons={this.props.buttons} key={`protocol_${protocol.id}`} />;
    }) : null;

    return (
      <div>
        <div className='input-group'>
          <input type='text' className='form-control' placeholder={this.props.placeholder}
                 onKeyPress={this.onKeyPress} onChange={this.onChange} />
          <div className='input-group-btn'>
            <Button onClick={this.filtering}>{this.props.text}</Button>
          </div>
        </div>
        <div className='mt-xl'>
          <table className='table'>
            <thead>{head}</thead>
            <tbody>{body}</tbody>
          </table>
        </div>
      </div>
    )
  }
}

export { ProtocolIndex }
