import React from 'react'
import ReactDOM from 'react-dom'
import $ from 'jquery'

class HistoryIndex extends React.Component {
  render() {
    const head =
      <tr>
        {
          this.props.headers.map((header, index) => {
            return <th key={`header_index_${index}`}>{header}</th>
          })
        }
      </tr>

    const body = this.props.data.versions.map((version, index) => {
      return (
        <tr key={`history_${version.id}`} >
          <td>{this.props.data.no} {this.props.data.title}</td>
          <td>{index}</td>
          <td>{version.whodunnit}</td>
          <td>{version.created_at}</td>
          <td>
            {(() => {
              if (version.revert_url.length > 0) {
                return (
                  <a href={`${version.revert_url}&index=${index}`} className='btn btn-warning'
                     data-confirm={this.props.buttons[2]} onClick={(e) => { this.onRevert(e) }}>
                    {this.props.buttons[0]}
                  </a>
                );
              }
            })()}
          </td>
          <td>
            <button className='btn btn-default'
                    data-url={`${version.compare_url}?index=${index}`} onClick={(e) => { this.onCompare(e) }}>
              {this.props.buttons[1]}
            </button>
          </td>
        </tr>
      );
    });

    return (
      <table className='table'>
        <thead>{head}</thead>
        <tbody>{body.reverse()}</tbody>
      </table>
    );
  }

  onRevert(e) {
    $('.history-modal').modal('hide');
  }

  onCompare(e) {
    $.ajax({
      url: $(e.target).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done((res) => {
      ReactDOM.render(
        <HistoryCompare data={res.data} text={$('.history-compare').data('text')} />,
        $('.history-compare')[0]
      );
      $('.history-index').hide();
    });
  }
}

class HistoryCompare extends React.Component {
  render() {
    return (
      <div>
        <div className='text-right'>
          <button className='btn btn-default' onClick={(e) => this.onClick(e) }>
            {this.props.text}
          </button>
        </div>
        <hr />
        <div dangerouslySetInnerHTML={{__html: this.props.data}}></div>
      </div>
    );
  }

  onClick(e) {
    ReactDOM.unmountComponentAtNode($('.history-compare')[0]);
    $('.history-index').show();
  }
}

$(() => {
  $('.history-button').click((e) => {
    $.ajax({
      url: $(e.target).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done((res) => {
      const target = $('.history-index');
      ReactDOM.render(
        <HistoryIndex data={res} headers={target.data('headers')} buttons={target.data('buttons')} />,
        $('.history-index')[0]
      );
      $('.history-modal').modal('show');
    });
  });
});
