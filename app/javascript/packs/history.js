import React from 'react'

class HistoryIndex extends React.Component {
  render() {
    let head =
      <tr>
        {
          this.props.headers.map((header, index) => {
            return <th key={'header_index_' + index}>{header}</th>
          })
        }
      </tr>

    let body = [];

    for (let i = this.props.data.versions.length - 1; i >= 0; i--) {
      let version = this.props.data.versions[i]
      body.push(
        <tr key={'history_' + i} >
          <td>{this.props.data.no} {this.props.data.title}</td>
          <td>{i}</td>
          <td>{version.whodunnit}</td>
          <td>{version.created_at}</td>
          <td>
            {version.revert_url.length > 0 ?
              <a href={`${version.revert_url}&index=${i}`} className='btn btn-warning history-revert'
                                                           data-confirm={this.props.buttons[2]}>
                {this.props.buttons[0]}
              </a> : ''
            }
          </td>
          <td>
            <button name='button' type='button' className='btn btn-default compare-button'
                    data-url={`${version.compare_url}?index=${i}`}>
              {this.props.buttons[1]}
            </button>
          </td>
        </tr>
      );
    }

    return (
      <table className='table'>
        <thead>{head}</thead>
        <tbody>{body}</tbody>
      </table>
    );
  }
}

class HistoryCompare extends React.Component {
  render() {
    return (
      <div>
        <div className='text-right'>
          <button name='button' type='button' className='btn btn-default history-compare-back'>
            {this.props.text}
          </button>
        </div>
        <hr />
        <div dangerouslySetInnerHTML={{__html: this.props.data}}></div>
      </div>
    )
  }
}

export { HistoryIndex, HistoryCompare }
