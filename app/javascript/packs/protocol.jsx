import React from 'react'
import ReactDOM from 'react-dom'
import $ from 'jquery'

class Protocol extends React.Component {
  render() {
    const head =
      <tr>
        {
          this.props.headers.map((header, index) => {
            return <th key={`header_${index}`}>{header}</th>
          })
        }
      </tr>

    const body = this.props.data.map((data) => {
      return (
        <tr key={`protocols_${data.id}`} className='clickable-tr'
            data-link={data.section_url} onClick={(e) => { this.onTrClick(e) }}>
          <td>{data.title}</td>
          <td>{data.my_role}</td>
          <td>{data.principal_investigator}</td>
          <td>{data.status}</td>
          <td>{data.version}</td>
          <td>
            <a href={data.show_url} className='btn btn-default' onClick={(e) => { this.onClick(e) }}>{this.props.buttons[0]}</a>
          </td>
          <td>
            {(() => {
              if (data.export_pdf_url.length > 0) {
                return (
                  <a href={data.export_pdf_url} className='btn btn-default' target='_blank' onClick={(e) => { this.onClick(e) }}>
                    {this.props.buttons[1]}
                  </a>
                );
              }
            })()}
            {(() => {
              if (data.export_docx_url.length > 0) {
                return (
                  <a href={data.export_docx_url} className='btn btn-default ml-s' target='_blank' onClick={(e) => { this.onClick(e) }}>
                    {this.props.buttons[2]}
                  </a>
                );
              }
            })()}
          </td>
          <td>
            <a href={data.clone_url} className='btn btn-default' onClick={(e) => { this.onClick(e) }}>{this.props.buttons[3]}</a>
          </td>
        </tr>
      );
    });

    return (
      <table className='table'>
        <thead>{head}</thead>
        <tbody>{body}</tbody>
      </table>
    );
  }

  onTrClick(e) {
    window.location = $(e.target).parent().data('link');
  }

  onClick(e) {
    e.stopPropagation();
    return true;
  }
}

$(() => {
  function filtering() {
    $.ajax({
      url: $('.filter-form').data('url'),
      type: 'GET',
      dataType: 'json',
      data: {
        protocol_name_filter: $('.filter-form').val()
      }
    }).done((res) => {
      const target = $('.protocols-table');
      ReactDOM.render(
        <Protocol data={res} headers={target.data('headers')} buttons={target.data('buttons')} />,
        $('.protocols-table')[0]
      );
    });
  }
  $('.filter-button').click(() => {
    filtering();
  });
  $('.filter-form').keypress((e) => {
    if (e.keyCode == 13) filtering();
  });
  if ($('.filter-button').length > 0) {
    filtering();
  }
});
