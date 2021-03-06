import React from 'react';
import { Button } from 'react-bootstrap';
import { fetchWithCors } from './custom_fetch';
import I18n from './i18n';
import PropTypes from 'prop-types';

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
        <td><Button href={this.props.data.show_url}>{I18n.t('js.protocol.details')}</Button></td>
        <td>{this.props.data.export_url && (<Button href={this.props.data.export_url}>{I18n.t('js.protocol.export')}</Button>)}</td>
        <td><Button href={this.props.data.clone_url}>{I18n.t('js.protocol.clone')}</Button></td>
      </tr>
    );
  }
}

Protocol.propTypes = {
  data: PropTypes.object
};

export default class ProtocolIndex extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      word: '',
      data: []
    };
    this.onChange = this.onChange.bind(this);
    this.onKeyPress = this.onKeyPress.bind(this);
    this.filtering = this.filtering.bind(this);

    this.filtering();
  }

  onChange(e) {
    this.setState({ word: e.target.value });
  }

  onKeyPress(e) {
    if (e.charCode === 13) this.filtering();
  }

  filtering() {
    fetchWithCors(`${this.props.url}.json?protocol_name_filter=${this.state.word}`).then((json) => {
      this.setState({ data: json || [] });
    });
  }

  render() {
    const head = <tr>{I18n.t('js.protocol.headers').map((header, index) => <th key={`header_${index}`}>{header}</th>)}</tr>;

    const body = this.state.data.map((protocol) =>
      <Protocol data={protocol} key={`protocol_${protocol.id}`} />
    );

    return (
      <div>
        <div className='input-group'>
          <input type='text' className='form-control' placeholder={I18n.t('js.protocol.placeholder')}
            onKeyPress={this.onKeyPress} onChange={this.onChange} />
          <div className='input-group-btn'>
            <Button onClick={this.filtering}>{I18n.t('js.protocol.filtering')}</Button>
          </div>
        </div>
        <div className='mt-xl'>
          <table className='table'>
            <thead>{head}</thead>
            <tbody>{body}</tbody>
          </table>
        </div>
      </div>
    );
  }
}

ProtocolIndex.propTypes = {
  url: PropTypes.string
};
