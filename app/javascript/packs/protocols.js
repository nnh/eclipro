import React from 'react'

export class Protocols extends React.Component {
  render() {
    let head =
      <tr>
        {
          this.props.headers.map((header, index) => {
            return <th key={'header_' + index}>{header}</th>
          })
        }
      </tr>

    let body = [];
    this.props.data.map((data) => {
      body.push(
        <tr key={'protocols_' + data.id} className='clickable-tr' data-link={data.section_url} >
          <td>{data.title}</td>
          <td>{data.my_role}</td>
          <td>{data.principal_investigator}</td>
          <td>{data.status}</td>
          <td>{data.version}</td>
          <td> <a href={data.show_url} className='btn btn-default'>{this.props.buttons[0]}</a></td>
          <td>
            {data.export_pdf_url.length > 0 ?
              <a href={data.export_pdf_url} className='btn btn-default' target='_blank'>{this.props.buttons[1]}</a> : ''}
            {data.export_docx_url.length > 0 ?
              <a href={data.export_docx_url} className='btn btn-default ml-s' target='_blank'>{this.props.buttons[2]}</a> : ''}
          </td>
          <td><a href={data.clone_url} className='btn btn-default'>{this.props.buttons[3]}</a></td>
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
}
