import React from 'react'
import ReactDOM from 'react-dom'

class CommentIndex extends React.Component {
  render() {
    let body = [];

    this.props.data.map((data) => {
      body.push(
        <div className={`comment p-m mt-s mb-s${data.resolve ? ' resolve-comment' : '' }`} key={`comment_${data.id}`} >
          <div className='comment-header'>
            <i className='fa fa-user mr-xs'></i>
            {data.user.name}
            <div className='pull-right'>
              <i className='fa fa-clock-o mr-xs'></i>
              {data.created_at}
            </div>
          </div>
          <div className='comment-body'>{data.body}</div>
          <div className='comment-footer text-right'>
            {
              data.reply_url.length > 0 ?
                <button className='btn btn-default reply-button' data-url={data.reply_url} data-parent-id={data.id} >
                  {this.props.buttons[0]}
                </button> : ''
            }
            {
              data.resolve_url.length > 0 ?
                <button className='btn btn-default resolve-button' data-url={data.resolve_url}>
                  {this.props.buttons[1]}
                </button> : ''
            }
          </div>
          <div className='reply-comments ml-xl'>
            {data.replies.length > 0 ? <CommentIndex data={data.replies} buttons={this.props.buttons} /> : null}
          </div>
          <div className='reply-form' id={`reply-${data.id}`}></div>
        </div>
      );
    });

    return (
      <div>{body}</div>
    );
  }
}

class CommentForm extends React.Component {
  render() {
    return (
      <div>
        <textarea name='comment[body]' className='form-control mt-s mb-s comment-form-body' rows='3'></textarea>
        <div className='text-right'>
          <button className='btn btn-default comment-submit-button' disabled='true'
                  data-content-id={this.props.data.content_id} data-user-id={this.props.data.current_user_id}
                  data-parent-id={this.props.data.parent_id} data-url={this.props.data.url}>
            {this.props.buttons[0]}
          </button>
          <button className='btn btn-default ml-s comment-cancel-button'>{this.props.buttons[1]}</button>
        </div>
      </div>
    );
  }
}

export { CommentIndex, CommentForm }
