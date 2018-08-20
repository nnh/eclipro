import React from 'react'
import ReactDOM from 'react-dom'
import { Button } from 'react-bootstrap'
import { fetchWithCors } from './custom_fetch'

class Protocol extends React.Component {
  constructor(props) {
    super(props);
    this.onTrClick = this.onTrClick.bind(this);
  }

  onTrClick() {
    window.location = this.props.data.section_url;
  }

  render() {
    return (
      <tr className='clickable-tr' onClick={this.onTrClick}>
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
    fetchWithCors(`${this.props.url}.json?protocol_name_filter=${this.state.word}`).then((json) => {
      this.setState({ data: json || [] });
    });
  }

  render() {
    const head = <tr>{this.props.headers.map((header, index) => <th key={`header_${index}`}>{header}</th>)}</tr>;

    const body = this.state.data.map((protocol) =>
      <Protocol data={protocol} buttons={this.props.buttons} key={`protocol_${protocol.id}`} />
    );

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
